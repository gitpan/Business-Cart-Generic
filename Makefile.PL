use ExtUtils::MakeMaker;

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

WriteMakefile
(
 ($] ge '5.005') ?
 (
  AUTHOR   => 'Ron Savage (ron@savage.net.au)',
  ABSTRACT => 'Basic shopping cart. So far, the GUI only supports searching for orders',
    ) : (),
 clean =>
 {
	 FILES => 'blib/* Makefile MANIFEST Business-Cart-Generic-*'
 },
 dist =>
 {
	 COMPRESS => 'gzip',
	 SUFFIX   => 'gz'
 },
 DISTNAME  => 'Business-Cart-Generic',
 NAME      => 'Business::Cart::Generic',
 PL_FILES  => {},
 PREREQ_PM =>
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
 	 File::HomeDir               => 0.97,
	 FindBin                     => 1.50,
	 IO::File                    => 1.14,
	 IO::Scalar                  => 2.110,
 	 JSON::XS                    => 2.3,
	 Lingua::EN::Inflect::Number => 1.1,
 	 Log::Handler::Output::DBI   => 0.11,
 	 Moose                       => 0.98,
 	 namespace::autoclean        => 0.09,
 	 parent                      => 0.224,
 	 Path::Class                 => 0.23,
	 Perl6::Slurp                => 0.03,
	 Test::More                  => 0.94,
	 Test::Pod                   => 1.44,
	 Text::CSV_XS                => 0.80,
 	 Text::Xslate                => 1.0007,
 },
 VERSION_FROM => 'lib/Business/Cart/Generic.pm',
);
