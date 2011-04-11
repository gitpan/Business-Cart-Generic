package Business::Cart::Generic::Controller::Initialize;

use parent 'Business::Cart::Generic::Controller';
use strict;
use warnings;

use Text::Xslate 'mark_raw';

our $VERSION = '0.80';

# -----------------------------------------------

sub build_about_html
{
	my($self) = @_;

	$self -> log(debug => 'build_about_html()');

	my($config) = $self -> param('config');

	my(@tr);

	push @tr, {left => 'Program', right => "$$config{program_name} $$config{program_version}"};
	push @tr, {left => 'Author',  right => $$config{program_author} };
	push @tr, {left => 'Help',    right => mark_raw(qq|<a href="$$config{program_faq_url}">FAQ</a>|)};

	# Make YUI happy by turning the HTML into 1 long line.

	my($html) = $self -> param('templater') -> render('fancy.table.tx', {data => [@tr]});
	$html     =~ s/\n//g;

	return $html;

} # End of build_about_html.

# -----------------------------------------------

sub build_head_init
{
	my($self) = @_;

	$self -> log(debug => 'build_head_init()');

	my($about_html)  = $self -> build_about_html;
	my($add_html)    = $self -> param('view') -> add -> build_add_html;
	my($search_html) = $self -> param('view') -> search -> build_search_html;
	my($head_init)   = <<EJS;

YUI().use('node-base', 'tabview', function(Y)
{
	function init()
	{
		var tabview = new Y.TabView
			({
			  children:
				[
				 {
				   label:   'Search',
				   content: '$search_html'
				 },
				 {
				   label:   'Add',
				   content: 'Not implemented'
				 },
				 {
				   label:   'About',
				   content: '$about_html'
				 }
				]
			 });

		tabview.render('#tabview_container');
		tabview.on
			('selectionChange', function(e)
			 {
				 var label = e.newVal.get('label');

				 if (label === "Search")
				 {
					 make_search_number_focus();
				 }
				 else if (label === "Add")
				 {
					 make_add_name_focus();
				 }
			 }
			);
		make_search_number_focus();
		//prepare_add_form();
		prepare_search_form();
	}

	Y.on("domready", init);
});

EJS

	return $head_init;

} # End of build_head_init.

# -----------------------------------------------

sub build_head_js
{
	my($self) = @_;

	$self -> log(debug => 'build_head_js()');

	my($view_js) =
#		$self -> param('view') -> add -> build_head_js .
		$self -> param('view') -> search -> build_head_js;

	# These things are being declared within the web page's head.

	my($js) = <<EJS;
// Code in head of web page.

$view_js

function make_search_number_focus(eve)
{
	document.search_form.search_number.focus();
}

function make_add_name_focus(eve)
{
	//document.add_form.add_name.focus();
}

EJS

	return $js;

} # End of build_head_js.

# -----------------------------------------------

sub display
{
	my($self) = @_;

	$self -> log(debug => 'display()');

	# Generate the web page itself. This is not loaded by sub cgiapp_init(),
	# because, with AJAX, we only need it the first time the script is run.

	my($config) = $self -> param('config');
	my($param)  =
	{
	 css_url           => $$config{css_url},
	 head_js           => mark_raw($self -> build_head_js . $self -> build_head_init),
	 validator_css_url => $$config{validator_css_url},
	 validator_js_url  => $$config{validator_js_url},
	 yui_url           => $$config{yui_url},
	};

	return $self -> param('templater') -> render('web.page.tx', $param);

} # End of display.

# -----------------------------------------------

1;
