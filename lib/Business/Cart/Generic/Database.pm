package Business::Cart::Generic::Database;

use strict;
use warnings;

use Data::Session;

use DBIx::Admin::CreateTable;
use DBIx::Connector;

use Business::Cart::Generic::Database::Order;
use Business::Cart::Generic::Database::Product;
use Business::Cart::Generic::Database::Search;
use Business::Cart::Generic::Schema;

use Moose;

extends 'Business::Cart::Generic::Base';

has connector =>
(
 is  => 'rw',
 isa => 'Any',
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

our $VERSION = '0.81';

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

	$self -> session
		(
		 Data::Session -> new
		 (
		  data_source => $$config{dsn},
		  dbh         => $self -> connector -> dbh,
		  name        => 'sid',
		  pg_bytea    => $$config{pg_bytea} || 0,
		  pg_text     => $$config{pg_text}  || 0,
		  query       => $self -> query,
		  table_name  => $$config{session_table_name},
		  type        => $$config{session_driver},
		 )
		);

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

__PACKAGE__ -> meta -> make_immutable;

1;
