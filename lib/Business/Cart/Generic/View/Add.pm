package Business::Cart::Generic::View::Add;

use strict;
use warnings;

use JSON::XS;

use Moose;

extends 'Business::Cart::Generic::View::Base';

use namespace::autoclean;

our $VERSION = '0.80';

# -----------------------------------------------

sub build_add_html
{
	my($self) = @_;

	$self -> db -> logger -> log(debug => 'build_add_html()');

	# Make YUI happy by turning the HTML into 1 long line.

	my($html) = $self -> templater -> render
		(
		 'add.tx',
		 {
			 sid => $self -> db -> session -> id,
		 }
		);
	$html =~ s/\n//g;

	return $html;

} # End of build_add_html.

# -----------------------------------------------

sub build_head_js
{
	my($self) = @_;

	$self -> db -> logger -> log(debug => 'build_head_js()');

	return $self -> templater -> render
		(
		 'add.js',
		 {
			 sid => $self -> db -> session -> id,
		 }
		);

} # End of build_head_js.

# -----------------------------------------------

sub display
{
	my($self, $data) = @_;

	$self -> db -> logger -> log(debug => 'display()');

	my($output) =
	{
		results =>
			[
			 {
				 id   => $$data{id},
				 name => $$data{name},
			 }
			]
	};

	return JSON::XS -> new -> utf8 -> encode($output);

} # End of display.

# -----------------------------------------------

__PACKAGE__ -> meta -> make_immutable;

1;
