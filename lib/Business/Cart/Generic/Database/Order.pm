package Business::Cart::Generic::Database::Order;

use strict;
use warnings;

use Moose;

extends 'Business::Cart::Generic::Database::Base';

use namespace::autoclean;

our $VERSION = '0.81';

# --------------------------------------------------

sub inflate_order
{
	my($self, $order) = @_;

	$self -> db -> logger -> log(debug => 'inflate_order()');

	my($id)      = $order -> id;
	my $item_set = $self -> schema -> resultset('OrderItem') -> search
		(
		 {
			 order_id => $id
		 },
		 {
			 join     => [qw/product/],
			 order_by => [qw/product.name/],
		 }
		);
	my(%total) =
		(
		price => 0,
		tax   => 0,
		);

	my($currency);
	my(@item);

	while (my $item = $item_set -> next)
	{
		$currency     = $self -> schema -> resultset('Currency') -> search({id => $item -> product -> currency_id},{}) -> single;
		$total{price} += $item -> price;
		$total{tax}   += $item -> tax;

		push @item,
		{
			name       => $item -> name,
			order_id   => $item -> order_id,
			price      => $self -> format_amount($item -> price, $currency),
			product_id => $item -> product_id,
			quantity   => $item -> quantity,
			tax        => $self -> format_amount($item -> tax, $currency),
		};
	}

	return
	{
		billing_address =>
		{
			country_name => $order -> billing_address -> country -> name,
			locality     => $order -> billing_address -> locality,
			street_1     => $order -> billing_address -> street_1,
			zone_name    => $order -> billing_address -> zone -> name,
		},
		customer =>
		{
			name  => $order -> customer -> name,
			title => $order -> customer -> title -> name,
		},
		customer_address =>
		{
			country_name => $order -> customer_address -> country -> name,
			locality     => $order -> customer_address -> locality,
			street_1     => $order -> customer_address -> street_1,
			zone_name    => $order -> customer_address -> zone -> name,
		},
		delivery_address =>
		{
			country_name => $order -> delivery_address -> country -> name,
			locality     => $order -> delivery_address -> locality,
			street_1     => $order -> delivery_address -> street_1,
			zone_name    => $order -> delivery_address -> zone -> name,
		},
		date_added     => $order -> date_added,
		date_completed => $order -> date_completed,
		id             => $id,
		item           => [@item],
		order_status   => $order -> order_status -> name,
		payment_method => $order -> payment_method -> name,
		total_price    => $self -> format_amount($total{price}, $currency), # Careful! $currency assumed after loop.
		total_tax      => $self -> format_amount($total{tax}, $currency),
	};

} # End of inflate_order.

# --------------------------------------------------

sub get_orders
{
	my($self, $target) = @_;

	$self -> db -> logger -> log(debug => 'get_orders()');

	return scalar $self -> schema -> resultset('Order') -> search
		(
		 {},
		 {
			 join     => [qw/billing_address customer customer_address delivery_address order_status payment_method/],
			 order_by => [qw/me.date_added/],
		 }
		);

} # End of get_orders.

# --------------------------------------------------

__PACKAGE__ -> meta -> make_immutable;

1;
