package Business::Cart::Generic::Database::Base;

use strict;
use warnings;

use Business::Cart::Generic::Database;
use Business::Cart::Generic::Schema;

use Moose;

extends 'Business::Cart::Generic::Base';

has db =>
(
 is  => 'rw',
 isa => 'Business::Cart::Generic::Database',
 required => 0,
);

has schema =>
(
 is  => 'rw',
 isa => 'Business::Cart::Generic::Schema',
 required => 0,
);

use namespace::autoclean;

our $VERSION = '0.82';

# -----------------------------------------------

sub BUILD
{
	my($self) = @_;

	$self -> schema
		(
		 Business::Cart::Generic::Schema -> connect(sub{return $self -> connector -> dbh})
		);

} # End of BUILD.

# -----------------------------------------------

__PACKAGE__ -> meta -> make_immutable;

1;
