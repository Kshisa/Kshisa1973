package kshisa::Model::Yaml;
use Moose;
use namespace::autoclean;

extends 'Catalyst::Model';

use utf8;
use YAML::Any qw(LoadFile DumpFile);

sub tempIn {
    my ($self, $cols0, $cols, $img_path1) = @_;
    my $path = $img_path1.'temp.yaml';
    %$cols0{$_} foreach @$cols;
    my $mediainfo = {%$cols0};
    DumpFile($path, $mediainfo);
}
sub tempOut {
    my ($self, $cols, $img_path1) = @_;
    my %cols;
    my $path = $img_path1.'temp.yaml';
    my ($ds) = LoadFile($path);
    $cols{$_} = $ds->{$_} foreach @$cols;
    return %cols;
}
=head1 NAME

kshisa::Model::Yaml - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.


=encoding utf8

=head1 AUTHOR

Marat,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
