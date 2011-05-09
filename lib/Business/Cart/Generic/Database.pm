package Business::Cart::Generic::Database;

use strict;
use warnings;

use Business::Cart::Generic::Database::Order;
use Business::Cart::Generic::Database::Product;
use Business::Cart::Generic::Database::Search;
use Business::Cart::Generic::Schema;

use Data::Session;

use DBIx::Admin::CreateTable;
use DBIx::Connector;

use List::Util 'min';

use Moose;

extends 'Business::Cart::Generic::Base';

has connector =>
(
 is  => 'rw',
 isa => 'Any',
 required => 0,
);

has online =>
(
 default  => 1,
 is       => 'ro',
 isa      => 'Int',
 required => 0,
);

has order =>
(
 is  => 'rw',
 isa => 'Business::Cart::Generic::Database::Order',
 required => 0,
);

has product =>
(
 is  => 'rw',
 isa => 'Business::Cart::Generic::Database::Product',
 required => 0,
);

has query =>
(
 is  => 'ro',
 isa => 'Any',
 required => 1,
);

has schema =>
(
 is  => 'rw',
 isa => 'Business::Cart::Generic::Schema',
 required => 0,
);

has search =>
(
 is  => 'rw',
 isa => 'Business::Cart::Generic::Database::Search',
 required => 0,
);

has session =>
(
 is  => 'rw',
 isa => 'Data::Session',
 required => 0,
);

use namespace::autoclean;

our $VERSION = '0.82';

# -----------------------------------------------

sub BUILD
{
	my($self)   = @_;
	my($config) = $self -> config;
	my($attr)   = {AutoCommit => $$config{AutoCommit}, RaiseError => $$config{RaiseError} };

	if ( ($$config{dsn} =~ /SQLite/i) && $$config{sqlite_unicode})
	{
		$$attr{sqlite_unicode} = 1;
	}

	$self -> connector(DBIx::Connector -> new($$config{dsn}, $$config{username}, $$config{password}, $attr) );
	$self -> schema
		(
		 Business::Cart::Generic::Schema -> connect(sub{return $self -> connector -> dbh})
		);

	if ($$config{dsn} =~ /SQLite/i)
	{
		$self -> connector -> dbh -> do('PRAGMA foreign_keys = ON');
	}

	# populate.tables.pl and place.orders.pl call us with online => 0.

	$self -> set_up_session($config) if ($self -> online);

	# Note: A database object is created before a session object, so
	# we can't pass the session object to any other objects. Not that
	# we want to. Just use $obj -> db -> session...

	$self -> order
		(
		 Business::Cart::Generic::Database::Order -> new
		 (
		  db => $self,
		 )
		);

	$self -> product
		(
		 Business::Cart::Generic::Database::Product -> new
		 (
		  db => $self,
		 )
		);

	$self -> search
		(
		 Business::Cart::Generic::Database::Search -> new
		 (
		  db => $self,
		 )
		);

	return $self;

}	# End of BUILD.

# --------------------------------------------------

sub decrement_order_items
{
	my($self) = @_;

	$self -> logger -> log(debug => 'decrement_order_items()');

	my($order_session) = $self -> session -> param('order');

	$$order_session{item_count}--;

	$self -> session -> param(order => $order_session);

	return $$order_session{item_count};

} # End of decrement_order_items.

# --------------------------------------------------

sub get_id2name_map
{
	my($self, $class_name, $column_list) = @_;
	my(@rs)       = $self -> schema -> resultset($class_name) -> search({}, {columns => ['id', @$column_list]});
	@$column_list = grep{! /currency_id/} @$column_list;

	my($currency, $column);
	my(%map);
	my(@s);

	for my $rs (@rs)
	{
		if ($class_name eq 'Product')
		{
			$currency = $self -> schema -> resultset('Currency') -> search({id => $rs -> currency_id}, {}) -> single;
		}

		@s = ();

		for $column (@$column_list)
		{
			if ($column eq 'price')
			{
				push @s, $self -> format_amount($rs -> price, $currency);
			}
			elsif ($rs -> $column ne '')
			{
				push @s, $rs -> $column;
			}
		}

		$map{$rs -> id} = join(', ', @s);
	}

	return {%map};

} # End of get_id2name_map.

# --------------------------------------------------

sub get_special_id2name_map
{
	my($self, $class_name, $constraint_name, $constraint_id) = @_;

	my($map)    = {map{($_ -> id, $_ -> name)} $self -> schema -> resultset($class_name) -> search({$constraint_name => $constraint_id}, {columns => [qw/id name/]})};
	my($min_id) = min keys %$map;

	return ($map, $min_id);

} # End of get_special_id2name_map.

# --------------------------------------------------

sub increment_order_count
{
	my($self) = @_;

	$self -> logger -> log(debug => 'increment_order_count()');

	my($order_session) = $self -> session -> param('order');

	$$order_session{order_count}++;

	$self -> session -> param(order => $order_session);

	return $$order_session{order_count};

} # End of increment_order_count.

# --------------------------------------------------

sub reset_order
{
	my($self) = @_;

	$self -> logger -> log(debug => 'reset_order()');

	# If the CGI client (user) is a new client, then start a new order.
	# Of course, the user may not actually buy anything. We only know what
	# they're doing when they click buttons on the Order form, in which case
	# the code in *::Controller::Order will be called.
	# These fields both help us track orders and help us unwind cancelled orders.

	$self -> session -> param(order => {id => 0, item_count => 0, item_id => 0, order_count => 0});

} # End of reset_order.

# --------------------------------------------------

sub set_up_session
{
	my($self, $config) = @_;

	$self -> logger -> log(debug => 'set_up_session()');

	$self -> session
		(
		 Data::Session -> new
		 (
		  dbh        => $self -> connector -> dbh,
		  name       => 'sid',
		  pg_bytea   => $$config{pg_bytea} || 0,
		  pg_text    => $$config{pg_text}  || 0,
		  query      => $self -> query,
		  table_name => $$config{session_table_name},
		  type       => $$config{session_driver},
		 )
		);

	if ($Data::Session::errstr)
	{
		die $Data::Session::errstr;
	}

	if ($self -> session -> is_new)
	{
		$self -> reset_order;
	}

} # End of set_up_session.

# --------------------------------------------------

sub validate_country_id
{
	my($self, $id) = @_;

	return $self -> schema -> resultset('Country') -> search({id => $id}, {}) -> single ? 1 : 0;

} # End of validate_country_id.

# --------------------------------------------------

sub validate_customer_id
{
	my($self, $id) = @_;

	return $self -> schema -> resultset('Customer') -> search({id => $id}, {}) -> single ? 1 : 0;

} # End of validate_customer_id.

# --------------------------------------------------

sub validate_payment_method_id
{
	my($self, $id) = @_;

	return $self -> schema -> resultset('PaymentMethod') -> search({id => $id}, {}) -> single ? 1 : 0;

} # End of validate_payment_method_id.

# --------------------------------------------------

sub validate_product
{
	my($self, $id, $quantity) = @_;
	my($product) = $self -> schema -> resultset('Product') -> search({id => $id}, {}) -> single;
	my($result)  = 0;

	# max_quantity_per_order will be 24. See config/.htbusiness.cart.generic.conf.

	if ($product && ($quantity > 0) && ($quantity <= ${$self -> config}{max_quantity_per_order}) )
	{
		# We don't handle back-orders, so you can only buy what's in stock.

		$result = ($product -> quantity_on_hand >= $quantity) ? 1 : 0;
	}

	return $result;

} # End of validate_product.

# --------------------------------------------------

sub validate_street_address_id
{
	my($self, $id) = @_;

	return $self -> schema -> resultset('StreetAddress') -> search({id => $id}, {}) -> single ? 1 : 0;

} # End of validate_street_address_id.

# --------------------------------------------------

sub validate_tax_class_id
{
	my($self, $id) = @_;

	return $self -> schema -> resultset('TaxClass') -> search({id => $id}, {}) -> single ? 1 : 0;

} # End of validate_tax_class_id.

# --------------------------------------------------

sub validate_zone_id
{
	my($self, $id) = @_;

	return $self -> schema -> resultset('Zone') -> search({id => $id}, {}) -> single ? 1 : 0;

} # End of validate_zone_id.

# --------------------------------------------------

__PACKAGE__ -> meta -> make_immutable;

1;
