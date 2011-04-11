package Business::Cart::Generic::Schema::Result::CustomerStatuse;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Business::Cart::Generic::Schema::Result::CustomerStatuse

=cut

__PACKAGE__->table("customer_statuses");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'customer_statuses_id_seq'

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
    sequence          => "customer_statuses_id_seq",
  },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "upper_name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 customers

Type: has_many

Related object: L<Business::Cart::Generic::Schema::Result::Customer>

=cut

__PACKAGE__->has_many(
  "customers",
  "Business::Cart::Generic::Schema::Result::Customer",
  { "foreign.customer_status_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2011-04-10 14:05:48
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:3caqVFHZ7tPyVgX5ebTFmQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
