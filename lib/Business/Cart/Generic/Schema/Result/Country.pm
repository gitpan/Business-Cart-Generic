package Business::Cart::Generic::Schema::Result::Country;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Business::Cart::Generic::Schema::Result::Country

=cut

__PACKAGE__->table("countries");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'countries_id_seq'

=head2 address_format

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 iso2_code

  data_type: 'char'
  is_nullable: 0
  size: 2

=head2 iso3_code

  data_type: 'char'
  is_nullable: 0
  size: 3

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 upper_name

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "countries_id_seq",
  },
  "address_format",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "iso2_code",
  { data_type => "char", is_nullable => 0, size => 2 },
  "iso3_code",
  { data_type => "char", is_nullable => 0, size => 3 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "upper_name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 street_addresses

Type: has_many

Related object: L<Business::Cart::Generic::Schema::Result::StreetAddress>

=cut

__PACKAGE__->has_many(
  "street_addresses",
  "Business::Cart::Generic::Schema::Result::StreetAddress",
  { "foreign.country_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 zones

Type: has_many

Related object: L<Business::Cart::Generic::Schema::Result::Zone>

=cut

__PACKAGE__->has_many(
  "zones",
  "Business::Cart::Generic::Schema::Result::Zone",
  { "foreign.country_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2011-04-10 14:05:48
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:3BwnQcksRc6yp+Ab/sgr8w


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
