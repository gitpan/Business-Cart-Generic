package Business::Cart::Generic::Base;

use Business::Cart::Generic::Util::Config;
use Business::Cart::Generic::Util::Logger;

use DBIx::Connector;

use Moose;

has config =>
(
 default  => sub{ return Business::Cart::Generic::Util::Config -> new -> config },
 is       => 'rw',
 isa      => 'HashRef',
 required => 0,
);

has connector =>
(
 is  => 'rw',
 isa => 'Any',
 required => 0,
);

has logger =>
(
 is       => 'rw',
 isa      => 'Business::Cart::Generic::Util::Logger',
 required => 0,
);

use namespace::autoclean;

our $VERSION = '0.80';

# -----------------------------------------------

sub BUILD
{
	my($self)   = @_;
	my($config) = $self -> config;
	my($attr)   = {AutoCommit => $$config{AutoCommit}, RaiseError => $$config{RaiseError} };

	if ( ($$config{dsn} =~ /SQLite/i) && $$config{sqlite_unicode})
	{
		$$attr{sqlite_unicode} = 1;
	}

	$self -> connector
		(
		 DBIx::Connector -> new($$config{dsn}, $$config{username}, $$config{password}, $attr)
		);

	if ($$config{dsn} =~ /SQLite/i)
	{
		$self -> connector -> dbh -> do('PRAGMA foreign_keys = ON');
	}

	$self -> logger
		(
		 Business::Cart::Generic::Util::Logger -> new(config => $config)
		);

} # End of BUILD.

# -----------------------------------------------

__PACKAGE__ -> meta -> make_immutable;

1;
