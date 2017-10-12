package kshisa::Schema::Result::User;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

kshisa::Schema::Result::User

=cut

use strict;
use warnings;
use utf8;
use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<users>

=cut

__PACKAGE__->table("users");

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0, size => 5 },
  "username",
  { data_type => "varchar", is_nullable => 0, size => 15 }, 
 "password",
  { data_type => "varchar", is_nullable => 0, size => 15 },
 "email",
  { data_type => "varchar", is_nullable => 0, size => 45 },
 "avatar",
  { data_type => "varchar", is_nullable => 0, size => 15 },
  "status",
  { data_type => "varchar", is_nullable => 0, size => 5 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("password", ["password"]);

# Created by DBIx::Class::Schema::Loader v0.07043 @ 2016-02-09 10:04:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:oP9rg8zKFIvtWY/2OSJBnQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
