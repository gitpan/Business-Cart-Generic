package Business::Cart::Generic::Util::Logger;

use strict;
use warnings;

use Log::Handler::Output::DBI;

use Moose;

has config =>
(
 is       => 'rw',
 isa      => 'HashRef',
 required => 1,
);

has logger =>
(
 is  => 'rw',
 isa => 'Any',
);

use namespace::autoclean;

our $VERSION = '0.81';

# -----------------------------------------------

sub BUILD
{
	my($self)   = @_;
	my($config) = $self -> config;

	$self -> logger
		(
		 Log::Handler::Output::DBI -> new
		 (
		  columns     => [qw/level message/],
		  data_source => $$config{dsn},
		  password    => $$config{password},
		  persistent  => 1,
		  table       => 'log',
		  user        => $$config{username},
		  values      => [qw/%level %message/],
		  )
		);

}	# End of BUILD.

# -----------------------------------------------

sub log
{
	my($self, $level, $s) = @_;

	$self -> logger -> log(level => $level, message => $s || '')

} # End of log.

# --------------------------------------------------

__PACKAGE__ -> meta -> make_immutable;

1;
