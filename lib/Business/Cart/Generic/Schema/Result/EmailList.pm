package Business::Cart::Generic::Schema::Result::EmailList;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Business::Cart::Generic::Schema::Result::EmailList

=cut

__PACKAGE__->table("email_lists");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'email_lists_id_seq'

=head2 customer_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 email_address_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "email_lists_id_seq",
  },
  "customer_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "email_address_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 customer

Type: belongs_to

Related object: L<Business::Cart::Generic::Schema::Result::Customer>

=cut

__PACKAGE__->belongs_to(
  "customer",
  "Business::Cart::Generic::Schema::Result::Customer",
  { id => "customer_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 email_address

Type: belongs_to

Related object: L<Business::Cart::Generic::Schema::Result::EmailAddress>

=cut

__PACKAGE__->belongs_to(
  "email_address",
  "Business::Cart::Generic::Schema::Result::EmailAddress",
  { id => "email_address_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2011-04-10 14:05:48
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Wawj8lh/RCfcA4hvYkkwvg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
