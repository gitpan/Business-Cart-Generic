#!/usr/bin/env perl

use strict;
use warnings;

use Business::Cart::Generic::Database::Loader;

# ----------------------------

Business::Cart::Generic::Database::Loader -> new -> populate_all_tables;
