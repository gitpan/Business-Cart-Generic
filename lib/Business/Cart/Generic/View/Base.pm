package Business::Cart::Generic::View::Base;

use strict;
use warnings;

use Moose;

use Text::Xslate 'mark_raw';

extends 'Business::Cart::Generic::Database::Base';

has config =>
(
 is       => 'ro',
 isa      => 'HashRef',
 required => 1,
);

has templater =>
(
 is       => 'ro',
 isa      => 'Text::Xslate',
 required => 1,
);

use namespace::autoclean;

our $VERSION = '0.82';

# -----------------------------------------------

sub build_select
{
	my($self, $class_name, $default, $id_name, $column_list, $onchange) = @_;

	$self -> db -> logger -> log(debug => "build_select($class_name, $default)");

	$default     ||= 1;
	$id_name     ||= lc "${class_name}_id";
	$onchange    = $onchange ? qq|onchange="$onchange"| : '';
	$column_list ||= ['name'];
	my($option)  = $self -> db -> get_id2name_map($class_name, $column_list);

	return $self -> templater -> render
	(
	 'select.tx',
	 {
		 name     => $id_name,
		 onchange => mark_raw($onchange),
		 loop     =>
			 [map
				  {
					  {
						  default => $_ == $default ? 1 : 0,
						  name    => $$option{$_},
						  value   => $_,
					  };
				  } sort{$$option{$a} cmp $$option{$b} } keys %$option
			 ],
	 }
	);

} # End of build_select.

# -----------------------------------------------

sub build_special_select
{
	my($self, $map, $default, $id_name) = @_;

	$self -> db -> logger -> log(debug => 'build_special_select()');

	return $self -> templater -> render
	(
	 'select.tx',
	 {
		 name => $id_name,
		 loop =>
			 [map
				  {
					  {
						  default => $_ == $default ? 1 : 0,
						  name    => mark_raw($$map{$_}),
						  value   => $_,
					  };
				  } sort{$$map{$a} cmp $$map{$b} } keys %$map
			 ],
	 }
	);

} # End of build_special_select.

# -----------------------------------------------

sub format_errors
{
	my($self, $error) = @_;
	my($param) =
	{
		data => [],
	};

	my($s);

	for my $key (sort keys %$error)
	{
		$s = "$key: " . join(', ', @{$$error{$key} });

		push @{$$param{data} }, {td => mark_raw($s)};

		$self -> db -> logger -> log(debug => "Error. $s");
	}

	my($output) =
	{
		div     => 'order_message_div',
		content => $self -> templater -> render('error.tx', $param),
	};

	return JSON::XS -> new -> utf8 -> encode($output);

} # End of format_errors.

# -----------------------------------------------

sub format_note
{
	my($self, $error) = @_;
	my($param) =
	{
		data => [],
	};

	my($s);

	for my $key (sort keys %$error)
	{
		$s = "$key: " . join(', ', @{$$error{$key} });

		push @{$$param{data} }, {td => mark_raw($s)};

		$self -> db -> logger -> log(debug => "Error. $s");
	}

	my($output) =
	{
		div     => 'order_message_div',
		content => $self -> templater -> render('note.tx', $param),
	};

	return JSON::XS -> new -> utf8 -> encode($output);

} # End of format_note.

# -----------------------------------------------

__PACKAGE__ -> meta -> make_immutable;

1;
