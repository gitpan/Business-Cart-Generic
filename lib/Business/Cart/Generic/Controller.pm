package Business::Cart::Generic::Controller;

use parent 'CGI::Application';
use strict;
use warnings;

use Business::Cart::Generic::Database;
use Business::Cart::Generic::Util::Config;
use Business::Cart::Generic::Util::Logger;
use Business::Cart::Generic::View;

use Text::Xslate;

# We don't use Moose because we ias CGI::Application.

our $VERSION = '0.81';

# -----------------------------------------------

sub cgiapp_prerun
{
	my($self, $rm) = @_;

	# Can't call, since logger not yet set up.
	#$self -> log(debug => 'cgiapp_prerun()');

	$self -> param(config => Business::Cart::Generic::Util::Config -> new -> config);
	$self -> param(logger => Business::Cart::Generic::Util::Logger -> new(config => $self -> param('config') ) );

	my($q) = $self -> query;

	# Log the CGI form parameters.

	$self -> log(info  => '');
	$self -> log(info  => $q -> url(-full => 1, -path => 1) );
	$self -> log(info  => "Param: $_: " . $q -> param($_) ) for $q -> param;

	# Other controllers add their own run modes.

	$self -> run_modes([qw/display/]);
	$self -> log(debug => 'tmpl_path: ' . ${$self -> param('config')}{template_path});

	# Set up the session. To simplify things we always use
	# Data::Session, and ignore the PSGI alternative.

	my($config) = $self -> param('config');

	$self -> param
		(
		 db => Business::Cart::Generic::Database -> new
		 (
		  query => $q,
		 )
		);

	$self -> param
		(
		 templater => Text::Xslate -> new
		 (
		  input_layer => '',
		  path        => ${$self -> param('config')}{template_path},
		 )
		);

	$self -> param
		(
		 view => Business::Cart::Generic::View -> new
		 (
		  db        => $self -> param('db'),
		  templater => $self -> param('templater'),
		 )
		);

	$self -> log(info  => 'Session id: ' . $self -> param('db') -> session -> id);

} # End of cgiapp_prerun.

# -----------------------------------------------

sub log
{
	my($self, $level, $s) = @_;

	$self -> param('logger') -> log($level => $s);

} # End of log.

# -----------------------------------------------

sub teardown
{
	my($self) = @_;

	$self -> log(debug => 'teardown()');

	# This is mandatory under Plack.

	$self -> param('db') -> session -> flush;
	$self -> param('db') -> connector -> disconnect;
	$self -> param('logger') -> logger -> disconnect;

} # End of teardown.

# -----------------------------------------------

1;
