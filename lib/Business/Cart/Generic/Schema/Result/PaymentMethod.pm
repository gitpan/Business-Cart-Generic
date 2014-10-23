package Business::Cart::Generic::Schema::Result::PaymentMethod;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Business::Cart::Generic::Schema::Result::PaymentMethod

=cut

__PACKAGE__->table("payment_methods");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'payment_methods_id_seq'

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
    sequence          => "payment_methods_id_seq",
  },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "upper_name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 orders

Type: has_many

Related object: L<Business::Cart::Generic::Schema::Result::Order>

=cut

__PACKAGE__->has_many(
  "orders",
  "Business::Cart::Generic::Schema::Result::Order",
  { "foreign.payment_method_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2011-04-10 14:05:48
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:7MoVRAXWA+AbeDfsFPGbzQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
