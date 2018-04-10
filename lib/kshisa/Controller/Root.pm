package kshisa::Controller::Root;

use Moose;
use namespace::autoclean;
use utf8;
use YAML::Any qw(LoadFile DumpFile);


BEGIN { extends 'Catalyst::Controller::HTML::FormFu' }

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
    
    my $param = $c->req->body_params;
    my $userPath = $c->config->{'userPath'};    
    my $img_path1 = $c->config->{'img_path1'};
    my $img_path2 = $c->config->{'img_path2'};
    my $img_path3 = $c->config->{'img_path3'};
    my $img_path4 = $c->config->{'img_path4'};

    my ( $ident, $text, $form, $full, $ba, $lo, $ava, $name, $user, $id, $lb, $l, $r, $rb, $micro, $rew,
         $avat, $file, $side, $right, $maxr, $rcent, $dsl, $left, $maxl, $cout, $info, $ds, $path, $usreit, 
         $usrew, $love, $message, $n, $film );
    my $pl = 0;

    if ($param->{'kshisa.x'}) {
        $c->response->redirect($c->uri_for("/"));
    }
    if ($param->{'P6'}) {                                               # PASSWORD VERIFICATION
        my $pass;
        for (1..6) { $pass = $pass.$param->{'P'.$_} if $param->{'P'.$_}}
        my ($ds0) = LoadFile($userPath.0);
        my $flag = 0;
        for (1..$ds0->{0}) {
            if ( $ds0->{$_}{1} eq $pass ) {
                $id = $ds0->{$_}{0};                                    # HOME SCREEN
                ($user, $file, $side, $right, $maxr, $rcent, $ava, $lo, $ba, $dsl, $left, $maxl, $cout, $info, $ds, $love, $n) = 
                    $c->model('Html')->load( $param, $userPath, $id );
                ($l, $full, $r, $lb, $rb) = 
                    $c->model('Html')->info( $cout, $side, $left, $right, $ds, $dsl, $info, $rew, 
                                             $path, $message, $usreit, $usrew, $lo, $ba, $n, $pl ); 
                    $c->model('Yaml')->dump( $userPath, $id, $ds, $file, $left, $side, $right, $cout, $love );
                $flag = 1;
            }
        }
        ($text, $ident) = ($c->model('Html')->wrong($userPath), 'pass') if $flag == 0;  # WRONG PASSWORD
    }
    
    elsif ($id = $param->{id}) {
        $ident = 'main';
        ( $user, $file, $side, $right, $maxr, $rcent, $ava, $lo, $ba, $dsl, $left, $maxl, $cout, $info, $ds, $love, $n) = 
            $c->model('Html')->load( $param, $userPath, $id );

        if ( $param->{'Next_l.x'} or $param->{'Last_l.x'}) {            # STEP LEFT POSTERS
            $left = $c->model('Yaml')->step($param, $left, $maxl)
        }
        elsif ( $param->{'Next_r.x'} or $param->{'Last_r.x'}) {         # STEP RIGHT POSTERS
            $right = $c->model('Yaml')->step($param, $right, $maxr);
        }
        elsif ($param->{'kadr1.x'}) { ($cout, $side, $info) = ($left+1,   0, $dsl->{1}{1}{$left+1}) }   # CENTRAL VIEW
        elsif ($param->{'kadr2.x'}) { ($cout, $side, $info) = ($left+2,   0, $dsl->{1}{1}{$left+2}) }
        elsif ($param->{'kadr3.x'}) { ($cout, $side, $info) = ($left+3,   0, $dsl->{1}{1}{$left+3}) }
        elsif ($param->{'kadr4.x'}) { ($cout, $side, $info) = ($left+4,   0, $dsl->{1}{1}{$left+4}) }
        if ($love == 0) {
            if ($param->{'kadr5.x'}) { ($cout, $side, $info) = ($right+1,  1, $ds->{1}{2}{$right+1}) }
            if ($param->{'kadr6.x'}) { ($cout, $side, $info) = ($right+2,  1, $ds->{1}{2}{$right+2}) }
            if ($param->{'kadr7.x'}) { ($cout, $side, $info) = ($right+3,  1, $ds->{1}{2}{$right+3}) }
            if ($param->{'kadr8.x'}) { ($cout, $side, $info) = ($right+4,  1, $ds->{1}{2}{$right+4}) }
        }
        if ($love == 1) {
            if ($param->{'kadr5.x'}) { ($cout, $side, $info) = ($right+1,  1, $ds->{1}{4}{$right+1}) }
            if ($param->{'kadr6.x'}) { ($cout, $side, $info) = ($right+2,  1, $ds->{1}{4}{$right+2}) }
            if ($param->{'kadr7.x'}) { ($cout, $side, $info) = ($right+3,  1, $ds->{1}{4}{$right+3}) }
            if ($param->{'kadr8.x'}) { ($cout, $side, $info) = ($right+4,  1, $ds->{1}{4}{$right+4}) }
        }
        if ( $side == 0 ) {
            if  ( $file == 0 ) {
                if ($param->{'g.x'}) {                                  # MASHINE CHOICE FOR VIEWING
                    ($cout, $right) = $c->model('Yaml')->mashine($ds, $cout, $dsl, $userPath, 'g');
                    ($file, $side, $info, $love) = (0, 1, $ds->{1}{2}{$cout}, 0);
                }
                if ($param->{'h.x'}) {                                  # MASHINE CHOICE OF FAVORITE
                    ($cout, $right) = $c->model('Yaml')->mashine($ds, $cout, $dsl, $userPath, 'h');
                    ($file, $side, $info, $love) = (0, 1, $ds->{1}{4}{$cout}, 1);
                }
            }
            if  ( $file == 1 ) {
                if ($param->{'g.x'}) {                                  # CHOICE FOR VIEWING
                    ($cout, $right) = $c->model('Yaml')->mashine($ds, $cout, $dsl, $userPath, 'g');
                    ($side, $info, $love) = (1, $ds->{1}{2}{$cout}, 0);
                     
                }
                if ($param->{'h.x'}) {                                  # CHOICE OF FAVORITE
                    ($cout, $right) = $c->model('Yaml')->mashine($ds, $cout, $dsl, $userPath, 'h');
                    ($side, $info, $love) = (1, $ds->{1}{4}{$cout}, 1);
                }
            }
        }
        if ( $side == 1 ) {
            if ($param->{'phon.x'} && $param->{rew}) {                  # SAVE USER REWIEW
                ($usreit, $usrew) = $c->model('Yaml')->rew($ds, $cout, $param, $love);
            }        
            if ($param->{'phon.x'}) {  
                $rew = $c->model('HTML')->rew($ds, $cout);              # USER REWIEW PANEL
            }
            if ($param->{'del.x'} && $love == 0) {                      # DELETE FOR VIEWING
                ($cout, $side, $info, $left) = $c->model('Yaml')->del($ds, $dsl, $cout, $maxr, 2);
            }
            if ($param->{'del.x'} && $love == 1) {                      # DELETE OF FAVORITE
                ($cout, $side, $info, $left) = $c->model('Yaml')->del($ds, $dsl, $cout, $maxr, 4);
            }
        } 
        
        if ($param->{ID}) {                                             # FIND IN BASE BY NUMBER
            ($message, $cout, $side, $info, $left) = 
                $c->model('Yaml')->numb($param->{Info}, $dsl);
        }
        if ($param->{find}) {                                           # FIND IN BASE BY NAME
            my $find = 0;
            ($file, $cout, $side, $info, $left, $find) = 
                $c->model('Yaml')->find(lc $param->{Address}, $dsl);
            if ($find == 0) {                                           # FIND IN AFISHA BY NAME
                $message = 'No result in base';
                $c->detach('admin', [$user, 'new', $param->{Address}]);
            }            
        }
        if ($param->{find0}) {                                          # INSERT INFO IN MYSQL BASE
            $c->detach('admin', [$user, 'create']);
        }
        if ($param->{find1}) {                                          # EDIT INFO IN MYSQL BASE
            $c->detach('admin', [$user, 'insert']);
        }   
        if ($param->{find2}) {                                          # LOAD PICTURES FROM MAIL.RU INTO /FIND1 AND SHOW
            $micro = $c->model('Yaml')->pics($img_path1, $userPath);
        }     

        foreach my $key (keys %$param) {                                # FIND ALL OF THAT YEAR
            if ($key =~ /^\d+$/) {
                $micro = $c->model('Html')->micro($dsl, $key);
            }
            if ($key =~ /^(\d+)\.x/) {                                  # ONE FROM FILMS OF THAT YEAR
                ($micro, $side, $cout, $info) = ('', 0, $1, $dsl->{1}{1}{$1});
                my $p = $cout/4 - int($cout/4);
                if    ( $p == 0)    { $left = $cout-4}
                elsif ( $p == 0.75) { $left = $cout-3}
                elsif ( $p == 0.5)  { $left = $cout-2}
                elsif ( $p == 0.25) { $left = $cout-1}
            }
            if ($key =~ /^(\d+_.*?)\.x/) { 
                $key =~ tr[.x][]d;
                $c->detach('admin', [$user, 'edit', $key]);             # CHOOSE ONE FILM FROM POSTERS
            }
        }
        if ($param->{find3}) {                                          # SHOW PREVIEW
            ($micro, $side, $pl) = ('', 0, 3);                              
            ($path, $info) = $c->model('Yaml')->tempIn3($userPath, $c->config->{'cols'}, $param);      # IN TEMP
        }

        if ($param->{find4}) {                                          # CHOOSE 4 PICTURES AND LOAD POSTER AND GREY
           my $code = 
                      $c->model('Yaml')->imgs( $userPath, $img_path1, $img_path2, $img_path3, $img_path4 ); 
           ($cout, $left) = $c->model('Yaml')->all($c->config->{'select'}, $c->config->{'userPath'}, $code);
            
           ($file, $side, $info) = (1, 0, $dsl->{1}{1}{$cout});
        }
        if ($param->{edit}) {                                           # EDIT
            $c->detach('admin', [$user, 'new', $info->{'orname'}]);
        }
        if ($param->{down}) {                                           # DOWNLOAD
            my $magnet = $info->{'magnet'};
            $message = `transmission-remote 192.168.1.5:9091 -a magnet:?xt=urn:btih:$magnet`;
        }
        if ($param->{sql}) {                                            # FOM ALL TO MYSQL
            $c->model('Yaml')->conf($c->config->{'cols'}, $c->config->{'select'}, $c->config->{'form_path'});
            #$c->model('Yaml')->mysql($c->config->{'cols'}, $c->config->{'select'}, $userPath);
        }
        # $message  = $cout.'-----'.$side.'-----'.$info.'-----'.$love;
        ($l, $full, $r, $lb, $rb) = 
            $c->model('Html')->info( $cout, $side, $left, $right, $ds, $dsl, $info, $rew, 
                                     $path, $message, $usreit, $usrew, $lo, $ba, $n, $pl );
            $c->model('Yaml')->dump( $userPath, $id, $ds, $file, $left, $side, $right, $cout, $love );
    }

    elsif ($param->{New}) {                                             # NEW OR NOT USER
        ($text)         = ($c->model('Html')->yes_new($userPath))         if $param->{New} eq 'Yes';
        ($text, $ident) = ($c->model('Html')->not_new($userPath), 'pass') if $param->{New} eq 'No', ;
    }        
    else { 
        $text = $c->model('Html')->start($userPath);                    # START SCREEN
        $ident = 'start';
    }
    foreach my $avat (keys %$param) {                                   # CREATING NEW USER                                                                      
        if ($avat =~ /ava\d+.x/) {
            $avat =~ s/\.x//;
            if ($param->{name} && $param->{mail}) {
                my $pass = $c->model('Yaml')->user($c->config->{'userPath'}, $param->{name}, $avat, $param->{mail});
                ($text, $ident) = ($c->model('Html')->enter($pass), 'pass')
            }
            else {
                $text = $c->model('Html')->forgot($c->config->{'userPath'});
            }
       }
    }
    $c->stash (
        user     => $user,                                              # HEADER
        micro    => $micro,                                             # ALLPICTURES
        l        => $lb.$l,                                             # LEFT PICTURES
        full     => $full,                                              # CENTER-FULLINFO
        text     => $text,                                              # HTML CODE
        r        => $rb.$r,                                             # RIGHT PICTURES
        forma    => $form,
        ident    => $ident,
    );
}
sub admin :Local :FormConfig('find.json') {                             # ADMIN PANEL
    
    my ($self, $c, $user, $edit, $name ) = @_;
    
    my $form = $c->stash->{form};
    my $param = $c->req->body_params;
    my $select = $c->config->{'select'};
    my $userPath = $c->config->{'userPath'};  
    my $img_path1 = $c->config->{'img_path1'};
    my $img_path2 = $c->config->{'img_path2'};
    my $img_path3 = $c->config->{'img_path3'};
    my $img_path4 = $c->config->{'img_path4'};

    my (@cols, @cols1, %cols, $micro, $mail, $cols);
    push @cols, $_->[0] foreach @{$c->config->{'cols'}};                # TABLES ROWS
    push @cols1, $_->[0] foreach @{$c->config->{'cols1'}};
    
    if ($edit eq 'new' or $edit eq 'edit') {   
        if ($edit eq 'new') {                       
            ($micro, $mail) = ($c->model('Yaml')->search($name, $img_path3)) ;
            $cols = $c->model('Yaml')->mail($mail, $select);
        }
        if ($edit eq 'edit') {
            $cols = $c->model('Yaml')->mail($name, $select);
        }
        my ($orname, $year) = $c->model('Yaml')->tempIn1($cols, $userPath);      # IN TEMP FILE
        delete $cols->{'kad0'};
        $form->add_valid($_.'_a', $cols->{$_}) foreach (keys %$cols);
        my $rs = $c->model('Yaml')->resultset('Films2')->find({orname => $orname, year => $year});
        
        if ($rs) {
            my $ds = LoadFile($userPath.'temp');
            $ds->{code} = $rs->code;
            DumpFile($userPath.'temp', $ds);
            my %cols1;
            foreach (@cols1) {                                           
                if ($_ =~ /(\D+)_(\d+)/) {
                    my @set = split ':', $rs->$1;
                        $cols1{$_} = uc $set[$2];
                }
                else{
                    $cols1{$_} = $rs->$_ ;
                }
            }
            $form->add_valid($_.'_b', $cols1{$_}) foreach (keys %cols1);
            $form->add_valid('Address', $rs->id);
        }
    }        
     if ($edit eq 'create') {                                            # INSERT IN MYSQL
        $form->add_valid($_.'_a', '') foreach (@cols1);
        $cols{$_} = $param->{$_.'_a'} foreach (@cols1);
        $form->add_valid($_.'_b', $cols{$_}) foreach (keys %cols);
        $c->model('Yaml')->cret(\%cols);
        $c->model('Yaml')->tempIn2($userPath, \%cols);                  # IN TEMP FILE
    }  
    if ($edit eq 'insert') {                                            # EDIT IN MYSQL
        $form->add_valid($_.'_a', '') foreach (@cols1);
        $cols{$_} = $param->{$_.'_a'} foreach (@cols1);
        $form->add_valid($_.'_b', $cols{$_}) foreach (keys %cols);
        $c->model('Yaml')->edit(\%cols, $param->{'Address'});
        $c->model('Yaml')->tempIn2($userPath, \%cols);                  # IN TEMP FILE
    }

    $c->stash (
        user     => $user,                                              # HEADER
        micro    => $micro,                                             # ALLPICTURES

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
