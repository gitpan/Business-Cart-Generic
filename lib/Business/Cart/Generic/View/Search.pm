package Business::Cart::Generic::View::Search;

use strict;
use warnings;

use JSON::XS;

use Moose;

extends 'Business::Cart::Generic::View::Base';

use namespace::autoclean;

our $VERSION = '0.82';

# -----------------------------------------------

sub build_search_html
{
	my($self) = @_;

	$self -> db -> logger -> log(debug => 'build_search_html()');

	# Make YUI happy by turning the HTML into 1 long line.

	my($html) = $self -> templater -> render
		(
		 'search.tx',
		 {
			 sid => $self -> db -> session -> id,
		 }
		);
	$html =~ s/\n//g;

	return $html;

} # End of build_search_html.

# -----------------------------------------------

sub build_head_js
{
	my($self) = @_;

	$self -> db -> logger -> log(debug => 'build_head_js()');

	return $self -> templater -> render
		(
		 'search.js',
		 {
		 }
		);

} # End of build_head_js.

# -----------------------------------------------

sub display
{
	my($self, $number, $order) = @_;

	$self -> db -> logger -> log(debug => "display($number, ...)");

	if (! $order)
	{
		$order = [ [{td => "No order matches # '$number'"}] ];
	}

	return $self -> templater -> render
		(
		'basic.table.tx',
		 {
			 border => 0,
			 row    => $order,
		 }
		);

} # End of display.

# -----------------------------------------------

__PACKAGE__ -> meta -> make_immutable;

1;
