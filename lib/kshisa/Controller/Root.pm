package kshisa::Controller::Root;

use Moose;
use namespace::autoclean;
use utf8;

BEGIN { extends 'Catalyst::Controller' }

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config(namespace => '');

=encoding utf-8

=head1 NAME

kshisa::Controller::Root - Root Controller for kshisa

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=head2 index

The root page (/)

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
    my @codes;
    my @rs = $c->model('DB')->resultset('Films2')->search(undef, {rows => 10});
    foreach my $code ( @rs ) {
        push @codes, $code->code;
    }
    $c->stash( 
        template => 'first.tt',
        codes => \@codes,
    );
}
sub pass :Local :Args(0) {
    my ( $self, $c ) = @_;
    my $choose;
    my $new = $c->req->body_params->{New};
    my $userId;
    if ($new eq 'Yes') {
        $userId = $c->model('DB')->pass($c->config->{'select'}, $c->config->{'userPath'});
        my @codes;
        my @rs = $c->model('DB')->resultset('Films2')->search(undef, {rows => 10});
        foreach my $code ( @rs ) {
            push @codes, $code->code;
        }
        $c->stash( 
            template => 'second.tt',
            codes    => \@codes,
            userId   => $userId,
        );
    }
    elsif ($new eq 'No') {
        $c->stash->{template} = 'third.tt';
    }
}

sub more :Local :Args(0) {
    my ( $self, $c ) = @_;
    my $param = $c->req->body_params;
    my $avat;
    my $id = $param->{userId};
    my $name = $param->{name};
    my $mail = $param->{mail};
    if ($name && $mail) {
        foreach my $key (keys %$param){
            if ($key =~ /ava\d+.x/) {
                $key =~ s/\.x//;
                $avat = $key;
            }
        }
        my $rs = $c->model('DB')->resultset('User')->find({id => $id});
        $rs->update({
            username => $name,
            email    => $mail,
            avatar   => $avat,
        });
        $c->stash ( 
            template => 'third.tt',
            userId   => $id,
        );
    } 
    else {
            $c->stash ( 
                template => 'second.tt',
                mesg => 'You forgot name or email',
            );
    } 
}

=head2 default

Standard 404 error page

=cut

sub default :Path {
    my ( $self, $c ) = @_;
    $c->response->body( 'Page not found' );
    $c->response->status(404);
}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {}

=head1 AUTHOR

Hakimov Marat

=head1 LICENSE
21.07.2017
This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
