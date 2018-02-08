package kshisa::Controller::Root;

use Moose;
use namespace::autoclean;
use utf8;
use YAML::Any qw(LoadFile DumpFile);

BEGIN { extends 'Catalyst::Controller' }

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
    my ( $codes, $text, $form, $full, $ba, $fr, $ava, $name, $id, $lb, $l, $r, $rb, $all, $rew, $admin,
    $avat, $file, $side, $right, $maxr, $rcent, $dsl, $left, $maxl, $cout, $info, $ds );
    my $param = $c->req->body_params;
    my $userPath = $c->config->{'userPath'};
    sub char {
        my $pass;
        my @chars = split( " ","A B C D E F G H I J K L" );
        foreach my $line (1..6) {
            $pass = $pass.'<hr/>';
            foreach my $char (@chars) {
                $pass = $pass.'<label><input type="radio" name="'.$line.'"value="'.$char.'" />'.$char.'</label>'
            }
        }
        return '<form method=POST action="/user/pass"><p/>'.$pass.'<hr/><input type="submit" name="Enter" value="Enter"/><p/></form>'
    }
    sub code {
        my (@codes, $codes);
        my ($ds) = LoadFile('/home/marat/Users/best');
        push @codes, $ds->{$_}{'code'} for (1..100);
        foreach (@codes) {
            $codes = $codes.'<img src="/images/imgs/'.$_.'kad3.jpg">';
        }
        return $codes;
    }
    if ($param->{'admin.x'}) {
        $c->stash (
            action => '/admin/start',
        );
    }
     if ($param->{Enter}) {
        my $pass;
        for (1..6) { $pass = $pass.$param->{$_} if $param->{$_}}
        my ($ds0) = LoadFile($userPath.0);
        for (1..$ds0->{0}) {
            if ( $ds0->{$_}{1} eq $pass ) {
                $id = $ds0->{$_}{0};

                ( $name, $avat, $file, $side, $right, $maxr, $rcent, $ava, $fr, $ba, $dsl, $left, $maxl, $cout, $info, $ds ) = 
                    $c->model('Html')->load( $param, $userPath, $id );
                ( $l, $full, $r, $lb, $rb  ) = 
                    $c->model('Html')->info( $cout, $side, $left, $right, $info->{'code'}, $ds, $dsl, $info, $rew, $ava, $name, $id ); 
                    $c->model('Html')->dump( $userPath, $id, $ds, $file, $left, $side, $right, $cout );
            }
        }
    }
    elsif ($id = $param->{id}) {
         my ($s0, $s1, $s2, $s3, $s4, $s5, $s6, $s7)=                        # SNIPETS
            ('<img class="', '<input class="', '" type="image" name="', '" src="/images/imgs/', '.jpg" />', '<div class="numb">', '</div>', 
            '" src="/images/buttons/');
            
        ( $name, $avat, $file, $side, $right, $maxr, $rcent, $ava, $fr, $ba, $dsl, $left, $maxl, $cout, $info, $ds ) = 
            $c->model('Html')->load( $param, $userPath, $id );
            
        if ( $param->{'Next_l.x'} or $param->{'Last_l.x'}) {            # STEP LEFT POSTERS
            $left = $c->model('Yaml')->step($param, $left, $maxl)
        }
        elsif ( $param->{'Next_r.x'} or $param->{'Last_r.x'}) {         # STEP RIGHT POSTERS
            $right = $c->model('Yaml')->step($param, $right, $maxr);
        }
        elsif ($param->{'kadr1.x'}) { ($cout, $side, $info) = ($left+1,   0, $dsl->{1}{1}{$left+1}) }
        elsif ($param->{'kadr2.x'}) { ($cout, $side, $info) = ($left+2,   0, $dsl->{1}{1}{$left+2}) }
        elsif ($param->{'kadr3.x'}) { ($cout, $side, $info) = ($left+3,   0, $dsl->{1}{1}{$left+3}) }
        elsif ($param->{'kadr4.x'}) { ($cout, $side, $info) = ($left+4,   0, $dsl->{1}{1}{$left+4}) }
        elsif ($param->{'kadr5.x'}) { ($cout, $side, $info) = ($right+1,  1, $ds->{1}{2}{$right+1}) }
        elsif ($param->{'kadr6.x'}) { ($cout, $side, $info) = ($right+2,  1, $ds->{1}{2}{$right+2}) }
        elsif ($param->{'kadr7.x'}) { ($cout, $side, $info) = ($right+3,  1, $ds->{1}{2}{$right+3}) }
        elsif ($param->{'kadr8.x'}) { ($cout, $side, $info) = ($right+4,  1, $ds->{1}{2}{$right+4}) }
        elsif ($param->{'poster.x'} && $side==0 && $file==1) {          # CHOOSE
            $c->model('Yaml')->magic($ds, $cout, $dsl);
        }
        elsif ($param->{'poster.x'} && $side==0 && $file==0) {          # MAGIC CHOOSE
            my ($dsb) = LoadFile($userPath.'base');
            my ( $dsc, $code ) = $c->model('Yaml')->magic($ds, $cout, $dsl, $dsb);
            DumpFile($userPath.'code', $dsc);
        }
        elsif ($param->{'poster.x'} && $side==1) {
            my $radio;
            $radio = $radio.'<label><input type="radio" name="usreit" value="'.$_.'" />'.$_.'</label>' for ( 1..9 );
            $rew = '<textarea name="rew" cols="68" rows="2" placeholder="Review">'.$ds->{1}{2}{$cout}{$id}{'rew'}
            .'</textarea>'.'<p>IMDB ='.$ds->{1}{2}{$cout}{'reit'}.'&nbsp;&nbsp;&nbsp;Your ='.$radio.'</p>';
        }
        elsif ($param->{'poster.x'} && $param->{rew}) {
            $ds->{1}{2}{$cout}{$id}{'Usreit'} = $param->{usreit}.'00';
            $ds->{1}{2}{$cout}{$id}{'rew'} = $param->{rew};
            $ds->{1}{2}{$cout}{'grey'} = '';
            $ds->{0}{'reit'} = $ds->{0}{'reit'} + 1;
        }
        elsif ($param->{'All_l.x'}) {
            $all = $all.$s1.'imageall'.$s2.$_.$s3.$ds->{1}{1}{$_}{'code'}.'kad0'.$s4 for(1..$ds->{1}{1}{0});
        }
        elsif ($param->{'All_r.x'}) {
            $all = $all.$s1.'imageall'.$s2.$_.$s3.$ds->{1}{2}{$_}{'code'}.'kad0'.$s4 for(1..$ds->{1}{2}{0});
        }
        elsif ($param->{'del.x'}) { $side = $c->model('Yaml')->del($ds, $rcent, $maxr) }              # DELETE
        elsif ($param->{id} && $param->{'fr.x'}){ $c->go("/friends/index", [$id]) }

        ( $l, $full, $r, $lb, $rb  ) = 
            $c->model('Html')->info( $cout, $side, $left, $right, $info->{'code'}, $ds, $dsl, $info, $rew, $ava, $name, $id ); 
            $c->model('Html')->dump( $userPath, $id, $ds, $file, $left, $side, $right, $cout );
    }
    
    elsif ($param->{New}) {
        if ($param->{New} eq 'Yes') {
            my $avat;
            $codes = '<div class="fadein">'.code.'</div>';
            my @ava = split( " ","001 002 003 004 005 006 007 008 009 010 011 012" );
            foreach (@ava) {
                $avat = $avat.'<input type="image" class="ava" src="/images/avat/ava'.$_.'.jpg" name="ava'.$_.'" />';
            }
        $text = '<div id="pass"></div><div id="user"><hr>______________1. Enter Your Name:________________________2. Enter Your Email:__<p>
                 <input type="text" name="name" class="userid"/>&nbsp&nbsp
                 <input type="text" name="mail" class="userid"/>
                 <hr>3. Choose Your Avatar<p>'.$avat.'</div>';
        }
        elsif ($param->{New} eq 'No') {
            $text = '<div id="pass"></div><div id="user">Enter your password</div>';
            $form = '<div id="dash">'.char.'</div>';
            $codes = '<div class="fadein"></div>';

        }
    }        
    else {
        $codes = '<div class="fadein">'.code.'</div>';
        $text = '<div id="pass"></div><div id="user">New User? &nbsp&nbsp&nbsp
                     <input type="radio" name="New" onclick="subm()"value="Yes">Yes</input>
                     <input type="radio" name="New" onclick="subm()"value="No">No</input></div>';
        $admin = '<input type="image" name="admin" src="/images/buttons/@.png"/>';
    }
    foreach my $avat (keys %$param) {
        if ($avat =~ /ava\d+.x/) {
            $avat =~ s/\.x//;
            $codes = '';
            if ($param->{name} && $param->{mail}) {
                $text = $c->model('Yaml')->user($c->config->{'userPath'}, $param->{name}, $avat, $param->{mail});
                if ($text eq '') {
                    $text = '<div id="pass"></div><div id="user">Enter your password</div>';
                }
                $form = '<div id="dash">'.char.'</div>';
            }
            else {
                $text = '<div id="pass"></div><div id="user">You forgot to type your name or email</div>';
            }
       }
    }

    $c->stash (
        text     => $text,
        form     => $form,
        codes    => $codes,
        admin    => $admin,
        full     => $full,
        ba       => $ba,
        fr       => $fr,
        avat     => $ava,
        name     => $name,
        id       => $id,
        user     => $name,
        lb       => $lb,                                                # LEFT BUTTONS
        l        => $l,                                                 # LEFT PICTURES
        r        => $r,                                                 # RIGT PICTURES
        rb       => $rb,                                                # RIGHT BUTTONS
        all      => $all,
        
    );
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
This library is not free software.

=cut

__PACKAGE__->meta->make_immutable;

1;
