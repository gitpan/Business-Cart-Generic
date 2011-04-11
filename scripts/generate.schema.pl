#!/usr/bin/env perl

use strict;
use warnings;

use DBIx::Class::Schema::Loader 'make_schema_at';

use Business::Cart::Generic::Util::Config;

# -----------------------------------------------

my($config) = Business::Cart::Generic::Util::Config -> new -> config;

make_schema_at
(
	'Business::Cart::Generic::Schema',
	{
		dump_directory => './lib',
	},
	[
		$$config{dsn}, $$config{username}, $$config{password},
	],
);
