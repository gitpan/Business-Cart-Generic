package Business::Cart::Generic;

our $VERSION = '0.81';

1;

=pod

=head1 NAME

L<Business::Cart::Generic> - Basic shopping cart. The GUI only supports searching for orders

=head1 Synopsis

Convert parts of L<osCommerce|http://www.oscommerce.com/> and L<PrestaShop|http://prestashop.com> into Perl.

=head1 Description

L<Business::Cart::Generic> implements parts of osCommerce and PrestaShop in Perl.

=over 4

=item o Placing orders

See scripts/place.orders.pl.

=item o Outputting orders as HTML files

See scripts/export.orders.as.html.pl.

=item o Outputting orders as HTML via the GUI

See httpd/cgi-bin/generic.cart.psgi and httpd/cgi-bin/generic.cart.cgi.

You can use the GUI to search for orders by order number.

=back

=head1 Distributions

This module is available as a Unix-style distro (*.tgz).

See L<http://savage.net.au/Perl-modules/html/installing-a-module.html>
for help on unpacking and installing distros.

=head1 Installation

=head2 The Module Itself

Install L<Business::Cart::Generic> as you would for any C<Perl> module:

Run:

	cpanm Business::Cart::Generic

or run:

	sudo cpan Business::Cart::Generic

or unpack the distro, and then either:

	perl Build.PL
	./Build
	./Build test
	sudo ./Build install

or:

	perl Makefile.PL
	make (or dmake or nmake)
	make test
	make install

=head2 The Configuration File

Next, tell L<Business::Cart::Generic> your values for some options.

For that, see config/.htbusiness.cart.generic.conf.

If you are using Build.PL, running Build (without parameters) will run scripts/copy.config.pl,
as explained next.

If you are using Makefile.PL, running make (without parameters) will also run scripts/copy.config.pl.

Either way, before editing the config file, ensure you run scripts/copy.config.pl. It will copy
the config file using L<File::HomeDir>, to a directory where the run-time code in
L<Business::Cart::Generic> will look for it.

	shell>cd Business-Cart-Generic-1.00
	shell>perl scripts/copy.config.pl

Under Debian, this directory will be $HOME/.perl/Benchmark-Featureset-LocaleCountry/. When you
run copy.config.pl, it will report where it has copied the config file to.

Check the docs for L<File::HomeDir> to see what your operating system returns for a
call to my_dist_config().

The point of this is that after the module is installed, the config file will be
easily accessible and editable without needing permission to write to the directory
structure in which modules are stored.

That's why L<File::HomeDir> and L<Path::Class> are pre-requisites for this module.

All modules which ship with their own config file are advised to use the same mechanism
for storing such files.

=head2 The Yahoo User Interface (YUI)

This module does not ship with YUI. You can get it from:
L<http://developer.yahoo.com/yui>.

All development was done using V 3.3.0.

With YUI3 you download just 1 file: yui-min.js, and install it somewhere under your
web server's docroot. Here's how I install it. How to configure your setup is explained below.

=over 4

=item o L<Debian|http://debian.org>'s RAM disk is /dev/shm/

=item o Under that, my docroot is /dev/shm/html/

=item o I install yui-min.js in /dev/shm/html/assets/js/yui3/

=item o The corresponding URL is /assets/js/yui3/yui-min.js

=item o Now for the templates shipped with this module

Copy them (recursively) to your docroot:

	shell>cd Business-Cart-Generic-1.00
	shell>cp -r htdocs/* /dev/shm/html

This creates /dev/shm/html/assets/css/ and /dev/shm/html/assets/templates/ (not assets/js/).

=back

=head2 Unobstrusive Javascript Validation

This module does not ship with validation code. You can get it from:
L<http://blog.jc21.com>.

=over 4

=item o validator.css

I installl this in /dev/shm/html/assets/css/validator/.

=item o validator.js

I installl this in /dev/shm/html/assets/js/validator/.

=back

=head2 The Interface between Business::Cart::Generic and YUI and the Validator

=over 4

=item o The interface to YUI

See htdocs/assets/templates/business/cart/generic/web.page.tx. It contains this line:

<script type="text/javascript" src="<: $yui_url :>/yui-min.js" charset="utf-8"></script>

The syntax	<: $var_name :> is used by L<Text::Xslate>.

The value for yui_url is specified in config/.htbusiness.cart.generic.conf (below).

=item o The interface to the validator

web.page.tx also contains:

<link rel="stylesheet" type="text/css" href="<: $validator_css_url :>/validator.css"> and

<script type="text/javascript" src="<: $validator_js_url :>/validator.js" charset="utf-8"></script>

The values for validator_css_url and validator_js_url are also in config/.htbusiness.cart.generic.conf.

=item o Configuration with .htbusiness.cart.generic.conf

All that remains is to tell L<Business::Cart::Generic> your values for yui_url, etc.

For that, see config/.htbusiness.cart.generic.conf, where it specifies the
URL used by the code to find YUI's JavaScript files.

But wait! Before editing that config file, run scripts/copy.config.pl. It will copy
the config file using L<File::HomeDir>, to a directory where the run-time code in
L<Business::Cart::Generic> will look for it.

	shell>cd Business-Cart-Generic-1.00
	shell>perl scripts/copy.config.pl

Under Debian, this directory will be $HOME/.perl/Business-Cart-Generic/. When you
run copy.config.pl, it will report where it has copied the config file to.

Check the docs for L<File::HomeDir> to see what your operating system returns for a
call to my_dist_config().

The point of this is that after the module is installed, the config file will be
easily accessible and editable without needing permission to write to the directory
structure in which modules are stored.

That's why L<File::HomeDir> and L<Path::Class> are pre-requisites for this module.

All modules which ship with their own config file are advised to use the same mechanism
for storing such files.

=back

Now you can edit various values in the config file before creating and populating any
database tables.

=head2 Creating the database

OK, here we go...

I assume you're using the default values (in .htbusiness.cart.generic.conf):

=over 4

=item o Database name: generic_cart

=item o Username: online

=item o Password: shopper

=back

If you use Postgres, do this to create the database:

	shell>psql -U postgres
	psql>create role online login password 'shopper';
	psql>create database generic_cart owner online encoding 'UTF8';
	psql>\q

Now, running scripts/create.tables.pl (next) will create the database.

=head2 Creating and populating the database tables

The distro contains a set of text files which are used to populate constant tables.
All such data is in the data/ directory.

This data is loaded into the database using programs in the distro.
All such programs are in the scripts/ directory.

After unpacking the distro, create and populate the database thus:

	shell>cd Business-Cart-Generic-1.00
	# Naturally, you only drop /pre-existing/ tables :-),
	# so use drop.tables.pl later, when re-building the db.
	shell>perl scripts/drop.tables.pl -v
	shell>perl scripts/create.tables.pl -v
	# If you change the schema, regenerate the DBIx::Class interface.
	shell>perl scripts/generate.schema.pl
	shell>perl scripts/populate.tables.pl -v

populate.tables.pl uses Business::Cart::Generic::Database::Import. This module only
populates tables which are independent of any manufacturer, product or customer.

Up to this point, there are no products in the database, which means orders can't be placed.

	shell>perl scripts/place.orders.pl

place.orders.pl uses Business::Cart::Generic::Database::Loader.

This tells you what you need to fabricate to place an order. This code has been
deliberately separated from Database::Import, since it (Loader) populates tables
which depend on specific manufacturers, products and customers.

Note: Loader deletes these tables: product_classes, product_colors, product_sizes,
product_styles and product_types, because they are only needed due to the nature of
the sample product data. This means the next time you run drop.tables.pl, expect
5 warning messages relating to these tables (since they have already been dropped).

=head2 Install the trivial CGI script and the Plack script

Copy the distro's httpd/cgi-bin/generic.cart.cgi to your web server's cgi-bin/
directory, and make it executable.

If I used Apache, my cgi-bin/ dir would be /usr/lib/cgi-bin/, so I would end up
with /usr/lib/cgi-bin/generic.cart.cgi.

Actually, I run nginx (Engine X) L<http://wiki.nginx.org/Main>, which does not serve
CGI scripts, and mini-httpd L<http://acme.com/software/>, which does.

=head2 Install the FAQ web page

This FAQ is for using the shopping cart CGI scripts, not for the module itself.

In .htbusiness.cart.generic.conf there is a line:

program_faq_url = /cart/generic.cart.faq.html

This page is displayed when the user clicks FAQ on the About tab.

A sample page is shipped in docs/html/generic.cart.faq.html. It has been built from
docs/pod/generic.cart.faq.pod (by running a script I wrote, pod2html.pl, which in turn
is a simple wrapper around L<Pod::Simple::HTML>).

So, copy the sample HTML file into cart/ under your web server's doc root, or generate another version
of the page, using docs/pod/generic.cart.faq.pod as input.

=head2 Start testing

Try:

	starman -l 127.0.0.1:5008 --workers 1 httpd/cgi-bin/office/cms.psgi &

Or, for good debug output:

	plackup -l 127.0.0.1:5008 httpd/cgi-bin/office/cms.psgi &

Or, install generic.cart.cgi and point your browser at:

	http://127.0.0.1/cgi-bin/generic.cart.cgi.

=head1 Constructor and Initialization

C<new()> is called as C<< my($builder) = Business::Cart::Generic -> new(k1 => v1, k2 => v2, ...) >>.

It returns a new object of type C<Business::Cart::Generic>.

Key-value pairs in accepted in the parameter list (see corresponding methods for details):

=over 4

=item o (None as yet)

=back

=head1 TODO

=over 4

=item o Customers

Only 2 dummy customers are included, in data/customers.csv.

See Business::Cart::Generic::Database::Loader.populate_customers_table().

=item o Discounts

Not implemented.

=item o Gifts

Not implemented.

=item o Invoices

Not implemented.

=item o Manufacturers

Only 1 dummy manufacturer is included, in data/manufacturers.csv.

See Business::Cart::Generic::Database::Loader.populate_manufacturers_table().

=item o Multiple indexes per database table

Not implemented.

=item o Orders and order history

Only some dummy orders are included, in data/orders.csv and data/order.items.csv.

See Business::Cart::Generic::Database::Loader.populate_orders_table(). This method
also fabricates some history for these orders.

=item o Payments

Not implemented.

=item o Stores

Not implemented.

=item o Weights and weight classes

Only dummy values are used so far.

See Business::Cart::Generic::Database::Imports.populate_products_table().

=item o Tax

Not implemented.

=item o TODO items

Search the source code tree for 'TODO' to see things which need to be cleaned up.

=back

=head1 FAQ

=over 4

=item o What is the main purpose of this module?

To store orders sent from another system. Hence the lack of a GUI (so far).

=item o What parts of osCommerce have you implemented?

The minimum required to store orders.

=item o What parts of PrestaShop have you implemented?

PrestaShop has influenced the database table design.

=item o What web interface are you using?

A home-grown one, written using L<YUI3|http://developer.yahoo.com/yui/3/>.

It is minimalistic.

=item o What L<Object-Relational Mapping|http://en.wikipedia.org/wiki/Object-relational_mapping>
(ORM) are you using?

L<DBIx::Class>.

=item o What templating system are you using?

L<Text::Xslate>.

=item o What is the database schema?

See L<generic.cart.png|http://savage.net.au/Perl-modules/generic.cart.png>, which was output by scripts/plot.schema.sh.

The code to create the tables is in L<Business::Cart::Generic::Database::Create>.

=item o How do I see how things work?

Trace the logic in script/place.orders.pl and scripts/export.orders.as.html.pl.

Once you've run place.orders.pl you can use this module's GUI to search for orders by order number.

=item o What is the point of all the clean_*() methods in L<Business::Cart::Generic::Database::Import>.

They transform files of constant data extracted from osCommerce, so the populate_*() methods
can import it.

=item o What do I need to be aware of?

Many things. Here is a tiny selection of them:

=over 4

=item o Customer addresses

For example, if a customer supplies a shipping address while placing an order, and later changes the address,
the question arises: To which address should the order be shipped? The new address? But what if the order
has already been printed using the old address?

This problem occurs in many situations, not just with addresses.

=item o Validation of credit card numbers

It makes most sense to just send the card number to the bank, even though osCommerce contains reg exps
(see the install dir) for checking the format (at least) of such numbers.

=item o The date_modified column

Various tables have a date_modified column, but there is no code which updates it.

=back

=back

=head1 Machine-Readable Change Log

The file CHANGES was converted into Changelog.ini by L<Module::Metadata::Changes>.

=head1 Version Numbers

Version numbers < 1.00 represent development versions. From 1.00 up, they are production versions.

=head1 Thanks

Many thanks are due to the people who chose to make osCommerce and PrestaShop, etc, Open Source.

=head1 Support

Email the author, or log a bug on RT:

L<https://rt.cpan.org/Public/Dist/Display.html?Name=Business::Cart::Generic>.

=head1 Author

L<Business::Cart::Generic> was written by Ron Savage I<E<lt>ron@savage.net.auE<gt>> in 2011.

Home page: L<http://savage.net.au/index.html>.

=head1 Copyright

Australian copyright (c) 2011, Ron Savage.

	All Programs of mine are 'OSI Certified Open Source Software';
	you can redistribute them and/or modify them under the terms of
	The Artistic License, a copy of which is available at:
	http://www.opensource.org/licenses/index.html

=cut
