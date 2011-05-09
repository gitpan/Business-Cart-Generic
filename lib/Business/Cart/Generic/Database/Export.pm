package Business::Cart::Generic::Database::Export;

use strict;
use warnings;

use CGI;

use Business::Cart::Generic::Database;
use Business::Cart::Generic::View;

use Moose;

use Path::Class; # For file().

use Text::CSV_XS;
use Text::Xslate 'mark_raw';

extends 'Business::Cart::Generic::Database::Base';

has db =>
(
 is       => 'rw',
 isa      => 'Business::Cart::Generic::Database',
 required => 0,
);

has view =>
(
 is       => 'rw',
 isa      => 'Business::Cart::Generic::View',
 required => 0,
);

has tx =>
(
 is       => 'rw',
 isa      => 'Text::Xslate',
 required => 0,
);

use namespace::autoclean;

our $VERSION = '0.82';

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

	$self -> tx
		(
		 Text::Xslate -> new
		 (
		  input_layer => '',
		  path        => ${$self -> config}{template_path},
		  )
		);

	$self -> view
		(
		 Business::Cart::Generic::View -> new
		 (
		  db        => $self -> db,
		  templater => $self -> tx,
		 )
		);

}	# End of BUILD.

# -----------------------------------------------

sub orders_as_html
{
	my($self)       = @_;
	my($config)     = $self -> config;
	my($order_path) = $$config{order_html_path};
	my($order_url)  = $$config{order_html_url};

	my($id);
	my(%page_name, $page_name);

	for my $order (@{$self -> read_orders_table})
	{
		$id             = $$order{id};
		$page_name{$id} = "order.$id.html";
		$page_name      = file($order_path, $page_name{$id});

		open(OUT, '>', $page_name) || die "Can't open($page_name): $!";
		print OUT $self -> tx -> render
			(
			 'export.order.page.tx',
			 {
				 border => 0,
				 id     => $id,
				 row    => $self -> view -> order -> format_search_order($order),
			 }
			);
		close OUT;

		print "Saved $page_name. \n";
	}

	$page_name{0} = file($order_path, "orders.html");

	open(OUT, '>', $page_name{0}) || die "Can't open($page_name{0}): $!";
	print OUT $self -> tx -> render
		(
		 'export.order.index.page.tx',
		 {
			 borders => 1,
			 css_url => $$config{css_url},
			 row     => [map{[{td => mark_raw(qq|<a href="$order_url/$page_name{$_}">Order # $_</a>|)}]} sort grep{! /^0$/} keys %page_name],
		 }
		);
	close OUT;

	print "Saved $page_name{0}. \n";

} # End of orders_as_html.

# -----------------------------------------------

sub products_as_html
{
	my($self)       = @_;
	my($config)     = $self -> config;
	my($order_path) = $$config{order_html_path};
	my($order_url)  = $$config{order_html_url};
	my($page_name)  = file($order_path, 'products.html');

	open(OUT, '>', $page_name) || die "Can't open($page_name): $!";
	print OUT $self -> tx -> render
		(
		 'basic.table.tx',
		 {
			 border => 1,
			 row    => $self -> view -> product -> format_products($self -> read_products_table),
		 }
		);
	close OUT;

	print "Saved $page_name. \n";

} # End of products_as_html.

# -----------------------------------------------

sub read_orders_table
{
	my($self)     = @_;
	my $order_set = $self -> db -> order -> get_orders;

	my(@order);

	while (my $order = $order_set -> next)
	{
		push @order, $self -> db -> order -> inflate_order($order);
	}

	return [@order];

} # End of read_orders_table.

# -----------------------------------------------

sub read_products_table
{
	my($self)       = @_;
	my $product_set = $self -> db -> product -> get_products;

	my(@product);

	while (my $product = $product_set -> next)
	{
		push @product, $self -> db -> product -> inflate_product($product);
	}

	return [@product];

} # End of read_products_table.

# -----------------------------------------------

__PACKAGE__ -> meta -> make_immutable;

1;
