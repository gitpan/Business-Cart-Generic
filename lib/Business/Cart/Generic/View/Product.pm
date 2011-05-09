package Business::Cart::Generic::View::Product;

use strict;
use warnings;

use JSON::XS;

use Moose;

use Text::Xslate 'mark_raw';

extends 'Business::Cart::Generic::View::Base';

use namespace::autoclean;

our $VERSION = '0.82';

# -----------------------------------------------

sub format_products
{
	my($self, $product) = @_;

	$self -> db -> logger -> log(debug => "format_products(...)");

	my(@row);

	push @row,
	[
		{td => 'Name'},
		{td => 'Description'},
		{td => 'Price'},
		{td => 'Currency'},
	];

	for my $item (@$product)
	{
		push @row,
		[
		{td => $$item{name} },
		{td => $$item{description} },
		{td => $$item{price} },
		{td => $$item{currency} },
		];
	}

	push @row,
	[
		{td => 'Name'},
		{td => 'Description'},
		{td => 'Price'},
		{td => 'Currency'},
	];

	return \@row;

} # End of format_products.

# -----------------------------------------------

__PACKAGE__ -> meta -> make_immutable;

1;
