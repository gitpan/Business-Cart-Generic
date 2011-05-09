package Business::Cart::Generic::Database::Product;

use strict;
use warnings;

use Moose;

extends 'Business::Cart::Generic::Database::Base';

use namespace::autoclean;

our $VERSION = '0.82';

# --------------------------------------------------

sub inflate_product
{
	my($self, $product) = @_;

	$self -> db -> logger -> log(debug => 'inflate_product()');

	return
	{
		currency    => $product -> currency -> code,
		description => $product -> description,
		id          => $product -> id,
		name        => $product -> name,
		price       => $self -> format_amount($product -> price, $product -> currency),
	};

} # End of inflate_product.

# --------------------------------------------------

sub get_products
{
	my($self, $target) = @_;

	$self -> db -> logger -> log(debug => 'get_products()');

	return scalar $self -> schema -> resultset('Product') -> search
		(
		 {},
		 {
			 join     => 'currency',
			 order_by => [qw/me.name me.description/],
		 }
		);

} # End of get_products.

# --------------------------------------------------

__PACKAGE__ -> meta -> make_immutable;

1;
