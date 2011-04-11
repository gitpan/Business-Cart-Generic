package Business::Cart::Generic::View::AutoComplete;

use strict;
use warnings;

use JSON::XS;

use Moose;

extends 'Business::Cart::Generic::View::Base';

use namespace::autoclean;

our $VERSION = '0.80';

# -----------------------------------------------

sub display
{
	my($self, $type, $target, $result) = @_;

	$self -> db -> logger -> log(debug => "display($type, $target, " . scalar @$result . ')');

	my($output);

	# Warning: YUI3's AutoComplete takes an arrayref of candidates, not an arrayref of hashrefs.

	if ($#$result >= 0)
	{
		$output = {results => $result};
	}
	else
	{
		$output = {results => []};
	}

	return JSON::XS -> new -> utf8 -> encode($output);

} # End of display.

# -----------------------------------------------

__PACKAGE__ -> meta -> make_immutable;

1;
