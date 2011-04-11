package Business::Cart::Generic::View;

use strict;
use warnings;

use Business::Cart::Generic::View::Add;
use Business::Cart::Generic::View::Order;
use Business::Cart::Generic::View::Product;
use Business::Cart::Generic::View::Search;

use Moose;

extends 'Business::Cart::Generic::View::Base';

has add =>
(
 is  => 'rw',
 isa => 'Business::Cart::Generic::View::Add',
);

has order =>
(
 is  => 'rw',
 isa => 'Business::Cart::Generic::View::Order',
);

has product =>
(
 is  => 'rw',
 isa => 'Business::Cart::Generic::View::Product',
);

has search =>
(
 is  => 'rw',
 isa => 'Business::Cart::Generic::View::Search',
);

use namespace::autoclean;

our $VERSION = '0.80';

# -----------------------------------------------

sub BUILD
{
	my($self) = @_;

	$self -> add
		(
		 Business::Cart::Generic::View::Add -> new
		 (
		  db        => $self -> db,
		  templater => $self -> templater,
		 )
		);

	$self -> order
		(
		 Business::Cart::Generic::View::Order -> new
		 (
		  db        => $self -> db,
		  templater => $self -> templater,
		 )
		);

	$self -> product
		(
		 Business::Cart::Generic::View::Product -> new
		 (
		  db        => $self -> db,
		  templater => $self -> templater,
		 )
		);

	$self -> search
		(
		 Business::Cart::Generic::View::Search -> new
		 (
		  db        => $self -> db,
		  templater => $self -> templater,
		 )
		);

}	# End of BUILD.

# --------------------------------------------------

__PACKAGE__ -> meta -> make_immutable;

1;
