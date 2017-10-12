package kshisa::Controller::User;
use Moose;
use namespace::autoclean;
use utf8;
use YAML::Any qw(LoadFile DumpFile);

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME
kshisat:Controller::User - Catalyst Controller
=head1 DESCRIPTION
Catalyst Controller.
=head1 METHODS
=cut
=head2 index
=cut

sub index :Path :Args(0) {
    my ($self, $c) = @_;
    my ($id, $name);
    my $redir = $c->config->{'redir'};
    my $param = $c->req->body_params;
    my $pass  = $param->{P1}.$param->{P2}.$param->{P3}.$param->{P4}.$param->{P5}.$param->{P6};
    
    my $rs = $c->model('DB')->resultset('User')->find({password => $pass});
    if ($rs) {
        $id = $rs->id;
        $name = $rs->username;
    }
    if ( $c->authenticate({username => $name, password => $pass}) ) {
            if ( $c->check_user_roles( qw/ admin /) ) {
                $c->response->redirect( $redir );
            }
            elsif ( $c->check_user_roles( qw/ user /) ) {
                
                $c->detach('user');
        }
    }
    if ($c->user_exists( )) {
        $c->detach('user');
    }
    $c->stash->{msg} = 'Wrong password';
    $c->stash->{template} = 'third.tt';
}
sub user :Private {
    my ($self, $c) = @_;
    my $param = $c->req->body_params;
    my $userPath = $c->config->{'userPath'};
    my ($avat, $name, $id, @info, @rightpic, @seen, $magic, $newcode, @dna, $pass, $rs, $poster, $count, $info, $code, $check);
    
    if ($param->{P1} && $param->{P2} && $param->{P3} && $param->{P4} && $param->{P5} && $param->{P6}) {
        $pass  = $param->{P1}.$param->{P2}.$param->{P3}.$param->{P4}.$param->{P5}.$param->{P6};
        $rs = $c->model('DB')->resultset('User')->find({password => $pass});
    }
    
    if ($rs) {
        $avat = $rs->avatar;
        $name = $rs->username;
        $id = $rs->id;
    }
    elsif ($param->{id}) {
        $id = $param->{id};
        $rs = $c->model('DB')->resultset('User')->find({id => $id});
        $avat = $rs->avatar;
        $name = $rs->username;
    }
    else {
        $c->stash->{msg} = 'Wrong password';
        $c->stash->{template} = 'second.tt';
    }
        
    my ($ds) = LoadFile($userPath.$id);                                 # загрузка инфы из файла юзера
    
    my @cent = split ':', $ds->{'count'}{'cent'};                       # переменная текущего центрального постера
    my $cent = $cent[0] || 0;
    my $side = $cent[1] || 'new';
    
    my $left = $ds->{'count'}{'left'}   || 0;                           # переменная левых постеров
    my $right = $ds->{'count'}{'right'} || 0;                           # переменная правых постеров
    my $rCount = $ds->{'now'}{'count'};
    
    if ( $param->{'Next_l.x'} ) {                                       # прокрутка вперёд списка предложений по 3
        $left = $left + 3;
        $left = 0             if $left > 98;
    }
    if ( $param->{'Last_l.x'} ) {                                       # прокрутка назад списка предложений по 3
        $left = $left - 3;
        $left = 96            if $left < 0;
    }
    
    if ( $param->{'Next_r.x'} ) {                                       # прокрутка вперёд списка предложений по 3
        $right = $right + 3;
        if ($right > $rCount) {
            $right = 0;
        }
    }
    if ( $param->{'Last_r.x'} ) {                                       # прокрутка назад списка предложений по 3
        $right = $right - 3;
        if ($right < 0) {
            if ($rCount > 3) {
                $right = $rCount - 1;
            }
            else {
                $right = 0;
            }
        }
    }
    
    $code = $ds->{$side}{$cent}{'code'};
    $poster = '<input id="poster" type="image" name="poster" src="/images/imgs/'.$code;                             # установка значения центрального постера
    $info = $ds->{$side}{$cent};
        
    if ( $param->{'Next_l.x'} or $param->{'Last_l.x'} ) {
        $code = $ds->{$side}{$cent}{'code'};
        $poster = '<input id="poster" type="image" name="poster" src="/images/imgs/'.$code;                         # установка значения центрального постера
        $info = $ds->{$side}{$cent};
        
    }
    if ( $param->{'Next_r.x'} or $param->{'Last_r.x'} ) {
        $code = $ds->{$side}{$cent}{'code'};
        $poster = '<img id="poster" src="/images/imgs/'.$code;                                                      # установка значения центрального постера
        $info = $ds->{$side}{$cent};
    }
    
    if    ($param->{'kadr1.x'}) {
        $side = 'new';
        $cent = $left;
        $code = $ds->{$side}{$cent}{'code'};
        $poster = '<input id="poster" type="image" name="poster" src="/images/imgs/'.$code;
        $info = $ds->{$side}{$cent};
    }
    elsif ($param->{'kadr2.x'}) {
        $side = 'new';
        $cent = $left + 1;
        $code = $ds->{$side}{$cent}{'code'};
        $poster = '<input id="poster" type="image"  name="poster" src="/images/imgs/'.$code;
        $info = $ds->{$side}{$cent};
    }                              
    elsif ($param->{'kadr3.x'}) {
        $side = 'new';
        $cent = $left + 2;
        $code = $ds->{$side}{$cent}{'code'};
        $poster = '<input id="poster" type="image"  name="poster" src="/images/imgs/'.$code;
        $info = $ds->{$side}{$cent};
    }
    elsif ($param->{'kadr4.x'}) {
        $side = 'now';
        $cent = $right + 1;
        $code = $ds->{$side}{$cent}{'code'};
        $poster = '<img id="poster" src="/images/imgs/'.$code;
        $info = $ds->{$side}{$cent};
    }
    elsif ($param->{'kadr5.x'}) {
        $side = 'now';
        $cent = $right + 2;
        $code = $ds->{$side}{$cent}{'code'};
        $poster = '<img id="poster" src="/images/imgs/'.$code;
        $info = $ds->{$side}{$cent};
    }
    elsif ($param->{'kadr6.x'}) {
        $side = 'now';
        $cent = $right + 3;
        $code = $ds->{$side}{$cent}{'code'};
        $poster = '<img id="poster" src="/images/imgs/'.$code;
        $info = $ds->{$side}{$cent};
    }

    if ($param->{'poster.x'} && $side eq 'new') {                       # выбор пользователя, интелектуальное предложение
        my ( @dna1, @dna2, @dna3, $dna1, $dna2, %dna );

        $ds->{'now'}{'count'} = $ds->{'now'}{'count'}+1 || 0;           # счётчик фильмов, выбранных пользователем
        $count = $ds->{'now'}{'count'};
        
        my $new = $ds->{'new'}{$cent};
        $ds->{'now'}{$count} = {%$new};                                 # запись нового выбора
        $ds->{'now'}{$count}{grey} = 'G';
        delete $ds->{'new'}{$cent};
        
        my $dna4 = 'a0a0';
        my $dna5 = '9999';
        $newcode = $ds->{'now'}{$count}{'code'};                            # днк пользователя
        if ($ds->{'count'}{'DNA1'}){
            my $dna1 = $ds->{'count'}{'DNA1'};
            my $dna2 = $ds->{'count'}{'DNA2'};
            
            push @dna1, split ':', $dna1;
            push @dna2, split ':', $dna2;
            
            $dna{$dna1[$_]} = $dna2[$_] for (1..@dna1-1);                    # хэш днк
            
            push @dna3, substr ($newcode, 4*$_, 4) for (1..3);
            foreach my $four1 (0..2){
                foreach my $four2 (keys %dna){
                    if ($dna3[$four1] eq $four2 ){
                        $dna{$four2} = $dna{$four2} + 1;
                        $dna3[$four1] = undef
                    } 
                }
            }
            for my $name ( @dna3 ) {
                $dna{$name} = 1001 if($name);
            }

            foreach (sort {$dna{$b}<=>$dna{$a}} keys %dna){
                $dna4 = $dna4.':'.$_;
                $dna5 = $dna5.':'.$dna{$_};
            }
            $ds->{'count'}{'DNA1'} = $dna4;
            $ds->{'count'}{'DNA2'} = $dna5;
        }
        else{
            my $stval = 1001;
            push @dna1, substr ($newcode, 4*$_, 4) for (1..3);
            $ds->{'count'}{'DNA1'} = $dna4.':'.$dna1[0].':'.$dna1[1].':'.$dna1[2];
            $ds->{'count'}{'DNA2'} = $dna5.':'.$stval.':'.$stval.':'.$stval;
        }
        $dna1 = $ds->{'count'}{'DNA1'};
        for(1..$count){                                                 # коды просмотренных фильмов
           push @seen, $ds->{'now'}{$_}{'code'} if $ds->{'now'}{$_}{'code'}
        }
        for(0..99){                                                     # коды фильмов
           push @seen, $ds->{'new'}{$_}{'code'} if $ds->{'new'}{$_}{'code'}
        }
        $magic = $c->model('DB')->magic(\@seen, \%dna);
        
        my $rs = $c->model('DB')->resultset('Films2')->find({code => $magic});
        
        my @code_coun = split ':', uc $rs->coun;
        my @code_genr = split ':', uc $rs->genr;
        my $selec = $c->config->{'select'};
        my $coun0 = $selec->{'coun'}{$code_coun[0]}[1];
        my $coun1 = $selec->{'coun'}{$code_coun[1]}[1];
        my $coun2 = $selec->{'coun'}{$code_coun[2]}[1];
        my $coun3 = $selec->{'coun'}{$code_coun[3]}[1];
        my $genr0 = $selec->{'genr'}{$code_genr[0]}[1];
        my $genr1 = $selec->{'genr'}{$code_genr[1]}[1];
        my $genr2 = $selec->{'genr'}{$code_genr[2]}[1];
        my $genr3 = $selec->{'genr'}{$code_genr[3]}[1];
        $info = $ds->{'new'}{$cent} = {
                code     => $rs->code,
                year     => $rs->year,
                coun     => $coun0.' '.$coun1.' '.$coun2.' '.$coun3,
                genr     => $genr0.' '.$genr1.' '.$genr2.' '.$genr3,
                time     => $rs->time,
                reit     => $rs->reit,
                runame   => $rs->runame,
                orname   => $rs->orname,
                director => $rs->director,
                actor1   => $rs->actor1,
                actor2   => $rs->actor2,
                actor3   => $rs->actor3,
                actor4   => $rs->actor4,
                actor5   => $rs->actor5,
                review   => $rs->review,
                
        };
        $code = $rs->code;
    }
    if    ($side eq 'new') {
        if      ($left == $cent) {
            $check = '<img id="check1" src="/images/buttons/Check.png" />';
        }
        elsif ($left+1 == $cent) {
            $check = '<img id="check2" src="/images/buttons/Check.png" />';
        }
        elsif ($left+2 == $cent) {
            $check = '<img id="check3" src="/images/buttons/Check.png" />';
        }
    }
    elsif ($side eq 'now') {
        if    ($right+1 == $cent) {
            $check = '<img id="check4" src="/images/buttons/Check.png" />';
        }
        elsif ($right+2 == $cent) {
            $check = '<img id="check5" src="/images/buttons/Check.png" />';
        }
        elsif ($right+3 == $cent) {
            $check = '<img id="check6" src="/images/buttons/Check.png" />';
        }
    }
    
    $rightpic[0] = $rightpic[1] = $rightpic[2] = '<img class="image" src="/images/buttons/blankkad.jpg" />';
    my $grey = $ds->{'now'}{$right+1}{grey};
    $rightpic[0] = '<input class="image" type="image" src="/images/imgs/'.$ds->{'now'}{$right+1}{'code'}.'kad0'.$grey.'.jpg" name="kadr4" />' if ($ds->{'now'}{$right+1}{'code'});
    $rightpic[1] = '<input class="image" type="image" src="/images/imgs/'.$ds->{'now'}{$right+2}{'code'}.'kad0'.$grey.'.jpg" name="kadr5" />' if ($ds->{'now'}{$right+2}{'code'});
    $rightpic[2] = '<input class="image" type="image" src="/images/imgs/'.$ds->{'now'}{$right+3}{'code'}.'kad0'.$grey.'.jpg" name="kadr6" />' if ($ds->{'now'}{$right+3}{'code'});

    $ds->{'count'}{'cent'} = $cent.':'.$side;
    $ds->{'count'}{'left'} = $left;
    $ds->{'count'}{'right'} = $right;
    
    DumpFile($userPath.$id, $ds);                                   # загрузка инфы ив файл юзера

    $c->stash ( 
        template => 'user.tt',
        info     => $info,
        user     => $name,
        name     => $name,
        numbL    => $left,
        numbR    => $right,        
        id       => $id,
        avat     => '<img id="avatar" src="/images/avat/'.$avat.'.jpg">',
        
        kadr1    => '<input class="image" type="image" name="kadr1" src="/images/imgs/'.$ds->{'new'}{$left  }{'code'}.'kad0.jpg" />'.$check,    # 1 постер слева
        kadr2    => '<input class="image" type="image" name="kadr2" src="/images/imgs/'.$ds->{'new'}{$left+1}{'code'}.'kad0.jpg" />'.$check,    # 2 постер слева
        kadr3    => '<input class="image" type="image" name="kadr3" src="/images/imgs/'.$ds->{'new'}{$left+2}{'code'}.'kad0.jpg" />'.$check,    # 3 постер слева
        
        poster   => '<input id="poster" type="image"  name="poster" src="/images/imgs/'.$code.'kad0.jpg" />',                                                                                                                    # центральный постер
        kadrs    => '<img class="kadr1" src="/images/imgs/'.$code.'kad1.jpg" />'.               # первый кадр
                    '<img class="kadr1" src="/images/imgs/'.$code.'kad2.jpg" />'.               # второй кадр
                    '<img class="kadr1" src="/images/imgs/'.$code.'kad3.jpg" />'.               # третий кадр
                    '<img class="kadr1" src="/images/imgs/'.$code.'kad4.jpg" />',               # четвёртый кадр
        kadr4    => $rightpic[0].$check,         # 1 постер справа
        kadr5    => $rightpic[1].$check,         # 2 постер справа
        kadr6    => $rightpic[2].$check,         # 3 постер справа
    );
}

=encoding utf8

=head1 AUTHOR

Hakimov Marat

=head1 LICENSE
23.07.2017
This library is not free software.
=cut

__PACKAGE__->meta->make_immutable;

1;
