package kshisa::Model::Html;
use Moose;
use namespace::autoclean;
use utf8;
use YAML::Any qw(LoadFile DumpFile);
extends 'Catalyst::Model';

=head1 NAME

kshisa::Model::Html - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.


=encoding utf8

=head1 AUTHOR

Marat,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
sub load {
    my ( $self, $param, $userPath, $id ) = @_;
    
    my ($ds)  = LoadFile($userPath.$id);                                # LOAD USERFILE
    
    my ($s0, $s1, $s2, $s3, $s4, $s5, $s6, $s7)=                        # SNIPETS
    ('<img class="', '<input class="', '" type="image" name="', '" src="/images/imgs/', '.jpg" />', '<div class="numb">', '</div>', 
     '" src="/images/buttons/');
     
    my ($ba, $dsl, $left, $maxl, $cout, $info);
    my ( $name, $avat ) = ($ds->{0}{0}, $ds->{0}{1});
    my ($file, $side, $right, $maxr)  = ($ds->{1}{0}{0}, $ds->{1}{0}{1}, $ds->{1}{0}{4}, $ds->{1}{2}{0});
    my $rcent = $ds->{1}{0}{5};
    my $ava = $s0.'buts" src="/images/avat/'.$avat.'.png" />';
    my $fr  = $s1.$s2.'fr'.$s7.'fr3'.$s4;
    $ba = $s1.$s2.'ba'.$s7.'ba3'.$s4    if $file == 0;
    $ba = $s1.$s2.'au'.$s7.'au3'.$s4    if $file == 1;

    ($file, $ds->{1}{0}{0}, $ba)  = (1, 1, $s1.$s2.'au'.$s7.'au3'.$s4) if $param->{'ba.x'};
    ($file, $ds->{1}{0}{0}, $ba)  = (0, 0, $s1.$s2.'ba'.$s7.'ba3'.$s4) if $param->{'au.x'};
    
    if ($file ==0 ) {
        ($dsl, $left, $maxl) = ($ds, $ds->{1}{0}{2}, $ds->{1}{1}{0});
        if ($side == 0) {
            $cout = $ds->{1}{0}{3};
            $info = $dsl->{1}{1}{$cout};
        }
        if ($side == 1) {
            $cout = $ds->{1}{0}{5};
            $info = $ds->{1}{2}{$cout};
        }
    }

    if ($file ==1) {
        $dsl = LoadFile($userPath.'all');
        ($left, $maxl) = ($ds->{1}{0}{6}, $dsl->{1}{1}{0});                                     
        if ($side == 0) {
            $cout = $ds->{1}{0}{7};
            $info = $dsl->{1}{1}{$cout};
        }
        if ($side == 1) {
            $cout = $ds->{1}{0}{5};
            $info = $ds->{1}{2}{$cout};
        }
    }

    return $name, $avat, $file, $side, $right, $maxr, $rcent, $ava, $fr, $ba, $dsl,  $left, $maxl, $cout, $info, $ds
}

sub info {
    my ( $self, $cout, $side, $left, $right, $code, $ds, $dsl, $info, $rew, $ava, $name, $id ) = @_;
    my ($s0, $s1, $s2, $s3, $s4, $s5, $s6, $s7)=                        # SNIPETS
    ('<img class="', '<input class="', '" type="image" name="', '" src="/images/imgs/', '.jpg" />', '<div class="numb">', '</div>', 
     '" src="/images/buttons/');
    my $lb = '<span>'.$s1.$s2.'Last_l'.$s7.'prev'.$s4.'</span>
              <span>'.$s1.$s2.'All_l'.$s7.'all'.$s4.'</span>
              <span>'.$s1.$s2.'Next_l'.$s7.'next'.$s4.'</span>';
    my $rb = '<span>'.$s1.$s2.'Last_r'.$s7.'prev'.$s4.'</span>
              <span>'.$s1.$s2.'All_r'.$s7.'all'.$s4.'</span>
              <span>'.$s1.$s2.'Next_r'.$s7.'next'.$s4.'</span>';
   
    my $usreit = $name.':'.$ds->{1}{2}{$cout}{$id}{'Usreit'} if $side==1;
    my $usrew = $ds->{1}{2}{$cout}{$id}{'rew'}               if $side==1;
   
    my ( $ch, $check );
    $ch = 1 if $left+1  == $cout && $side == 0;                          # CHECK
    $ch = 2 if $left+2  == $cout && $side == 0;
    $ch = 3 if $left+3  == $cout && $side == 0;
    $ch = 4 if $left+4  == $cout && $side == 0;
    $ch = 5 if $right+1 == $cout && $side == 1;
    $ch = 6 if $right+2 == $cout && $side == 1;
    $ch = 7 if $right+3 == $cout && $side == 1;
    $ch = 8 if $right+4 == $cout && $side == 1;
    
    $check = '<img id="check'.$ch.'" src="/images/buttons/Check.png" />' if $ch;  
    
    my $del = $s1.$s2.'del'.$s7.'del'.$s4 if $side == 1;

    my $clock1 = ($info->{time}-$info->{time}%60)/60;
    $clock1 = ( $clock1 < 10 ? "0" : "" ).$clock1;
    my $clock2 = $info->{time}%60;
    $clock2 = ( $clock2 < 10 ? "0" : "" ).$clock2;

    my $p1 = my $p2 = my $p3 = my $p4 = my $p5 = my $p6 = my $p7 = my $p8 =
    $s0.'image'.$s3.'blankkad0'.$s4; 
    $p1 = $s1.'image'.$s2.'kadr1'.$s3.$dsl->{1}{1}{$left+1}{'code'}.'kad0'.$s4 if ($dsl->{1}{1}{$left+1});
    $p2 = $s1.'image'.$s2.'kadr2'.$s3.$dsl->{1}{1}{$left+2}{'code'}.'kad0'.$s4 if ($dsl->{1}{1}{$left+2});
    $p3 = $s1.'image'.$s2.'kadr3'.$s3.$dsl->{1}{1}{$left+3}{'code'}.'kad0'.$s4 if ($dsl->{1}{1}{$left+3});
    $p4 = $s1.'image'.$s2.'kadr4'.$s3.$dsl->{1}{1}{$left+4}{'code'}.'kad0'.$s4 if ($dsl->{1}{1}{$left+4});
    
    my $l = $s5.($left+1).$s6.$p1.$s5.($left+2).$s6.$p2.$s5.($left+3).$s6.$p3.$s5.($left+4).$s6.$p4.$s5.$s6;                # LEFT PICS
    my $p = $s1.'poster'.$s2.'poster'.$s3.$code.'kad0'.$s4;                                            # POSTER
    my $k = $s0.'kadr1'.$s3.$code.'kad1.jpg"/>'.                                                       # FRAMES
            $s0.'kadr1'.$s3.$code.'kad2.jpg"/>'.
            $s0.'kadr1'.$s3.$code.'kad3.jpg"/>'.
            $s0.'kadr1'.$s3.$code.'kad4.jpg"/>';
    $p5 = $s1.'image'.$s2.'kadr5'.$s3.$ds->{1}{2}{$right+1}{'code'}.'kad0'.$ds->{1}{2}{$right+1}{'grey'}.$s4 if ($ds->{1}{2}{$right+1});
    $p6 = $s1.'image'.$s2.'kadr6'.$s3.$ds->{1}{2}{$right+2}{'code'}.'kad0'.$ds->{1}{2}{$right+2}{'grey'}.$s4 if ($ds->{1}{2}{$right+2});
    $p7 = $s1.'image'.$s2.'kadr7'.$s3.$ds->{1}{2}{$right+3}{'code'}.'kad0'.$ds->{1}{2}{$right+3}{'grey'}.$s4 if ($ds->{1}{2}{$right+3});
    $p8 = $s1.'image'.$s2.'kadr8'.$s3.$ds->{1}{2}{$right+4}{'code'}.'kad0'.$ds->{1}{2}{$right+4}{'grey'}.$s4 if ($ds->{1}{2}{$right+4});

    my $r = $s5.($right+1).$s6.$p5.$s5.($right+2).$s6.$p6.$s5.($right+3).$s6.$p7.$s5.($right+4).$s6.$p8.$check.$s5.$s6;       # RIGT PICS

    my $full = $p.'<h3>IMDB: '.$info->{reit}.'&nbsp;&nbsp;&nbsp;'.$usreit.'</h3><div class="foto">'.$k.$rew
      .'<hr><h3>'.$info->{year}.
      '<input type="checkbox" name="'.$info->{year}.'" 
      />&nbsp;&nbsp;&nbsp;'.$info->{coun}.'</h3></p><hr>'
      .'<H2>'.$info->{runame}.'</p>'.$info->{orname}.'</H2>'.$del.'</div> </p>'
      .'<hr>'.$info->{genr}.'</p><hr>
      Producer (Режисёр):'.$info->{director}.'</p><hr>Staring (В главных ролях):'
      .$info->{actor1}.$info->{actor2}.$info->{actor3}.$info->{actor4}.$info->{actor5}.'</p><hr>'.$info->{review}.'</p><hr>'.
      $s0.'start'.$s7.'start'.$s4.
      '<ul><li class="hours"></li><li class="point">:</li><li class="min"> </li>
      <li class="point">:</li><li class="sec"> </li></ul><span id="hours">'.$clock1.'</span>
      ::<span id="minut">'.$clock2.'</H2></span><ul><li class="hours1"></li><li class="point">
      :</li><li class="min1"></li><li class="point">:</li><li class="sec"> </li></ul>'.
      $s0.'stop'.$s7.'stop'.$s4.
      '<hr><div id="Avat">'.$ava.'</div><div id="Name">'.$name.'</div>'.$usrew.'<hr>';
      
    return  $l, $full, $r, $lb, $rb ;
}

sub dump {
    my ( $self, $userPath, $id, $ds, $file, $left, $side, $right, $cout ) = @_;
  
    if ($file ==0) {
        $ds->{1}{0}{2} = $left;                                         # LEFT PICS VAR
        $ds->{1}{0}{3} = $cout if $side == 0;
        $ds->{1}{0}{5} = $cout if $side == 1;
    }
    elsif ($file ==1) {
        $ds->{1}{0}{6} = $left;                                         # LEFT PICS VAR
        $ds->{1}{0}{7} = $cout if $side == 0;
        $ds->{1}{0}{5} = $cout if $side == 1;
    }
    ($ds->{1}{0}{0}, $ds->{1}{0}{1}, $ds->{1}{0}{4}) = ($file, $side, $right);

    DumpFile($userPath.$id, $ds);                                       # DUMP INFO IN USERFIle
}
__PACKAGE__->meta->make_immutable;

1;
