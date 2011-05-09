#!/usr/bin/env perl

use strict;
use warnings;

use Locale::SubCountry;

# ---------------------

my($world)   = Locale::SubCountry::World -> new;
my(%country) = $world -> code_full_name_hash;
my($id)      = 0;

for my $code (sort keys %country)
{
	$id++;

	print "$id => $code => $country{$code}\n";
}

my($oz)   = Locale::SubCountry -> new('Australia');
my(%zone) = $oz -> code_full_name_hash;
$id       = 0;

for my $code (sort keys %zone)
{
	$id++;

	print "$id => $code => $zone{$code}\n";
}

