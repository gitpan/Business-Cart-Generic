package Business::Cart::Generic::Database::AutoComplete;

use strict;
use warnings;

use Moose;

extends 'Business::Cart::Generic::Database::Base';

use namespace::autoclean;

our $VERSION = '0.82';

# --------------------------------------------------

sub build_result
{
	my($self, $rs, $result) = @_;

	# Warning: YUI3's AutoComplete takes an arrayref of candidates, not an arrayref of hashrefs.

	while (my $item = $rs -> next)
	{
		push @$result, $item -> name;
	}

	return $result;

} # End of build_result.

# --------------------------------------------------

sub name
{
	my($self, $name) = @_;

	$self -> db -> logger -> log(debug => "name($name)");

	my $rs = $self -> schema -> resultset('Name') -> search
		(
		 {
		   'me.upper_name' => {like => uc "%$name%"},
		 },
		 {
			 order_by => [qw/me.upper_name/],
		 }
		);

	return $self -> build_result($rs, []);

} # End of name.

# --------------------------------------------------

__PACKAGE__ -> meta -> make_immutable;

1;
