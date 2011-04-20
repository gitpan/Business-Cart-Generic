use Module::Build;

my $class = Module::Build->subclass(code => <<'EOF');

sub ACTION_build
{
	my $self = shift;
	$self->SUPER::ACTION_build(@_);
	$self->run_perl_script('scripts/copy.config.pl');
}
EOF

$class -> new
(
 module_name    => 'Business::Cart::Generic',
 license        => 'artistic',
 dist_abstract  => 'Basic shopping cart. So far, the GUI only supports searching for orders',
 dist_author    => 'Ron Savage <ron@savage.net.au>',
 build_requires =>
 {
 	 Test::More => 0.94,
 	 Test::Pod  => 1.44,
 },
 configure_requires =>
 {
 	 Module::Build => 0.3800,
 },
 requires =>
 {
 	 CGI                         => 3.52,
 	 CGI::Application            => 4.31,
 	 Config::Tiny                => 2.13,
 	 Data::Session               => 1.03,
	 Date::Simple                => 3.03,
 	 DBIx::Admin::CreateTable    => 2.07,
 	 DBIx::Class                 => 0.08121,
 	 DBIx::Class::Schema::Loader => 0.06001,
 	 DBIx::Connector             => 0.42,
	 File::Copy                  => 2.18,
 	 File::HomeDir               => 0.97,
	 FindBin                     => 1.50,
	 IO::File                    => 1.14,
 	 JSON::XS                    => 2.3,
	 Lingua::EN::Inflect::Number => 1.1,
 	 Log::Handler::Output::DBI   => 0.11,
 	 Moose                       => 0.98,
 	 namespace::autoclean        => 0.09,
 	 parent                      => 0.224,
 	 Path::Class                 => 0.23,
	 Perl6::Slurp                => 0.03,
	 Text::CSV_XS                => 0.80,
 	 Text::Xslate                => 1.0007,
 },
) -> create_build_script();
