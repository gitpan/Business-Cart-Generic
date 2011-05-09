package Business::Cart::Generic::Schema::Result::Manufacturer;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Business::Cart::Generic::Schema::Result::Manufacturer

=cut

__PACKAGE__->table("manufacturers");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'manufacturers_id_seq'

=head2 date_added

  data_type: 'timestamp'
  is_nullable: 0

=head2 date_modified

  data_type: 'timestamp'
  is_nullable: 0

=head2 image

  data_type: 'varchar'
  is_nullable: 0
  size: 255

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
    sequence          => "manufacturers_id_seq",
  },
  "date_added",
  { data_type => "timestamp", is_nullable => 0 },
  "date_modified",
  { data_type => "timestamp", is_nullable => 0 },
  "image",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "upper_name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 manufacturers_infos

Type: has_many

Related object: L<Business::Cart::Generic::Schema::Result::ManufacturersInfo>

=cut

__PACKAGE__->has_many(
  "manufacturers_infos",
  "Business::Cart::Generic::Schema::Result::ManufacturersInfo",
  { "foreign.manufacturer_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 products

Type: has_many

Related object: L<Business::Cart::Generic::Schema::Result::Product>

=cut

__PACKAGE__->has_many(
  "products",
  "Business::Cart::Generic::Schema::Result::Product",
  { "foreign.manufacturer_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2011-05-09 11:58:48
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ixnx5fkBWJU3MPklNPDlHw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
