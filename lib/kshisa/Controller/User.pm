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
    my $redir = $c->config->{'redir1'};
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
    $c->stash->{template} = 'second.tt';
}
sub user :Private {
    my ($self, $c) = @_;
    my $param = $c->req->body_params;
    my $userPath = $c->config->{'userPath'};
    my ($avat, $name, $id, @info, @codes, @rightpic, @seen, $magic, $newcode, @dna, $pass, $rs);
    
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
    my $poster = 'G.jpg';
    
    my ($ds) = LoadFile($userPath.$id);                     # загрузка инфы из файла юзера
    
    my $cent = $ds->{'count'}{'cent'} || 0;                 # переменная текущего центрального постера
    my $left = $ds->{'count'}{'left'} || 0;                 # переменная левых постеров
    my $right = $ds->{'count'}{'right'} || 0;
    my $rCount = $ds->{'now'}{'count'};
    
    if ( $param->{'Next_l.x'} ) {                                            # прокрутка вперёд списка предложений по 3
        $left = $left + 3;
        $left = 0             if $left > 98;
    }
    if ( $param->{'Last_l.x'} ) {                                            # прокрутка назад списка предложений по 3
        $left = $left - 3;
        $left = 96            if $left < 0;
    }
    
    if ( $param->{'Next_r.x'} ) {                                            # прокрутка вперёд списка предложений по 3
        $right = $right + 3;
        if ($right > $rCount) {
            $right = 0;
        }
    }
    if ( $param->{'Last_r.x'} ) {                                            # прокрутка назад списка предложений по 3
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
    
    $cent = $left     if $param->{'kadr1.x'};                                # установка значения центрального постера
    $cent = $left + 1 if $param->{'kadr2.x'};
    $cent = $left + 2 if $param->{'kadr3.x'};
    my $new = $ds->{'new'}{$cent};

    if ( $param->{'poster.x'} ) {                                           # выбор пользователя, интелектуальное предложение
        my ( @dna1, @dna2, @dna3, $dna1, $dna2, %dna );
        $ds->{'now'}{'count'} = $ds->{'now'}{'count'}+1 || 0;
        
        my $count = $ds->{'now'}{'count'};
        $ds->{'now'}{$count} = {%$new};
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
        for(0..17){                                                     # коды фильмов
           push @seen, $ds->{'new'}{$_}{'code'} if $ds->{'new'}{$_}{'code'}
        }
        $magic = $c->model('DB')->magic(\@seen, \%dna);
        
        my $rs = $c->model('DB')->resultset('Films2')->find({code=>$magic});
        
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
        $ds->{'new'}{$cent} = {
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
        $new = $ds->{'new'}{$cent};
    }
    $rightpic[0] = $ds->{'now'}{$right+1}{'code'} || 'blank';
    $rightpic[1] = $ds->{'now'}{$right+2}{'code'} || 'blank';
    $rightpic[2] = $ds->{'now'}{$right+3}{'code'} || 'blank';
    
    for(0..99){                                                         # коды фильмов
       push @codes, $ds->{'new'}{$_}{'code'} if $ds->{'new'}{$_}{'code'}
    }
    $ds->{'count'}{'cent'} = $cent;
    $ds->{'count'}{'left'} = $left;
    $ds->{'count'}{'right'} = $right;

    DumpFile($userPath.$id, $ds);                                   # загрузка инфы ив файл юзера

    $c->stash ( 
        template => 'user.tt',
        info     => $new,
        user   => $name,
        id     => $id,
        kadr   => '/images/imgs/'.$codes[$cent].'kad0.jpg',             # центральный постер фильма
        kadr1  => '/images/imgs/'.$codes[$left  ].'kad0.jpg',           # 1 постер фильма слева
        kadr2  => '/images/imgs/'.$codes[$left+1].'kad0.jpg',           # 2 постер фильма слева
        kadr3  => '/images/imgs/'.$codes[$left+2].'kad0.jpg',           # 3 постер фильма слева
        kadr11 => '/images/imgs/'.$codes[$cent].'kad1.jpg',
        kadr12 => '/images/imgs/'.$codes[$cent].'kad2.jpg',
        kadr13 => '/images/imgs/'.$codes[$cent].'kad3.jpg',
        kadr14 => '/images/imgs/'.$codes[$cent].'kad4.jpg',
        kadr5  => '/images/imgs/'.$rightpic[0].'kad0'.$poster,
        kadr6  => '/images/imgs/'.$rightpic[1].'kad0'.$poster,
        kadr7  => '/images/imgs/'.$rightpic[2].'kad0'.$poster,
        procent  => $magic,
        name => $name,
        numbL => $left,
        numbR => $right,
        avat=> '<img id="avatar" src="/images/avat/'.$avat.'.jpg">',
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
