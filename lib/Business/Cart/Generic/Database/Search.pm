package Business::Cart::Generic::Database::Search;

use strict;
use warnings;

use Moose;

extends 'Business::Cart::Generic::Database::Base';

use namespace::autoclean;

our $VERSION = '0.81';

# --------------------------------------------------

sub find
{
	my($self, $target) = @_;

	$self -> db -> logger -> log(debug => "search($target)");

	return $self -> db -> schema -> resultset('Order') -> search
		(
		 {
		   id => $target,
		 },
		 {
		 }
		) -> single;

} # End of find.

# --------------------------------------------------

__PACKAGE__ -> meta -> make_immutable;

1;
