package Business::Cart::Generic::Database::Import;

use strict;
use warnings;

use CGI;

use FindBin;

use Business::Cart::Generic::Database;

use IO::File;

use Moose;

use Perl6::Slurp;

use Text::CSV_XS;
use Text::Xslate;

use Try::Tiny;

extends 'Business::Cart::Generic::Database::Base';

use namespace::autoclean;

our $VERSION = '0.81';

# -----------------------------------------------

sub BUILD
{
	my($self) = @_;

	$self -> db
		(
		 Business::Cart::Generic::Database -> new
		 (
		  query => CGI -> new,
		 )
		);

}	# End of BUILD.

# -----------------------------------------------

sub clean_all_data
{
	my($self) = @_;

	$self -> clean_country_data;
	$self -> clean_zone_data;
	$self -> clean_currency_data;
	$self -> clean_language_data;
	$self -> clean_order_statuses_data;

} # End of clean_all_data.

# -----------------------------------------------

sub clean_country_data
{
	my($self)          = @_;
	my($input_path)    = "$FindBin::Bin/../data/raw.countries.txt";
	my(@original_data) = slurp($input_path, {chomp => 1});

	my(@field);
	my($line);
	my(@raw_data);

	push @raw_data, '"name","iso2","iso3","address_format"';

	for $line (@original_data)
	{
		# Expected format:
		# INSERT INTO osc_countries VALUES (1,'Afghanistan','AF','AFG','');
		# INSERT INTO osc_countries VALUES (52,'Cote D\'Ivoire','CI','CIV','');

		$line     = substr($line, 0, - 2); # Discard );.
		@field    = split(/\s*,\s*/, $line, 2);
		$field[1] =~ s/\\n/#/g; # Inside address_format.
		$field[1] =~ s/\\'/!/;  # 'Cote D\'Ivoire'.
		$field[1] =~ tr/'/"/;   # For Text::CSV_XS.
		$field[1] =~ s/!/'/;    # 'Cote D\'Ivoire'.

		push @raw_data, $field[1];
	}

	my($output_path) = "$FindBin::Bin/../data/countries.csv";

	open(OUT, '>', $output_path) || die "Can't open($output_path): $!";

	my($csv) = Text::CSV_XS -> new({allow_whitespace => 1});

	my($status);
	my(%target);

	while ($line = shift @raw_data)
	{
		$status = $csv -> parse($line) || die "Can't parse $line";
		@field  = $csv -> fields;

		print OUT '"', join('","', @field), qq|"\n|;
	}

	close OUT;

} # End of clean_country_data.

# -----------------------------------------------

sub clean_currency_data
{
	my($self)          = @_;
	my($input_path)    = "$FindBin::Bin/../data/raw.currencies.txt";
	my(@original_data) = slurp($input_path, {chomp => 1});

	my(@field);
	my($line);
	my(@raw_data);

	push @raw_data, '"name","code","symbol_left","symbol_right","decimal_places"';

	for $line (@original_data)
	{
		# Expected format:
		# INSERT INTO osc_currencies VALUES (4,'Australian Dollar','AUD','$','','2','1.000', now());

		$line     = substr($line, 0, - 2); # Discard );.
		@field    = split(/VALUES \(/, $line);
		$field[1] =~ tr/'/"/;   # For Text::CSV_XS.
		@field    = split(/\s*,\s*/, $field[1]);

		push @raw_data, join(',', @field[1 .. 5]);
	}

	my($output_path) = "$FindBin::Bin/../data/currencies.csv";

	open(OUT, '>', $output_path) || die "Can't open($output_path): $!";

	my($csv) = Text::CSV_XS -> new({allow_whitespace => 1, binary => 1});

	my($status);
	my(%target);

	while ($line = shift @raw_data)
	{
		$status = $csv -> parse($line) || die "Can't parse $line";
		@field  = $csv -> fields;

		print OUT '"', join('","', @field), qq|"\n|;
	}

	close OUT;

} # End of clean_currency_data.

# -----------------------------------------------

sub clean_language_data
{
	my($self)          = @_;
	my($input_path)    = "$FindBin::Bin/../data/raw.languages.txt";
	my(@original_data) = slurp($input_path, {chomp => 1});

	my(@field);
	my($line);
	my(@raw_data);

	push @raw_data, '"name","code","locale","charset","date_format_short","date_format_long","time_format","text_direction","currency_id","numeric_separator_decimal","numeric_separator_thousands"';

	for $line (@original_data)
	{
		# Expected format:
		# INSERT INTO osc_languages VALUES (2,'English','en_AU','en_AU.UTF-8,en_AU,english','utf-8','%d/%m/%Y','%A %d %B, %Y','%H:%M:%S','ltr',1,'.',',',0,1);

		$line  = substr($line, 0, - 2); # Discard );.
		@field = split(/VALUES \(/, $line);
		$field[1]  =~ s/,(en_(?:AU|US)),/#$1#/; # locale.
		$field[1]  =~ s/B,/B#/;                 # date_format_long.
		$field[1]  =~ s/'.',',',/'.','#',/;     # numeric_separator_thousands.
		$field[1]  =~ tr/'/"/;   # For Text::CSV_XS.
		@field     = split(/\s*,\s*/, $field[1]);
		$field[3]  =~ s/#/,/g; # locale.
		$field[6]  =~ s/#/,/;  # date_format_long.
		$field[11] =~ s/#/,/;  # numeric_separator_thousands.

		push @raw_data, join(',', @field[1 .. 11]);
	}

	my($output_path) = "$FindBin::Bin/../data/languages.csv";

	open(OUT, '>', $output_path) || die "Can't open($output_path): $!";

	my($csv) = Text::CSV_XS -> new({allow_whitespace => 1});

	my($status);
	my(%target);

	while ($line = shift @raw_data)
	{
		$status = $csv -> parse($line) || die "Can't parse $line";
		@field  = $csv -> fields;

		print OUT '"', join('","', @field), qq|"\n|;
	}

	close OUT;

} # End of clean_language_data.

# -----------------------------------------------

sub clean_order_statuses_data
{
	my($self)          = @_;
	my($input_path)    = "$FindBin::Bin/../data/raw.order.statuses.txt";
	my(@original_data) = slurp($input_path, {chomp => 1});

	my(@field);
	my($line);
	my(@raw_data);

	push @raw_data, '"language_id","name"';

	for $line (@original_data)
	{
		# Expected format:
		# INSERT INTO osc_orders_status VALUES ( '1', '4', 'Pending');

		$line     = substr($line, 0, - 2); # Discard );.
		@field    = split(/VALUES \(/, $line);
		$field[1] =~ tr/'/"/;   # For Text::CSV_XS.
		@field    = split(/\s*,\s*/, $field[1]);

		push @raw_data, join(',', @field[1 .. 2]);
	}

	my($output_path) = "$FindBin::Bin/../data/order.statuses.csv";

	open(OUT, '>', $output_path) || die "Can't open($output_path): $!";

	my($csv) = Text::CSV_XS -> new({allow_whitespace => 1});

	my($status);
	my(%target);

	while ($line = shift @raw_data)
	{
		$status = $csv -> parse($line) || die "Can't parse $line";
		@field  = $csv -> fields;

		print OUT '"', join('","', @field), qq|"\n|;
	}

	close OUT;

} # End of clean_order_statuses_data.

# -----------------------------------------------

sub clean_zone_data
{
	my($self)          = @_;
	my($input_path)    = "$FindBin::Bin/../data/raw.zones.txt";
	my(@original_data) = slurp($input_path, {chomp => 1});

	my(@field);
	my($line);
	my(@raw_data);

	push @raw_data, '"country_id","code","name"';

	for $line (@original_data)
	{
		# Expected format:
		# INSERT INTO osc_zones (zone_country_id, zone_code, zone_name) VALUES (1,'BDS','بد خشان');
		# INSERT INTO osc_zones (zone_country_id, zone_code, zone_name) VALUES (4,'MA','Manu\'a');

		$line     = substr($line, 0, - 2); # Discard );.
		@field    = split(/VALUES \(/, $line);
		$field[1] =~ s/\\'/!/; # 'Manu\a'.
		@field    = split(/\s*,\s*/, $field[1]);
		$field[1] =~ tr/'/"/;  # For Text::CSV_XS.
		$field[1] =~ s/!/'/;   # 'Manu\a'.
		$field[2] =~ tr/'/"/;  # For Text::CSV_XS.
		$field[2] =~ s/!/'/;   # 'Manu\a'.

		push @raw_data, join(',', @field[0 .. 2]);
	}

	my($output_path) = "$FindBin::Bin/../data/zones.csv";

	open(OUT, '>', $output_path) || die "Can't open($output_path): $!";

	my($csv) = Text::CSV_XS -> new({allow_whitespace => 1, binary => 1});

	my($status);
	my(%target);

	while ($line = shift @raw_data)
	{
		$status = $csv -> parse($line) || die "Can't parse $line";
		@field  = $csv -> fields;

		print OUT '"', join('","', @field), qq|"\n|;
	}

	close OUT;

} # End of clean_zone_data.

# -----------------------------------------------

sub populate_all_tables
{
	my($self) = @_;

	$self -> connector -> txn
		(
		 fixup => sub{ $self -> populate_tables }, catch{ defined $_ ? die $_ : ''}
		);

}	# End of populate_all_tables.

# -----------------------------------------------

sub populate_tables
{
	my($self) = @_;

	$self -> populate_countries_table;
	$self -> populate_zones_table;
	$self -> populate_currencies_table;
	$self -> populate_languages_table;
	$self -> populate_order_statuses_table;
	$self -> populate_tax_classes_table;
	$self -> populate_weight_classes_table;
	$self -> populate_weight_class_rules_table;
	$self -> populate_table('yes.no.csv', 'YesNo');
	$self -> populate_table('payment.methods.csv', 'PaymentMethod');
	$self -> populate_table('customer.statuses.csv', 'CustomerStatuse');
	$self -> populate_table('customer.types.csv', 'CustomerType');
	$self -> populate_table('genders.csv', 'Gender');
	$self -> populate_table('email.address.types.csv', 'EmailAddressType');
	$self -> populate_table('phone.number.types.csv', 'PhoneNumberType');
	$self -> populate_table('titles.csv', 'Title');

}	# End of populate_tables.

# -----------------------------------------------

sub populate_countries_table
{
	my($self)    = @_;
	my($path)    = "$FindBin::Bin/../data/countries.csv";
	my($country) = $self -> read_csv_file($path);
	my($rs)      = $self -> schema -> resultset('Country');

	my($result);

	for my $line (@$country)
	{
		$result = $rs -> create
			({
			 address_format => $$line{address_format},
			 iso2_code      => $$line{iso2},
			 iso3_code      => $$line{iso3},
			 name           => $$line{name},
			 upper_name     => uc $$line{name},
			});
	}

} # End of populate_countries_table.

# -----------------------------------------------

sub populate_currencies_table
{
	my($self) = @_;
	my($path) = "$FindBin::Bin/../data/currencies.csv";
	my($zone) = $self -> read_csv_file($path);
	my($rs)   = $self -> schema -> resultset('Currency');

	my($result);

	for my $line (@$zone)
	{
		$result = $rs -> create
			({
			 code           => $$line{code},
			 decimal_places => $$line{decimal_places},
			 name           => $$line{name},
			 symbol_left    => $$line{symbol_left},
			 symbol_right   => $$line{symbol_right},
			 upper_name     => uc $$line{name},
			});
	}

} # End of populate_currencies_table.

# -----------------------------------------------

sub populate_languages_table
{
	my($self) = @_;
	my($path) = "$FindBin::Bin/../data/languages.csv";
	my($zone) = $self -> read_csv_file($path);
	my($rs)   = $self -> schema -> resultset('Language');

	my($result);

	for my $line (@$zone)
	{
		$result = $rs -> create
			({
			 charset                     => $$line{charset},
			 code                        => $$line{code},
			 currency_id                 => $$line{currency_id},
			 date_format_long            => $$line{date_format_long},
			 date_format_short           => $$line{date_format_long},
			 locale                      => $$line{locale},
			 name                        => $$line{name},
			 numeric_separator_decimal   => $$line{numeric_separator_decimal},
			 numeric_separator_thousands => $$line{numeric_separator_thousands},
			 text_direction              => $$line{text_direction},
			 time_format                 => $$line{time_format},
			 upper_name                  => uc $$line{name},
			});
	}

} # End of populate_languages_table.

# -----------------------------------------------

sub populate_order_statuses_table
{
	my($self)        = @_;
	my($path)        = "$FindBin::Bin/../data/order.statuses.csv";
	my($zone)        = $self -> read_csv_file($path);
	my($rs)          = $self -> schema -> resultset('OrderStatuse');
	my(@language2id) = $self -> schema -> resultset('Language') -> search({}, {columns => [qw/code id/]});
	my(%language2id) = map{($_ -> code, $_ -> id)} @language2id;

	my($language_id);
	my($result);

	for my $line (@$zone)
	{
		$language_id = $language2id{$$line{language} } || die "Unknown language: $$line{language}";
		$result      = $rs -> create
			({
			 language_id => $language_id,
			 name        => $$line{name},
			 upper_name  => uc $$line{name},
			});
	}

} # End of populate_order_statuses_table.

# -----------------------------------------------

sub populate_table
{
	my($self, $file_name, $class_name) = @_;
	my($path) = "$FindBin::Bin/../data/$file_name";
	my($data) = $self -> read_csv_file($path);
	my($rs)   = $self -> schema -> resultset($class_name);

	my($result);

	for my $line (@$data)
	{
		$result = $rs -> create
			({
			 name       => $$line{name},
			 upper_name => uc $$line{name},
			});
	}

} # End of populate_table.

# -----------------------------------------------

sub populate_tax_classes_table
{
	my($self) = @_;
	my($path) = "$FindBin::Bin/../data/tax.classes.csv";
	my($data) = $self -> read_csv_file($path);
	my($rs)   = $self -> schema -> resultset('TaxClass');

	my($result);

	for my $line (@$data)
	{
		$result = $rs -> create
			(
			 {
				 date_added    => \'now()',
				 date_modified => \'now()',
				 description   => $$line{description},
				 name          => $$line{name},
				 upper_name    => uc $$line{name},
			 }
			);
	}

} # End of populate_tax_classes_table.

# -----------------------------------------------

sub populate_weight_class_rules_table
{
	my($self)     = @_;
	my($path)     = "$FindBin::Bin/../data/weight.class.rules.csv";
	my($data)     = $self -> read_csv_file($path);
	my($rs)       = $self -> schema -> resultset('WeightClassRule');
	my(@class2id) = $self -> schema -> resultset('WeightClass') -> search({}, {columns => [qw/key id/]});
	my(%class2id) = map{($_ -> key, $_ -> id)} @class2id;

	my($from_id);
	my($result);
	my($to_id);

	for my $line (@$data)
	{
		$from_id = $class2id{$$line{from} } || die "Unknown weight class: $$line{from}";
		$to_id   = $class2id{$$line{to} }   || die "Unknown weight class: $$line{to}";
		$result  = $rs -> create
			(
			 {
				 from_id => $from_id,
				 to_id   => $to_id,
				 rule    => $$line{rule},
			 }
			);
	}

} # End of populate_weight_class_rules_table.

# -----------------------------------------------

sub populate_weight_classes_table
{
	my($self)        = @_;
	my($path)        = "$FindBin::Bin/../data/weight.classes.csv";
	my($data)        = $self -> read_csv_file($path);
	my($rs)          = $self -> schema -> resultset('WeightClass');
	my(@language2id) = $self -> schema -> resultset('Language') -> search({}, {columns => [qw/code id/]});
	my(%language2id) = map{($_ -> code, $_ -> id)} @language2id;

	my($language_id);
	my($result);

	for my $line (@$data)
	{
		$language_id = $language2id{$$line{language} } || die "Unknown language: $$line{language}";
		$result      = $rs -> create
			(
			 {
				 language_id => $language_id,
				 key         => $$line{key},
				 name        => $$line{name},
				 upper_name  => uc $$line{name},
			 }
			);
	}

} # End of populate_weight_classes_table.

# -----------------------------------------------

sub populate_zones_table
{
	my($self) = @_;
	my($path) = "$FindBin::Bin/../data/zones.csv";
	my($zone) = $self -> read_csv_file($path);
	my($rs)   = $self -> schema -> resultset('Zone');

	my($result);

	for my $line (@$zone)
	{
		$result = $rs -> create
			({
			 code       => $$line{code},
			 country_id => $$line{country_id},
			 name       => $$line{name},
			 upper_name => uc $$line{name},
			});
	}

} # End of populate_zones_table.

# -----------------------------------------------

sub read_csv_file
{
	my($self, $file_name) = @_;
	my($csv) = Text::CSV_XS -> new({binary => 1});
	my($io)  = IO::File -> new($file_name, 'r');

	$csv -> column_names($csv -> getline($io) );

	return $csv -> getline_hr_all($io);

} # End of read_csv_file.

# -----------------------------------------------

__PACKAGE__ -> meta -> make_immutable;

1;
