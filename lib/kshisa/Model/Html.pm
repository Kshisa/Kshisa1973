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

my $s0 = '<img class="';                                                # SNIPETS
my $s1 = '"><input class="';
my $s2 = '" type="image" name="';
my $s3 = '" src="/images/imgs/';
my $s4 = '.jpg" /></a>';
my $s5 = '<div class="numb">';
my $s6 = '</div>';
my $s7 = '" src="/images/buttons/';
my $s8 = '<a title="';
my $s9 = '.png" /></a>';
sub _code {
    my ( $userPath ) = @_;
    my (@codes, $codes);
    my ($ds) = LoadFile($userPath.'best');
    push @codes, $ds->{$_}{'code'} for (1..100);
    foreach (@codes) {
        $codes = $codes.'<img src="/images/imgs/'.$_.'kad3.jpg">';
    }
    return $codes;
}
sub _char {
    my $pass;
    my @chars = split( " ","A B C D E F G H I J K L" );
    foreach my $line (1..6) {
        $pass = $pass.'<hr/>';
        foreach my $char (@chars) {
            $pass = $pass.'<label><input type="radio" name="P'.$line.'"value="'.$char.'" />'.$char.'</label>' if $line != 6;
            $pass = $pass.'<label><input type="radio" name="P'.$line.'" onclick="subm1()" value="'.$char.'" />'.$char.'</label>' if $line == 6;
        }
    }
    return $pass
}
sub start {
    my ( $self, $userPath ) = @_;
    my $text = '<hr>
                <div id="user">
                <div class="fadein">'._code($userPath).'</div>
                    <div id="mess">New User? &nbsp&nbsp&nbsp
                        <input name="New" onclick="subm()" value="Yes" id="NY" type="radio">
                        <label for="NY">Yes&nbsp;&nbsp;</label>
                        <input name="New" onclick="subm()" value="No" id="NN" type="radio">
                        <label for="NN">No&nbsp;&nbsp;</label>
                    </div>
                </div>';
    return $text
}
sub not_new {
    my $text = '<hr>
                <div id="user">
                <div id="dash"><p/><p/><hr><hr>'._char.'<hr><hr><hr><p/></div>
                <div id="mess">Enter your password<p>
                </div></div>';
    return $text
}
sub yes_new {
    my ( $self, $userPath ) = @_;
    my $avat;
    my @ava = split( " ","001 002 003 004 005 006 007 008 009 010 011 012" );
    foreach (@ava) {
        $avat = $avat.'<input type="image" class="ava" src="/images/avat/ava'.$_.'.jpg" name="ava'.$_.'" />&nbsp';
    }
    my $text = '<hr>
                <div id="user"><div class="fadein">'._code($userPath).'</div>
                <div id="mess"><p>
                 1. Enter Your Name: &nbsp&nbsp&nbsp&nbsp 2. Enter Your Email:<p>
                 <input type="text" name="name" class="userid"/>&nbsp&nbsp&nbsp&nbsp
                 <input type="text" name="mail" class="userid"/><p>
                 3. Choose Your Avatar<p>'.$avat.'</div>';
    return $text
}
sub enter {
    my ( $self, $pass ) = @_;
    my $text = '<hr>
                <div id="user">
                <div id="dash"><p/><p/><hr><hr>'._char.'<hr><hr><hr><p/></div>
                <div id="mess">
                Welcome to Kshisa!<p>
                Your  oun video collection<p>
                Your password:<p>'.$pass.
                '<p>Enter your password on dashboard<p>
                check buttons before letter of your password<p>
                from top to bottom
                </div></div>';
    return $text
}
sub forgot {
    my ( $self, $userPath ) = @_;
    my $avat;
    my @ava = split( " ","001 002 003 004 005 006 007 008 009 010 011 012" );
    foreach (@ava) {
        $avat = $avat.'<input type="image" class="ava" src="/images/avat/ava'.$_.'.jpg" name="ava'.$_.'" />&nbsp';
    }
    my $text = '<hr>
                <div id="user"><div class="fadein">'._code($userPath).'</div>
                <div id="mess"><p>
                You forgot to type your name or email<p>
                 1. Enter Your Name: &nbsp&nbsp&nbsp&nbsp 2. Enter Your Email:<p>
                 <input type="text" name="name" class="userid"/>&nbsp&nbsp&nbsp&nbsp
                 <input type="text" name="mail" class="userid"/><p>
                 3. Choose Your Avatar<p>'.$avat.'</div>';
    return $text
}
sub wrong {
    my $text = '<hr>
                <div id="user">
                <div id="dash"><p/><p/><hr><hr>'._char.'<hr><hr><hr><p/></div>
                <div id="mess">Wrong password</div></div>';
    return $text
}
sub micro {
    my ($self, $ds, $key) = @_;
    my ($n, $micro);
    for(1..$ds->{1}{1}{0}) {
        if ($key eq $ds->{1}{1}{$_}{'year'}) {
            $micro = $micro.$s8.$ds->{1}{1}{$_}{'runame'}.$s1.'imageall'.$s2.$_.$s3.$ds->{1}{1}{$_}{'code'}.'kad0'.$s4;
            $n++;
        }
    }
    $micro = '<hr><div id="pics">'.$micro.'</div>';
    return $micro
}
sub rew {
    my ($self, $ds, $cout, $id) = @_;
    my $radio;
    $radio = $radio.'<label><input type="radio" name="usreit" value="'.$_.'" />'.$_.'</label>' for ( 1..9 );
    my $rew = '&nbsp;&nbsp;&nbsp;<textarea name="rew" cols="80" rows="4" placeholder="Review">'.
    $ds->{1}{2}{$cout}{$id}{'rew'}.'</textarea>'.'<p>IMDB ='.
    $ds->{1}{2}{$cout}{'reit'}.'&nbsp;&nbsp;&nbsp;Your ='.$radio.'</p>';
    return $rew 
}
sub load {
    my ( $self, $param, $userPath, $id ) = @_;

    my ($ds)  = LoadFile($userPath.$id);                                # LOAD USERFILE
 
    my ($ba, $lo, $dsl, $left, $maxl, $right, $maxr, $cout, $info, $n);
    my ($name, $avat) = ($ds->{0}{0}, $ds->{0}{1});
    my $ava = $s0.'buts" src="/images/avat/'.$avat.'.png" />';
    # USER CLOCK KSHISA
    my $user = '<input type="hidden" name="id" value="'.$id.'" />       
                <div id="Avat">'.$ava.'</div>
                <div id="Name">'.$name.'</div>                          
                <div class="clock"><div id="Date"></div>
                <ul> <li class="hours"> </li>
                <li class="point">:</li>
                <li class="min"> </li>
                <li class="point">:</li>
                <li class="sec"> </li></ul></div></div>
                <input type="image" id="kshisa" name="kshisa" src="/images/buttons/kshisa1.png"/>';
    
    my ($file, $side, $rcent, $love)  = ($ds->{1}{0}{0}, $ds->{1}{0}{1}, $ds->{1}{0}{0}, $ds->{1}{0}{10});

    $ba = $s8.$s1.$s2.'au'.$s7.'au1'.$s4    if $file == 0;
    $ba = $s8.$s1.$s2.'ba'.$s7.'ba1'.$s4    if $file == 1;
    
    $lo = $s8.$s1.$s2.'se'.$s7.'gla'.$s4     if $love == 0;    
    $lo = $s8.$s1.$s2.'lo'.$s7.'fav1'.$s4    if $love == 1;

    ($file, $ds->{1}{0}{0}, $ba)  = (1, 1, $s8.$s1.$s2.'ba'.$s7.'ba1'.$s4)  if $param->{'au.x'};
    ($file, $ds->{1}{0}{0}, $ba)  = (0, 0, $s8.$s1.$s2.'au'.$s7.'au1'.$s4)  if $param->{'ba.x'};
    
    ($love, $ds->{1}{0}{10}, $lo)  = (0, 0, $s8.$s1.$s2.'se'.$s7.'gla'.$s4)  if $param->{'lo.x'};
    ($love, $ds->{1}{0}{10}, $lo)  = (1, 1, $s8.$s1.$s2.'lo'.$s7.'fav1'.$s4)  if $param->{'se.x'};

    if ($file == 0) {
        ($dsl, $left, $maxl) = ($ds, $ds->{1}{0}{2}, $ds->{1}{1}{0});
        if ($side == 0) {
            $cout = $ds->{1}{0}{3};
            $info = $dsl->{1}{1}{$cout};
        }
    }
    if ($file == 1) {
        $dsl = LoadFile($userPath.'all');
        ($left, $maxl) = ($ds->{1}{0}{6}, $dsl->{1}{1}{0});                                     
        if ($side == 0) {
            $cout = $ds->{1}{0}{7};
            $info = $dsl->{1}{1}{$cout};
        }
    }
    if ($love == 0) {
        ($right, $maxr, $n) = ($ds->{1}{0}{4},  $ds->{1}{2}{0}, 2);
        if ($side == 1) {
            $cout = $ds->{1}{0}{5};
            $info = $ds->{1}{2}{$cout};
            
        }
    }
    if ($love == 1) {
        ($right, $maxr, $n) = ($ds->{1}{0}{8},  $ds->{1}{4}{0}, 4);
        if ($side == 1) {
            $cout = $ds->{1}{0}{9};
            $info = $ds->{1}{4}{$cout};
        }
    }

    return $user, $file, $side, $right, $maxr, $rcent, $ava, $lo, $ba, $dsl, 
        $left, $maxl, $cout, $info, $ds, $love, $n;
}

sub info {
    my ( $self, $cout, $side, $left, $rigt, $ds, $dsl, $info, $rew, $path, $message, $usreit, $usrew, $lo, $ba, $n, $pl ) = @_;

    if ($side == 1) {
        for (1..$info->{0}) { 
            $usrew  = $usrew.'<p>'.'['.$info->{$_}{'time'}.']&nbsp;&nbsp;'.$info->{$_}{'rewi'}.'<hr>';
        }
        $usreit = $info->{'usreit'};
    }
=cut
    my $p = $cout/4 - int(coutb/4);
    if    ( $p == 0)    { $left = $cout-4}
    elsif ( $p == 0.75) { $left = $cout-3}
    elsif ( $p == 0.5)  { $left = $cout-2}
    elsif ( $p == 0.25) { $left = $cout-1}
=cut
    my $code = $info->{code};
    
    my $clock1 = ($info->{time}-$info->{time}%60)/60;                   # START-STOP CLOCK
    $clock1 = ( $clock1 < 10 ? "0" : "" ).$clock1;
    my $clock2 = $info->{time}%60;
    $clock2 = ( $clock2 < 10 ? "0" : "" ).$clock2;
    my $clock = 'BEGIN <ul><li class="hours"></li><li class="point">:</li><li class="min"> </li>            
      <li class="point">:</li><li class="sec"> </li></ul><span id="hours">'.$clock1.'</span>
      ::<span id="minut">'.$clock2.'</H2></span><ul><li class="hours1"></li><li class="point">
      :</li><li class="min1"></li><li class="point">:</li><li class="sec"> </li></ul> END';

    my $title = 'orname';
    my $pl1 = '<span><input name="Address" type="text" value="';
    my $pl2 = ' "size="44"></span>&nbsp;&nbsp;
                <span><input name="find" type="submit" value="find" id="but"></span>&nbsp;&nbsp;';
    my $pl3 = '&nbsp;&nbsp;<span><input name="Info" type="text" value="" size="3"></span>&nbsp;&nbsp;';
    my $pl4; 
    my $pl5 = '<span><input name="ID" type="submit" value="find" id="but"></span>';
    my $pl6 = '<span><input name="edit" type="submit" value="edit" id="but"></span>';
    my $pl7 = '<span><input name="down" type="submit" value="down" id="but"></span>';
    my $pl8 = '<span><input name="add" type="submit" value="add" id="but"></span>';
    my $pl9 = '<span><input name="find4" type="submit" value="4" id="but"></span>';
    my $pl10 = '<span><input name="sql" type="submit" value="sql" id="but"></span>';
    $pl4 = $pl5.$pl6.$pl7.$pl10 if ( $pl == 0 );
    $pl4 = $pl5                 if ( $pl == 1 );
    $pl4 = $pl8                 if ( $pl == 2 );
    $pl4 = $pl9                 if ( $pl == 3 );

    my ( $ch, $check, $p, $k );
    $ch = 1 if $left+1  == $cout && $side == 0;                         # CHECK
    $ch = 2 if $left+2  == $cout && $side == 0;
    $ch = 3 if $left+3  == $cout && $side == 0;
    $ch = 4 if $left+4  == $cout && $side == 0;
    $ch = 5 if $rigt+1  == $cout && $side == 1;
    $ch = 6 if $rigt+2  == $cout && $side == 1;
    $ch = 7 if $rigt+3  == $cout && $side == 1;
    $ch = 8 if $rigt+4  == $cout && $side == 1;

    $check = '<img id="check'.$ch.'" src="/images/buttons/Check.png" />' if $ch;

    my $buts;
    $buts = $s8.$s1.$s2.'g'.$s7.'g'.$s4.'&nbsp;&nbsp'.$s8.$s1.$s2.'h'.$s7.'h'.$s9.'&nbsp;&nbsp'             if $side == 0;
    $buts = $s8.$s1.$s2.'phon'.$s7.'phon.png" /> &nbsp;&nbsp'.$s8.$s1.$s2.'del'.$s7.'del'.$s4.'&nbsp;&nbsp' if $side == 1;

    my $lb = '<hr><div class="left_col">
              <span>'.$s8.$s1.$s2.'Last_l'.$s7.'prev'.$s4.'</span>'.$ba.
             '<span>'.$s8.$s1.$s2.'Next_l'.$s7.'next'.$s4.'</span>';
    my $rb = '<span>'.$s8.$s1.$s2.'Last_r'.$s7.'prev'.$s4.'</span>'.$lo.
             '<span>'.$s8.$s1.$s2.'Next_r'.$s7.'next'.$s4.'</span>';

    my $p1 = my $p2 = my $p3 = my $p4 = my $p5 = my $p6 = my $p7 = my $p8 =
    $s0.'image'.$s3.'blankkad0'.$s4; 
    
    $p1 = $s8.$dsl->{1}{1}{$left+1}{$title}.$s1.'image'.$s2.'kadr1'.$s3.$dsl->{1}{1}{$left+1}{'code'}.'kad0'.$s4 if ($dsl->{1}{1}{$left+1});
    $p2 = $s8.$dsl->{1}{1}{$left+2}{$title}.$s1.'image'.$s2.'kadr2'.$s3.$dsl->{1}{1}{$left+2}{'code'}.'kad0'.$s4 if ($dsl->{1}{1}{$left+2});
    $p3 = $s8.$dsl->{1}{1}{$left+3}{$title}.$s1.'image'.$s2.'kadr3'.$s3.$dsl->{1}{1}{$left+3}{'code'}.'kad0'.$s4 if ($dsl->{1}{1}{$left+3});
    $p4 = $s8.$dsl->{1}{1}{$left+4}{$title}.$s1.'image'.$s2.'kadr4'.$s3.$dsl->{1}{1}{$left+4}{'code'}.'kad0'.$s4 if ($dsl->{1}{1}{$left+4});
    my $l = $s5.($left+1).$s6.$p1.$s5.($left+2).$s6.$p2.$s5.($left+3).$s6.$p3.$s5.($left+4).$s6.$p4.$s5.$s6.'</div><div class="center_col">';        # LEFT PICS
    if (!$path) {
        $p = $s0.'post'.$s3.$code.'kad0.jpg"/>';                        # POSTER
        $k = $s0.'kadr'.$s3.$code.'kad1.jpg"/>'.                        # FRAMES
             $s0.'kadr'.$s3.$code.'kad2.jpg"/>'.
             $s0.'kadr'.$s3.$code.'kad3.jpg"/>'.
             $s0.'kadr'.$s3.$code.'kad4.jpg"/>';
    }
    else {
        $p = $s0.'post'.$path->[0].'.jpg"/>';                           # POSTER
        $k = $s0.'kadr'.$path->[1].'.jpg"/>'.                           # FRAMES
             $s0.'kadr'.$path->[2].'.jpg"/>'. 
             $s0.'kadr'.$path->[3].'.jpg"/>'. 
             $s0.'kadr'.$path->[4].'.jpg"/>';
    }
    $p5 = $s8.$ds->{1}{$n}{$rigt+1}{$title}.$s1.'image'.$s2.'kadr5'.$s3.$ds->{1}{$n}{$rigt+1}{'code'}.'kad0'.$ds->{1}{$n}{$rigt+1}{'grey'}.$s4 if ($ds->{1}{$n}{$rigt+1});
    $p6 = $s8.$ds->{1}{$n}{$rigt+2}{$title}.$s1.'image'.$s2.'kadr6'.$s3.$ds->{1}{$n}{$rigt+2}{'code'}.'kad0'.$ds->{1}{$n}{$rigt+2}{'grey'}.$s4 if ($ds->{1}{$n}{$rigt+2});
    $p7 = $s8.$ds->{1}{$n}{$rigt+3}{$title}.$s1.'image'.$s2.'kadr7'.$s3.$ds->{1}{$n}{$rigt+3}{'code'}.'kad0'.$ds->{1}{$n}{$rigt+3}{'grey'}.$s4 if ($ds->{1}{$n}{$rigt+3});
    $p8 = $s8.$ds->{1}{$n}{$rigt+4}{$title}.$s1.'image'.$s2.'kadr8'.$s3.$ds->{1}{$n}{$rigt+4}{'code'}.'kad0'.$ds->{1}{$n}{$rigt+4}{'grey'}.$s4 if ($ds->{1}{$n}{$rigt+4});
    my $r = $s5.($rigt+1).$s6.$p5.$s5.($rigt+2).$s6.$p6.$s5.($rigt+3).$s6.$p7.$s5.($rigt+4).$s6.$p8.$check.$s5.$s6.'</div>' ;         # RIGT PICS

    my $full = $pl1.$message.$pl2.$cout.$pl3.$dsl->{1}{1}{0}.'&nbsp;&nbsp;'.$pl4.'<hr>'.$p.
    '<div class="my-rating-2" data-rating="'.($info->{reit}/100).'"></div>'.$usreit.
    '<div class="foto">'.$k.'<hr>
     <h3>'.$info->{year}.'<input type="checkbox" onchange="subm2(this)" name="'.$info->{year}.'"/>&nbsp;&nbsp;&nbsp;'.$info->{coun}.'</h3></p><hr>'
      .'<H2>'.$info->{runame}.'</p>'.$info->{orname}.'</H2><hr>'
      .'</div> </p>'.$info->{genr}.'</p><hr>
      Director:'.$info->{director}.'</p><hr>
      Stars:'.$info->{actor1}.'&nbsp;'.$info->{actor2}.'&nbsp;'.$info->{actor3}.'&nbsp;'.$info->{actor4}.'&nbsp;'.$info->{actor5}.'</p><hr>'
      .$info->{review}.'</p><hr>'.
      $clock.'<hr>'
      .$buts.'<hr>'.$rew.$usrew.'</div><div class="right_col">';
      
    return  $l, $full, $r, $lb, $rb;
}
sub conf {
my ($self, $cols1, $select, $form_path) = @_;

my $conf = qq( 
 {"elements"  :[{"type":"Block", "tag": "div class=left_col"},
                {"type":"Block",  "tag": "div class=center_col",
                 "elements":[{
                 "type":"Block",  "tag": "table", "elements":[
                 {"type":"Block",  "tag": "tr", "elements":[{"type":"Submit", "name":"find0",    "container_tag":"span", "value":"1-create", "id":"but"},
                                                            {"type":"Submit", "name":"find1",    "container_tag":"span", "value":"1 - edit", "id":"but"},
                                                            {"type":"Text",   "name":"Address", "container_tag":"span", "size":"65"},
                                                            {"type":"Submit", "name":"find2",    "container_tag":"span", "value":"2", "id":"but"},
                                                          ]},);
for my $i ( 1..26 ) {
    if ($i eq 'Select') {
        $conf = $conf.qq(
            {"type":"Block",  "tag": "tr",
                "elements":
                    [{"type":"Block",  "tag": "td", "element":{"label":"@$cols1[$i]", "type":"@$cols1[$i]","name":"@$cols1[$i]_a", "options":[
            );
        my $name = @$cols1[$i];
        chop $name;
        foreach my $sel (sort keys %{$select->{$name}}){
            $conf = $conf.qq({"value":"$select->{$name}->{$sel}", "label":"$sel"},);
        }
        $conf = $conf.qq(]}},
        {"type":"Block",  "tag": "td", "element":{"label":"@$cols1[$i]", "type":"@$cols1[$i]","name":"@$cols1[$i]_b", "options":[
        );
        foreach my $sel (sort keys %{$select->{$name}}){
            $conf = $conf.qq({"value":"$select->{$name}->{$sel}", "label":"$sel"},);
        }
        $conf = $conf.qq(]}}],},)
    }
    elsif ($i eq 'Text') {
        $conf = $conf.qq(
        {"type":"Block",  "tag": "tr",
        "elements":
        [{"type":"Block",  "tag": "td", "element":{"label":"@$cols1[$i]", "type":"@$cols1[$i]","name":"@$cols1[$i]_a", "size":"60"}},
        {"type":"Block",  "tag": "td", "element":{"label":"@$cols1[$i]", "type":"@$cols1[$i]","name":"@$cols1[$i]_b", "size":"60"}}],
        },)
    }
    elsif ($i eq 'Textarea') {
        $conf = $conf.qq(
        {"type":"Block",  "tag": "tr",
        "elements":
        [{"type":"Block",  "tag": "td", "element":{"label":"@$cols1[$i]", "type":"@$cols1[$i]","name":"@$cols1[$i]_a", "cols":"60", "rows":"7"}},
        {"type":"Block",  "tag": "td", "element":{"label":"@$cols1[$i]", "type":"@$cols1[$i]","name":"@$cols1[$i]_b", "cols":"60", "rows":"7"}}],
        },)
    }
}
$conf = $conf.qq( ]}]} );

my $filename = $form_path.'find4444.json';
open my $fh, '>', $filename;
print $fh $conf;
}
__PACKAGE__->meta->make_immutable;

1;
