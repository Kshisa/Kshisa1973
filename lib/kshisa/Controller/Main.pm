package kshisa::Controller::Main;
use Moose;
use namespace::autoclean;
use YAML::Any qw(LoadFile DumpFile);

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME
kshisa::Controller::Main - Catalyst Controller
=head1 DESCRIPTION
Catalyst Controller.
=head1 METHODS
=cut
=head2 index
=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
    my ($pics, @film, $form1, $form2, $l, $r, $post);
    my $param = $c->req->body_params;
    my $Base  = $c->config->{'Base'};
    my $imgs  = '/images/imgs1/';
    my $find0 = $c->config->{'find0'};
    my $find1 = $c->config->{'find1'};
	my $find2 = $c->config->{'find2'};
	my $imgs0 = $c->config->{'imgs0'};
    my $imgs1 = $c->config->{'imgs1'};
    my $imgs2 = $c->config->{'imgs2'};
    my $dba00 = LoadFile($Base.'00');
    my $dba2  = LoadFile($Base.'2');
    my $genr  = LoadFile($Base.'genr');	
	my $coun  = LoadFile($Base.'coun');
	my $year  = LoadFile($Base.'year');
    my $numb  = $param->{id} || 0;
    my $all   = $#{$dba00};
	my $f  = $param->{idl} || 1;
	$l = $f + 5;
	if ($param->{'nextl.x'}) {
        $f = $f + 5;
        $l = $l + 5;
		($form2, $l) = $c->model('Main')->blank($dba2, $find0, $f, $l);
	}
	if ($param->{'prevl.x'}) {
        $f = $f - 5;
        $l = $l - 5;
		($form2, $l) = $c->model('Main')->blank($dba2, $find0, $f, $l);
	}
	if ($param->{'nextr.x'}) {
		if ($numb == $all) {
			$numb = 0
		}
		else {
			$numb = $numb + 1
		}
		$pics = $c->model('Main')->picset($dba00, $numb, $imgs);
		($form2, $l) = $c->model('Main')->blank($dba2, $find0, $f, $l);
	}
	if ($param->{'prevr.x'}) {
		if ($numb == 0) {
			$numb = $all
		}
		else {
			$numb = $numb - 1
		}
		$pics = $c->model('Main')->picset($dba00, $numb, $imgs);
		($form2, $l) = $c->model('Main')->blank($dba2, $find0, $f, $l);
	}
	if ($param->{'find1.x'}) {
	    $pics = $c->model('Main')->pics($find1);
		($form2, $l) = $c->model('Main')->blank($dba2, $find0, $f, $l);
	}
	if ($param->{'find.x'}) {
	    $pics = $c->model('Main')->prew($dba2, $param, $imgs1);
		($form2, $l) = $c->model('Main')->blank($dba2, $find0, $f, $l);
	}
	if ($param->{'post.x'}) { 
	    my $film = $c->model('Main')->imgs($dba2, $dba00, $numb, $param, $imgs0, $imgs1);
		DumpFile($Base.'00', $film);
		($form2, $l) = $c->model('Main')->blank($dba2, $find0, $f, $l);
		$pics = $c->model('Main')->picset($dba00, $numb, $imgs);
	}
	if ($param->{'add0.x'}) {
		$pics = $c->model('Main')->addpics($dba2, $dba00, $param, $find1, $imgs1, $imgs2, $numb);
		DumpFile($Base.'00', $dba00);
		($form2, $l) = $c->model('Main')->blank($dba2, $find0, $f, $l);
	}
	if ($param->{Address}) {
		my $flag = 0;
		for (0..$all) {
			if ($param->{Address} eq $dba00->[$_][1][0] or $param->{Address} eq $dba00->[$_][1][1]) {
                $numb = $_;
				$flag = 1;
				($form2, $l) = $c->model('Main')->blank($dba2, $find0, $f, $l);
			}
		}
		if ($flag == 0) {
			($l, $form2, $pics) = $c->model('Main')->mail($dba2, $param->{Address}, $find0, $find1, $find2)
        }	
	}
	if ($param->{'add1.x'}) {
	    ($numb, @film) = $c->model('Main')->addDataset($dba2, $dba00, $param, $find1, $imgs1, $imgs2);
	    DumpFile($Base.'00', [@film]);
		$dba00 = \@film;
		$all = $#film;
		($form2, $l) = $c->model('Main')->blank($dba2, $find0, $f, $l);
	}
	foreach my $key (keys %$param) {
        if ($key =~ /^(\d+_.*?)\.x/) {
		    ($l, $form2, $pics) = $c->model('Main')->mail($dba2, $1, $find0, $find1, $find2);
	    }
	    elsif ($key =~ /^(\d+)k(.*?)f(\d+_\d+)\.x/) {
		    $pics = '<img src="/images/imgs1/'.$2.'/'.$3.'_'.$1.'.jpg" />';
			($form2, $l) = $c->model('Main')->blank($dba2, $find0, $f, $l);
	    }
	}
	($form1, $r, $post) = $c->model('Main')->fromDataset($dba2, $dba00, $numb, $imgs, $find0, $find1, $imgs1, $genr, $coun, $year);
    $c->stash (
		form1 => $form1,
		form2 => $form2,
		r     => $r,
		post  => $post,
		id    => $numb,
		idl   => $f,
		all   => $all,
		l     => $l,
		pics  => $pics
    );
}



=encoding utf8

=head1 AUTHOR

Marat,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
