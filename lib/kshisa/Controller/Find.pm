package kshisa::Controller::Find;
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

sub find :Local :FormConfig('find.json') {
    my ($self, $c) = @_;
    my $form = $c->stash->{form};
    my $param = $c->req->body_params;
    my $nextval0 = $param->{'id_a'} || 0;
    my $nextval1 = $param->{'id_b'} || 0;
    my $img_path1 = $c->config->{'img_path1'};
    my $img_path2 = $c->config->{'img_path2'};
    my $img_path3 = $c->config->{'img_path3'};
    my $img_path4 = $c->config->{'img_path4'};
    my (@cols, $cols0, $cols1, $par, $pics);
    
    push @cols, $_->[0] foreach @{$c->config->{'cols'}};                                             # столбцы таблиц
    
    ($cols0, $cols1) = $c->model('DB')->start(\@cols, $img_path3);                                   # начальный экран
    $form->default_values({$_.'_b' => $cols1->{$_}}) foreach (keys %$cols1);

    if  ($param->{$par ='prev.x'} or $param->{$par ='next.x'}) {                                     # переход в базе на шаг вперёд и назад
        ($cols0, $cols1) = $c->model('DB')->step($nextval1, \@cols, $par, $img_path3);
        $form->add_valid($_.'_b', $cols1->{$_}) foreach (keys %$cols1);
    }
 
    if ($param->{'find.x'}) { 
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
    }
   
   if ($param->{$par ='kadr0.x'} or $param->{$par ='kadr1.x'} or $param->{$par ='kadr2.x'} or $param->{$par ='kadr3.x'} or $param->{$par ='kadr4.x'}) {
        ($cols0, $cols1, $pics) = $c->model('DB')->mail(\@cols, $par, $c->config->{'select'}, $img_path1, $img_path3, $nextval1);
        $form->add_valid($_.'_a', $cols0->{$_}) foreach (keys %$cols0);
        foreach my $post (@$pics){
            my $pic = $form->element({type => 'Image', container_tag => 'span', name => $post, src => "/images/find1/$post.jpg"});
            my $position = $form->get_element({ type => 'Block', tag => 'table' });
            $form->insert_before($pic, $position);
        }
    }
    
    if ($param->{'add.x'}) {
        ( $cols0, $cols1 ) = $c->model('DB')->ins( $nextval1, $form, '_a', \@cols, $img_path2, $img_path3, $img_path4 );
        $form->add_valid('Address', '');
        $form->add_valid($_.'_b', $cols1->{$_}) foreach (keys %$cols1);
        $form->add_valid($_.'_a', '') foreach @cols
    }
    if ($param->{add1}) {
        ( $cols0, $cols1 ) = $c->model('DB')->ins( $nextval1, $form, '_b', \@cols, $img_path2, $img_path3, $img_path4 );
        $form->add_valid($_.'_b', $cols1->{$_}) foreach (keys %$cols1);
        $form->add_valid($_.'_a', '') foreach @cols
    }
    foreach my $key (keys %$param){
        if ($key =~ /https:SSpicDkinoDmailDruS\d+S\.x/) {
            ($cols0, $cols1, $pics) = $c->model('DB')->pics( \@cols, $img_path1, $img_path3, $nextval1);
            for (1..4){                                                                                                     # поля адресов картинок
                my $kadr = $form->element({type => 'Text',  container_tag => 'span', id => 'kadr', name => "kadr$_", placeholder => "https://pic.kino.mail.ru/"});
                my $position = $form->get_element({ type => 'Block', tag => 'table' });
                $form->insert_before( $kadr, $position );
            }
            my $submit = $form->element({type => 'Submit',  container_tag => 'span', name => 'kadr', value => 'in kad'});
            my $position = $form->get_element({ type => 'Block', tag => 'table' });
            $form->insert_before( $submit, $position );
            $position = $form->get_element({ type => 'Submit', name => 'kadr' });
            $form->insert_after( $form->element({type => 'Hr'}), $position ); 
            
            foreach my $post (@$pics){
                my $pic = $form->element({type => 'Image', container_tag => 'span', name => $post, src => "/images/find1/$post.jpg"});
                my $position = $form->get_element({ type => 'Block', tag => 'table' });
                $form->insert_before( $pic, $position );
            }
            $position = $form->get_element({ type => 'Block', tag => 'table' });
            $form->insert_before( $form->element({type => 'Hr'}), $position );
           
            $key =~ s/S/\//g;
            $key =~ s/D/\./g;
            $key =~ s/\.x//;
            $c->stash ( 
                img => "<img id=left width=640px src=\"$key\">",
            );
        }
    }
    if ($param->{kadr}) { 
        $form->add_valid('kad1_a', $param->{'kadr1'});
        $form->add_valid('kad2_a', $param->{'kadr2'});
        $form->add_valid('kad3_a', $param->{'kadr3'});
        $form->add_valid('kad4_a', $param->{'kadr4'});
        ( $cols0, $cols1 ) = $c->model('DB')->pics( \@cols, $img_path1, $img_path3, $nextval1 );
        
    }
    if ($param->{ID}) {
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
            
        }
    }
    if ($param->{'kadr5.x'}) {
       my $magnet = $param->{'magnet1_b'};
       my $message = `transmission-remote 192.168.1.33:9091 -a magnet:?xt=urn:btih:$magnet`;
       $form->add_valid('Address', $message);
    }
    
    my $sum = $c->model('DB')->resultset('Films2')->get_column('id')->func('count');
    $form->add_valid('Info1', $sum);
    $form->add_valid('Info2', $cols1->{'id'});
    my %cols0 = %$cols0;
    my %cols1 = %$cols1;
    my ($pict11, $pict12, $pict13, $pict14, $pict15) = ($cols0{'code0'}, $cols0{'code1'}, $cols0{'code2'}, $cols0{'code3'}, $cols0{'code4'});
    my $pict2 = '/images/imgs/'.$cols1{'code'};
    
    $form->get_element({type=>'Block', tag=>'div class=imgmin1'})->get_element({type=>'Image', name=>'kadr0'})->add_attrs({src =>$pict11.'kad0.jpg'});     
    $form->get_element({type=>'Block', tag=>'div class=imgmin1'})->get_element({type=>'Image', name=>'kadr1'})->add_attrs({src =>$pict12.'kad1.jpg'});
    $form->get_element({type=>'Block', tag=>'div class=imgmin1'})->get_element({type=>'Image', name=>'kadr2'})->add_attrs({src =>$pict13.'kad2.jpg'});
    $form->get_element({type=>'Block', tag=>'div class=imgmin1'})->get_element({type=>'Image', name=>'kadr3'})->add_attrs({src =>$pict14.'kad3.jpg'});
    $form->get_element({type=>'Block', tag=>'div class=imgmin1'})->get_element({type=>'Image', name=>'kadr4'})->add_attrs({src =>$pict15.'kad4.jpg'});
    
    $form->get_element({type=>'Block', tag=>'div class=imgmin2'})->get_element({type=>'Image', name=>'kadr5'})->add_attrs({src =>$pict2.'kad0.jpg'});
    $form->get_element({type=>'Block', tag=>'div class=imgmin2'})->get_element({type=>'Image', name=>'kadr6'})->add_attrs({src =>$pict2.'kad1.jpg'});
    $form->get_element({type=>'Block', tag=>'div class=imgmin2'})->get_element({type=>'Image', name=>'kadr7'})->add_attrs({src =>$pict2.'kad2.jpg'});
    $form->get_element({type=>'Block', tag=>'div class=imgmin2'})->get_element({type=>'Image', name=>'kadr8'})->add_attrs({src =>$pict2.'kad3.jpg'});
    $form->get_element({type=>'Block', tag=>'div class=imgmin2'})->get_element({type=>'Image', name=>'kadr9'})->add_attrs({src =>$pict2.'kad4.jpg'});
    
    $c->stash ( 
        template => 'find.tt',
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
