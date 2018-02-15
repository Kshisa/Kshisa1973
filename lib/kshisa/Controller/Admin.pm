package kshisa::Controller::Admin;
use Moose;
use namespace::autoclean;
use utf8;
BEGIN { extends 'Catalyst::Controller::HTML::FormFu' }

=head1 NAME
kshisa::Controller::Find - Catalyst Controller
=head1 DESCRIPTION
Catalyst Controller.
=head1 METHODS
=cut
=head2 index
=cut
sub index :Local :FormConfig('find.json') {
    my ($self, $c, $cols0, $cols1) = @_;
    my $form = $c->stash->{form};
    my $param = $c->req->body_params;
    my $nextval0  = $param->{'id_a'} || 0;
    my $nextval1  = $param->{'id_b'} || 0;
    my $img_path1 = $c->config->{'img_path1'};
    my $img_path2 = $c->config->{'img_path2'};
    my $img_path3 = $c->config->{'img_path3'};
    my $img_path4 = $c->config->{'img_path4'};
    my $select    = $c->config->{'select'};    
    my $userPath  = $c->config->{'userPath'};

    my (@cols, $par, $pics, $micro);
    push @cols, $_->[0] foreach @{$c->config->{'cols'}};                                             # столбцы таблиц
    
    ($cols0, $cols1) = $c->model('DB')->start(\@cols, $img_path3);                                    # home screen
    if ($param->{'kshisa.x'}) {
        $c->response->redirect($c->uri_for("/"));
    }
    if  ($param->{$par ='prev.x'} or $param->{$par ='next.x'}) {                                     # переход в базе на шаг вперёд и назад
        ($cols0, $cols1) = $c->model('DB')->step($nextval1, \@cols, $par, $img_path3);
        $form->add_valid($_.'_b', $cols1->{$_}) foreach (keys %$cols1);
    }
    
    if ($param->{'kadr5.x'}) {
        $c->model('DB')->inyaml($select, $c->config->{'userPath'});
        ($cols0, $cols1) = $c->model('DB')->start(\@cols, $img_path3);                                   # home screen
    }
    if ($param->{'add.x'}) {
        $c->model('Yaml')->base($select, $c->config->{'userPath'});
       ($cols0, $cols1) = $c->model('DB')->start(\@cols, $img_path3);                                    # home screen
    }
    
    if ($param->{find}) { 
        my $address = $param->{'Address'};                                                           # поиск
        my $rs = $c->model('DB')->resultset('Films2')->find({runame => { 'like', "%$address%" } });
        if ($rs) {
            $cols1->{'id'} = $rs->id;
            $nextval1 = $rs->id;
            ($cols0, $cols1) = $c->model('DB')->search($address, $img_path3, $nextval1, \@cols);
            $form->add_valid($_.'_b', $cols1->{$_}) foreach (keys %$cols1);
        }
        else {
           ($cols0, $cols1) = $c->model('DB')->search($address, $img_path3, $nextval1, \@cols); 
        }
        $form->add_valid($_.'_a', '') foreach @cols;
        $form->add_valid('Address', $address);
    }
   
   if ($param->{$par ='kadr0.x'} or $param->{$par ='kadr1.x'} or $param->{$par ='kadr2.x'}) {
        ($cols0, $cols1, $pics) = $c->model('DB')->mail(\@cols, $par, $select, $img_path1, $img_path3, $nextval1);
        my $orname = $cols0->{'orname'};
        $form->add_valid('Address', $orname);
        $form->add_valid($_.'_a', $cols0->{$_}) foreach (keys %$cols0);
        $c->model('Yaml')->tempIn($cols0, $userPath);
        my $rs = $c->model('DB')->resultset('Films2')->find({orname => { 'like', "%$orname%" } });
        if ($rs) {
            $cols1->{'id'} = $rs->id;
            $nextval1 = $rs->id;
            ($cols0, $cols1) = $c->model('DB')->search($orname, $img_path3, $nextval1, \@cols);
            $form->add_valid($_.'_b', $cols1->{$_}) foreach (keys %$cols1);
        }
        my $big = @$pics[0];
        $big =~ s/S/\//g;
        $big =~ s/D/\./g;
        $micro = '<img id=left width=640px src="'.$big.'"><div id="findimgs">';
        foreach (@$pics) {
            $micro = $micro.'<input class="imagemail" type="image" src="/images/find1/'.$_.'.jpg" name="'.$_.'" /><input type="checkbox" name="'.$_.'" />';
        }
        $micro = $micro.'<input type="submit" name="inkad" value="InKad" /></div>';
    }
    
    foreach my $key (keys %$param){
        if ($key =~ /https:SSpicDkinoDmailDruS\d+S\.x/) {
            $key =~ s/S/\//g;
            $key =~ s/D/\./g;
            $key =~ s/\.x//;
            $nextval1 = $param->{id_b};
            ($cols0, $cols1, $pics) = $c->model('DB')->pics( \@cols, $img_path1, $img_path3, $nextval1);
            $form->add_valid($_.'_a', $cols0->{$_}) foreach (keys %$cols0);

            $micro = '<img id=left width=640px src="'.$key.'"><div id="findimgs">';
            foreach (@$pics) {
                $micro = $micro.'<input class="imagemail" type="image" src="/images/find1/'.$_.'.jpg" name="'.$_.'" /><input type="checkbox" name="'.$_.'" />';
            }
            $micro = $micro.'<input type="submit" name="inkad" value="InKad" /></div>';
            my %info = $c->model('Yaml')->tempOut(\@cols, $userPath);
            $form->add_valid($_.'_a', $info{$_}) foreach (keys %info);
       }
    }
    
    if ($param->{inkad}) { 
        my %info = $c->model('Yaml')->tempOut(\@cols, $userPath);
        $form->add_valid($_.'_a', $info{$_}) foreach (keys %info);
        my $kad = 1;
        foreach my $key (keys %$param) {
            if ($key =~ /https:SSpicDkinoDmailDruS\d+/) {
                $key =~ s/S/\//g;
                $key =~ s/D/\./g;
                $key =~ s/\.x//;
                $info{'kad'.$kad} = $key;
                $form->add_valid('kad'.$kad.'_a', $key);
                $kad++;
            }
        }
        ( $cols0, $cols1 ) = $c->model('DB')->pics( \@cols, $img_path1, $img_path3, $nextval1 );
        $c->model('Yaml')->tempIn(\%info, $userPath);
    }
    
    if ($param->{'inst.x'}) {
        my $code;
        ( $cols0, $cols1, $code ) = $c->model('DB')->ins( $nextval1, $form, '_a', \@cols, $img_path2, $img_path3, $img_path4 );
        $form->add_valid('Address', '');
        $form->add_valid($_.'_b', $cols1->{$_}) foreach (keys %$cols1);
        $form->add_valid($_.'_a', '') foreach @cols;
        my %info = $c->model('Yaml')->tempOut(\@cols, $userPath);
        $info{'coun'} = $select->{'coun'}{$info{'coun_0'}}[1].':'.$select->{'coun'}{$info{'coun_1'}}[1].':'.$select->{'coun'}{$info{'coun_2'}}[1].':'.$select->{'coun'}{$info{'coun_3'}}[1];
        $info{'genr'} = $select->{'genr'}{$info{'genr_0'}}[1].':'.$select->{'genr'}{$info{'genr_1'}}[1].':'.$select->{'genr'}{$info{'genr_2'}}[1].':'.$select->{'genr'}{$info{'genr_3'}}[1];
        $info{'code'} = $code;
        $c->model('Yaml')->tempIn(\%info, $userPath);
        $c->model('Yaml')->create(\%info, $userPath);
    }
    if ($param->{add1}) {
        ( $cols0, $cols1 ) = $c->model('DB')->ins( $nextval1, $form, '_b', \@cols, $img_path2, $img_path3, $img_path4 );
        $c->model('Yaml')->tempIn($cols1, $userPath);
        $form->add_valid('Address', '');
        $form->add_valid($_.'_b', $cols1->{$_}) foreach (keys %$cols1);
        $form->add_valid($_.'_a', '') foreach @cols;
        
    }
    
    if ($param->{ID}) {
        ($cols0, $cols1) = $c->model('DB')->start(\@cols, $img_path3);
        my $id = $param->{'Info2'};
        my $rs = $c->model('DB')->resultset('Films2')->find({id => $id });
        if ($rs) {
            foreach (@cols) {
                if ($_ =~ /(\D+)_(\d+)/) {
                    my @set = split ':', $rs->$1;
                    $cols1->{$_} = uc $set[$2];
                } 
                else {
                    $cols1->{$_} = $rs->$_;
                }
            }
            $cols1->{'id'} = $rs->id;
            $form->add_valid($_.'_b', $cols1->{$_}) foreach (keys %$cols1);
        }
        else{
            ($cols0, $cols1) = $c->model('DB')->start(\@cols, $img_path3);                              # home screen
        }
    }
    
    if ($param->{doun}) {
       my $magnet = $param->{'magnet1_b'};
       my $message = `transmission-remote 192.168.1.33:9091 -a magnet:?xt=urn:btih:$magnet`;
       $form->add_valid('Address', $message);
       ($cols0, $cols1) = $c->model('DB')->start(\@cols, $img_path3);                                   # home screen
    }

    my $sum = $c->model('DB')->resultset('Films2')->get_column('id')->func('count');
    $form->add_valid('Info1', $sum);
    $form->add_valid('Info2', $cols1->{'id'});
    $form->add_valid($_.'_b', $cols1->{$_}) foreach (keys %$cols1);
    my %cols0 = %$cols0;
    my %cols1 = %$cols1;
    my ($pict11, $pict12, $pict13) = ($cols0{'code0'}, $cols0{'code1'}, $cols0{'code2'});
    my $pict2 = '/images/imgs/'.$cols1{'code'};
    my $kshisa = '<input type="image" id="kshisa" name="kshisa" src="/images/buttons/kshisa1.png"/>';
    
    $form->get_element({type=>'Block', tag=>'div class=left_col'})->get_element({type=>'Image', name=>'kadr0'})->add_attrs({src =>$pict11.'kad0.jpg'});     
    $form->get_element({type=>'Block', tag=>'div class=left_col'})->get_element({type=>'Image', name=>'kadr1'})->add_attrs({src =>$pict12.'kad1.jpg'});
    $form->get_element({type=>'Block', tag=>'div class=left_col'})->get_element({type=>'Image', name=>'kadr2'})->add_attrs({src =>$pict13.'kad2.jpg'});
    
    $form->get_element({type=>'Block', tag=>'div class=right_col'})->get_element({type=>'Image', name=>'kadr5'})->add_attrs({src =>$pict2.'kad0.jpg'});
    $form->get_element({type=>'Block', tag=>'div class=right_col'})->get_element({type=>'Image', name=>'kadr6'})->add_attrs({src =>$pict2.'kad1.jpg'});
    $form->get_element({type=>'Block', tag=>'div class=right_col'})->get_element({type=>'Image', name=>'kadr7'})->add_attrs({src =>$pict2.'kad2.jpg'});
    $form->get_element({type=>'Block', tag=>'div class=right_col'})->get_element({type=>'Image', name=>'kadr8'})->add_attrs({src =>$pict2.'kad3.jpg'});
    $form->get_element({type=>'Block', tag=>'div class=right_col'})->get_element({type=>'Image', name=>'kadr9'})->add_attrs({src =>$pict2.'kad4.jpg'});
    
    $c->stash ( 
        template => 'index.tt',
        micro    => '<form name="big" method=POST action="/find/base"><input type="hidden" name="id_b" value="[% id_b %]" />
                        <hr> <div id="pics">'.$micro.'<div> <hr> </form>',
        id_b     => $nextval1,
        kshisa   => $kshisa,
        action   => '/admin/index',
    ); 
}

=encoding utf8

=head1 AUTHOR

Hakimov Marat

=head1 LICENSE

This library is not free software.

=cut

__PACKAGE__->meta->make_immutable;

1;
