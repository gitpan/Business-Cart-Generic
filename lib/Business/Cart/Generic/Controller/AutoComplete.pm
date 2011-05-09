package Business::Cart::Generic::Controller::AutoComplete;

use feature qw/switch/;
use parent 'Business::Cart::Generic::Controller';
use strict;
use warnings;

# We don't use Moose because we isa CGI::Application.

our $VERSION = '0.82';

# -----------------------------------------------

sub display
{
	my($self) = @_;

	$self -> log(debug => 'display()');

	my($type) = $self -> query -> param('type') || '';
	my($name) = $self -> query -> param('name') || '';

	my($result);

	given ($type)
	{
		when ('name')
		{
			$result = $self -> param('db') -> autocomplete -> name($name);
		}
	}

	return $self -> param('view') -> autocomplete -> display($type, $name, $result);

} # End of display.

# -----------------------------------------------

1;
