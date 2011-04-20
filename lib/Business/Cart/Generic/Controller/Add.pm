package Business::Cart::Generic::Controller::Add;

use parent 'Business::Cart::Generic::Controller';
use strict;
use warnings;

use Date::Simple;

# We don't use Moose because we isa CGI::Application.

our $VERSION = '0.81';

# -----------------------------------------------

sub display
{
	my($self) = @_;

	$self -> log(debug => 'display()');

	my($data) =
	{
		name => $self -> query -> param('name') || '-',
	};

	$$data{name_id} = $self -> param('db') -> name -> read($$data{name});

	$self -> param('db') -> name -> add($data);

	return $self -> param('view') -> add -> display($data);

} # End of display.

# -----------------------------------------------

1;
