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

our $VERSION = '0.80';

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

sub format_amount
{
	my($self, $amount, $currency) = @_;
	my($decimal_places) = $currency -> decimal_places;
	my($symbol_left)    = $currency -> symbol_left;
	my($format)         = sprintf('%s%%.%sf', $symbol_left, $decimal_places);

	return sprintf($format, $amount),

} # End of format_amount.

# -----------------------------------------------

__PACKAGE__ -> meta -> make_immutable;

1;
