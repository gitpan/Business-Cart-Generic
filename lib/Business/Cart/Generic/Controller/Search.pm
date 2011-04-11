package Business::Cart::Generic::Controller::Search;

use parent 'Business::Cart::Generic::Controller';
use strict;
use warnings;

# We don't use Moose because we isa CGI::Application.

our $VERSION = '0.80';

# -----------------------------------------------

sub display
{
	my($self) = @_;

	$self -> log(debug => 'display()');

	# search($name) returns an arrayref of hashrefs.

	my($number) = $self -> query -> param('search_number') || '';
	my($order)  = $self -> param('db') -> search -> find($number);
	$order      = $order ? $self -> param('db') -> order -> inflate_order($order) : '';
	$order      = $order ? $self -> param('view') -> order -> format_order($order) : '';

	return $self -> param('view') -> search -> display($number, $order);

} # End of display.

# -----------------------------------------------

1;
