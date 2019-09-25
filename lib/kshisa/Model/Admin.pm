package kshisa::Model::Admin;
use Moose;
use utf8;
use namespace::autoclean;
use LWP;
use LWP::Simple qw(getstore);
use YAML::Any qw(LoadFile DumpFile);
use Image::Magick;
use File::Copy;
extends 'Catalyst::Model';

=head1 NAME

kshisa::Model::Admin - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.


=encoding utf8

=head1 AUTHOR

Marat,,,

=head1 LICENSE

This library is not free software. You can't redistribute it and/or modify
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
my $s10 = '" src="/images/avat/';
sub _sort {
    my ($glob) = @_;
    my @glob = @$glob;
    
    my @info = sort {                                                     # SORT BY YEAR AND REIT
        $b->[0][4] <=> $a->[0][4]
        ||
        $b->[0][3] <=> $a->[0][3]
    } @glob;
    return \@info
}
sub start {
    my ($self, $img_path3, $userPath, $cols1, $numb, $Base) = @_;
    my ($left, $rigt, @cols);
    my $dba0 = LoadFile($Base.'0');
    my $dba2 = LoadFile($Base.'2');
    $numb = @$dba2-1 if $numb < 0;
    $numb = 0 if $numb > @$dba2-1;
    opendir (my $dh, $img_path3) || die "can't opendir $img_path3: $!";
    my @files = grep { /^\d+_.*?\.jpg/ } readdir($dh);
    for ( 0..6 ) {
        $left = $left.'<div class="numb">'.($_+1).'</div><input type="image" class="image1" name="'
        .$files[$_].'" src="/images/find/'.$files[$_].'">' if $files[$_];
    }
    for ( 0..4 ) {
        $rigt = $rigt.'<input type="image" class="image1" name="'.$_.'" src="/images/imgs/'
        .$dba2->[$numb][0][0].'kad'.$_.'.jpg" />';
    }
      
    my @cols1;
    push @cols1, $_ foreach $dba0->[1];
    my $size = $#{$cols1[0]}+1;
   
    for my $fild (0..$size) {
        for my $y (0..$dba0->[1][$fild][3]) {
            $cols[$fild][$y] = $dba2->[$numb][$fild][$y] if $dba2->[$numb][$fild][$y];  
        }
    }

    return $left, $rigt, \@cols, $numb
}
sub mail {
    my ($self, $find, $img_path3, $userPath, $cols, $cols1, $cols2, $mail) = @_;
    my (@film0, @film1, @cols0, @cols1, @cols2, @pics, $micro, $left, $rigt);
    my $browser = LWP::UserAgent->new;
    my $UserAgent = 'Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:44.0) Gecko/20100101 Firefox/44.0';
    unlink glob "$img_path3*.*";
    if ($find =~ /^(\d+_.*?)\.jpg/) {
        $find = $1;
    }
    else {
        my $response = $browser->get($mail->[0].$find, 'User-Agent' => $UserAgent);
        for ($response->decoded_content) {
            while ( $_ =~ m{$mail->[1]}mg) {
               push @film0, $1;
               push @film1, $2;
            }
        }
        $find = $film1[0];
        for ( 0..5 ) {
            getstore($mail->[2].$film0[$_].'/', $img_path3.$film1[$_].'.jpg') if $film1[$_];
            $left = $left.'<div class="numb">'.($_+1).'</div><input type="image" class="image1" name="'
            .$film1[$_].'" src="/images/find/'.$film1[$_].'.jpg">' if $film1[$_];
        }
    }
    my $response = $browser->get($mail->[3].$find, 'User-Agent' => $UserAgent);

    open my $fh, '>', '/home/marat/Users/mail.html';
    print $fh $response->decoded_content; 

    for ($response->decoded_content) {
        for my $fild (0..@$cols1) {
            for my $y (0..$cols1->[$fild][0]) {
                if ($_ =~ m{$cols1->[$fild][7]}mg) {
                    my $z = 0;
                    for my $x (0..$cols1->[$fild][0]) {
                        $z = 1 if $cols1[$fild][$x] eq $1
                    }
                    $cols1[$fild][$y] = $1 if $z == 0;  
                }
            }
        }
    }
    $cols1[3][0] =~ tr[.][]d;
    $cols1[3][0] =  $cols1[3][0].0;

    my @time = split ':', $cols1[5][0];
    $cols1[5][0] = $time[0]*60 + $time[1];
    
    $cols1[7][0] =~ tr[&nbsp;][ ]d;
    $cols1[7][0] =~ tr[&mdash;]["—]d;
    $cols1[7][0] =~ tr[&hellip;]["..."]d;
    #$cols1[7][0] =~ tr[ rquo]["]d;
    #$cols1[7][0] =~ tr[.quo]["]d;
    $cols1[2][0] =~ tr[&#183;][-]d;
    $cols1[2][0] =~ tr[&#39;][']d;
    my $x = 1;
    my @pice;                                                           # LOAD PICTURES
    $cols2[0][0] = $find;
    for ($response->decoded_content) { 
        $cols2[1][0] = $1 if $_ =~ m{$cols2->[2][7]};
        my $numb  = $1    if $_ =~ m{$cols2->[1][7]};
        for my $p (0..$numb*2+3) {
            if ($_ =~ m{$cols2->[3][7]}g && $p > 3 && $p%2 == 0) {
                push @pice, $1;
                getstore($1, $img_path3.$x.'.jpg');
                my $image = Image::Magick->new;
                $image->Read($img_path3.$x.'.jpg');
                $image->Resize(geometry => '330x210');
                $image->Crop(width=>272, height=>178);
                $image->Write($img_path3.$x.'.jpg');
                $micro = $micro.'<img name="'.$x.'" src="/images/find/'.$x.'.jpg" /><input type="checkbox" name="'
                    .$x.'" />';
                $x++;
            }
        }
        $micro = '<hr><div id="pics">'.$micro.'<input type="submit" name="find3" value="3" style="width: 40px;" />
            </div>';
        push @cols2, [@pice];
    }
    my $n;
    my $dba = LoadFile($userPath.'yaml');
    for my $numb (1..@$dba) {                                           # SEARCH BY RUNAME
        if ($dba->[$numb][1][0] eq $cols1[1][0]) {
            $n = $numb;
            for my $fild (0..@$cols1) {
                for my $y (0..$cols1->[$fild][0]) {
                    $cols0[$fild][$y] = $dba->[$numb][$fild][$y] if $dba->[$numb][$fild][$y];  
                }
            }
            for ( 0..4 ) {
                $rigt = $rigt.'<input type="image" class="image1" name="'.$_.'" src="/images/imgs/'
                .$dba->[$numb][0][0].'kad'.$_.'.jpg" />';
            }           
        }
    }
    DumpFile($userPath.'temp1', [@cols1]);
    DumpFile($userPath.'temp2', [@cols2]);
    return $micro, $left, $rigt, \@cols1, \@cols0, $n
}
sub conf {
    my ($self, $cols, $Selt, $form_path) = @_;
    my $size = @$cols;
    my $conf = qq( 
    {"elements"  :[{"type":"Block",  "tag": "div class=center_col",
                 "elements":[{
                 "type":"Block",  "tag": "table", "elements":[
                 {"type":"Block",  "tag": "tr", "elements":[ {"type":"Text",   "name":"Address", "container_tag":"span", "size":"44",     "id":"Address"},
                                                             {"type":"Submit", "name":"conf",    "container_tag":"span", "value":"conf",  "id":"but"},
                                                             {"type":"Submit", "name":"sql",     "container_tag":"span", "value":"sql",   "id":"but"},
                                                             {"type":"Submit", "name":"mongo",   "container_tag":"span", "value":"mongo", "id":"but"},
                                                             {"type":"Submit", "name":"dba",     "container_tag":"span", "value":"dba",   "id":"but"},
                                                             {"type":"Submit", "name":"best",    "container_tag":"span", "value":"best",  "id":"but"}]},);

    for my $x (0..$size) {
        if ($cols->[$x][2] eq 'S' && $cols->[$x][3] eq 'v') {
            my $name = $cols->[$x][1];
            for my $y (0..$cols->[$x][0]) {
                $conf = $conf.qq(
                {"type":"Block",  "tag": "tr",
                "elements":
                [{"type":"Block", "tag": "td", "element":{"label":"$cols->[$x][1]", "type":"Select", "name":"$y$cols->[$x][1]_a", "options":[
                );
                my $size2 = @{$Selt->{$name}};
                for my $y (0..$size2) {
                    $conf = $conf.qq({"value":"$Selt->{$name}[$y][2]", "label":"$Selt->{$name}[$y][2]"},);
                }
                $conf = $conf.qq(]}},
                {"type":"Block",  "tag": "td", "element":{"label":"$cols->[$x][1]", "type":"Select", "name":"$y$cols->[$x][1]_b", "options":[
                );
                for my $y (0..$size2) {
                    $conf = $conf.qq({"value":"$Selt->{$name}[$y][2]", "label":"$Selt->{$name}[$y][2]"},);
                }
                $conf = $conf.qq(]}}],},)
            }
        }
    }
    for my $x (0..$size) {
        if ($cols->[$x][2] eq 'T' && $cols->[$x][3] eq 'v') {
            for my $y (0..$cols->[$x][0]) {
                $conf = $conf.qq(
                {"type":"Block",  "tag": "tr",
                "elements":
                [{"type":"Block",  "tag": "td", "element":{"id":"kad", "label":"$cols->[$x][1]", "type":"Text","name":"$y$cols->[$x][1]_a", "size":"60"}},
                 {"type":"Block",  "tag": "td", "element":{"id":"kad", "label":"$cols->[$x][1]", "type":"Text","name":"$y$cols->[$x][1]_b", "size":"60"}}],
                },)
            }
        }
    }
    for my $x (0..$size) {
        if ($cols->[$x][2] eq 'A' && $cols->[$x][3] eq 'v') {
            for my $y (0..$cols->[$x][0]) {
                $conf = $conf.qq(
                {"type":"Block",  "tag": "tr",
                "elements":
                [{"type":"Block",  "tag": "td", "element":{"label":"$cols->[$x][1]", "type":"Textarea","name":"$y$cols->[$x][1]_a", "cols":"45", "rows":"15"}},
                 {"type":"Block",  "tag": "td", "element":{"label":"$cols->[$x][1]", "type":"Textarea","name":"$y$cols->[$x][1]_b", "cols":"45", "rows":"15"}}],
                },)
            }
        }
    }
    $conf = $conf.qq( ]}]}]} );
    my $filename = $form_path.'4444.json';
    open my $fh, '>', $filename;
    print $fh $conf;

}
sub prewiew {
    my ($self, $userPath, $img_path3, $param) = @_;
    my $temp = LoadFile($userPath.'temp2');
    my @temp = @$temp;
    my $n = 0;
    foreach my $key (sort keys %$param) {                               # NUMBER OF PICS
        if ($key =~ /^(\d+)$/) {
            $temp[3][$n] = $1;
            $n++;
        }
    }
    my $uri = $temp->[1][0];
    getstore($uri, $img_path3.'0.jpg');
    my $image = Image::Magick->new;	
    $image->Read($img_path3.'0.jpg');
    $image->Resize(width=>320, height=>455);
    $image->Write($img_path3.'0.jpg');

    DumpFile($userPath.'temp2', [@temp]);

    my $p = '<input type="image" class="post" src="/images/find/0.jpg"/>';       # POSTER
    my $k = '<img class="kadr" src="/images/find/'.$temp[3][0].'.jpg"/>'.        # FRAMES
            '<img class="kadr" src="/images/find/'.$temp[3][1].'.jpg"/>'. 
            '<img class="kadr" src="/images/find/'.$temp[3][2].'.jpg"/>'. 
            '<img class="kadr" src="/images/find/'.$temp[3][3].'.jpg"/>';
    my $full = $p.'<div class="foto">'.$k.'<hr></div>';
    return $full
}
sub glob {
    my ($self, $userPath, $img_path2, $img_path3, $img_path4, $id, $cols, $param, $Selt, $cols2) = @_;
    my $temp = LoadFile($userPath.'temp2');
   
    my (%cols, @cols1, @cols2, @cols3, @glob1, @glob2, $numb, @time);
    
    ( $time[0], $time[1], $time[2], $time[3], $time[4], $time[5] ) = localtime();
    $time[4]++;
    for (0..4) {
        $time[$_] = "0".$time[$_] if $time[$_] < 10;
    }
    $glob1[0][0][0] = ($time[5]-100).$time[4].$time[3].$time[2].$time[1].$time[0];

    for my $x (0..@$cols) {                                             # вычисляемые поля
        if ( $cols->[$x][6] eq 'm') {
            my $conf = $cols->[$x][1];
            for my $z (0..@{$Selt->{$conf}}) {
                for my $y (0..$cols->[$x][0]) {
                    if ($param->{$y.$cols->[$x][1].'_a'} eq $Selt->{$conf}[$z][2]) {
                        $cols{'0glob'} = $cols{'0glob'}.':'.$Selt->{$conf}[$z][0] if $Selt->{$conf}[$z][0];
                    }
                }
            }           
        }
        if ($cols->[$x][5] eq 's') {                                    # невычисляемые поля
            for my $y (0..$cols->[$x][0]) {
                $cols{$y.$cols->[$x][1]} = $param->{$y.$cols->[$x][1].'_a'};
            }
        }
    }
    for my $fild (1..@$cols-2) {
        for my $y (0..$cols->[$fild][0]) {
            $glob1[0][$fild][$y] = $cols{$y.$cols->[$fild][1]};
        }
    }
    for my $fild (1..@$cols2) { 
        for my $y (0..$cols2->[$fild][0]) {
           $glob2[0][$fild][$y] = $temp->[0][$fild][$y];
        }
    }
    $glob2[0][5][0] = $param->{'0'.$cols->[12][1].'_a'};
    my $yaml1 = LoadFile($userPath.'dba1');
    my $yaml2 = LoadFile($userPath.'dba2');
    
    my @yaml1 = @$yaml1;
    my @yaml2 = @$yaml2;
    push @yaml1, @glob1;
    push @yaml2, @glob2;
    
    @yaml1 = sort {                                                      # SORT BY YEAR AND REIT
        $b->[4][0] <=> $a->[4][0]
        ||
        $b->[3][0] <=> $a->[3][0]
    } @yaml1;
    
    my $n;                                                              # NUMB OF FILM
    for my $x (0..@yaml1) {
        if ($yaml1[$x][0] eq $glob1[0][0]) {
            $n = $x;
        }
    }    
    $yaml1[$n][0][1] = @$yaml2;
    $yaml2->[@$yaml2][0][1] = $n;
    
    DumpFile($userPath.'dba1', [@yaml1]);
    DumpFile($userPath.'dba2', $yaml2);

    my ($rigt, $left);
    for ( 0..4 ) {
        $rigt = $rigt.'<input type="image" class="image1" name="'.$_.'" src="/images/imgs/'
        .$yaml1[$n][0][0].'kad'.$_.'.jpg" />';
    }
    
    opendir (my $dh, $img_path3) || die "can't opendir $img_path3: $!";
    my @files = grep { /^\d+_.*?\.jpg/ } readdir($dh);
    for ( 0..6 ) {
        $left = $left.'<div class="numb">'.($_+1).'</div><input type="image" class="image1" name="'
        .$files[$_].'" src="/images/find/'.$files[$_].'">' if $files[$_];
    }    
    move ($img_path3.'0.jpg', $img_path2.$glob1[0][0][0].'kad0.jpg');    
    move ($img_path3.$temp->[3][$_].'.jpg', $img_path2.$glob1[0][0][0].'kad'.($_ + 1).'.jpg') for 0..3;

    return $rigt, $left, \@glob1;

}
sub best {
    my ($self, $userPath) = @_;
    my ($ds) = LoadFile($userPath.'best');
    my $micro;
    for(1..100) {
        $micro = $micro.$s8.$ds->{$_}{'runame'}.$s1.'imageall'.$s2.'best'.$_.$s3.$ds->{$_}{'code'}.'kad0'.$s4;
    }
    $micro = '<hr><div id="pics">'.$micro.'</div>';
    return $micro 
}
sub change_best {
    my ($self, $userPath, $numb, $cout) = @_;
    my ($all)  = LoadFile($userPath.'all');
    my ($ds) = LoadFile($userPath.'best');
    $ds->{$numb} = $all->{1}{1}{$cout};
    DumpFile($userPath.'best', $ds);
    my $micro;
    for(1..100) {
        $micro = $micro.$s8.$ds->{$_}{'runame'}.$s1.'imageall'.$s2.'best'.$_.$s3.$ds->{$_}{'code'}.'kad0'.$s4;
    }
    $micro = '<hr><div id="pics">'.$micro.'</div>';
    return $micro
}
sub crew {
    my ($self, $img_path, $userPath) = @_;
    my (@pics, $micro);
    my $ds = LoadFile($userPath.'temp');
    my $act0 = $ds->{'director'};
    my $ua = LWP::UserAgent->new;
    my $address = 'https://afisha.mail.ru/search/?region_id=42&q='.$act0;
    my $req = HTTP::Request->new( 'GET', $address);
    $req->header('User-Agent' => 'Opera/9.80 (X11; Linux i686) Presto/2.12.388 Version/12.16');
    $req->header('Accept-Language' => 'ru,en;q=0.9');
    $req->header('Accept-Encoding' => 'gzip, deflate');
    my $resp = $ua->request($req);
    my $content = $resp->decoded_content;
}
sub mysql {                                                             # FROM YAML TO MYSQL
    my ($self, $cols, $select, $userPath) = @_;
    my (@cols, %cols);
    push @cols, $_->[0] foreach @{$cols};                               # NAMES OF FIELDS

    my $ds = LoadFile($userPath.'all');
    
    my %country1;
    my %country = %{$select->{'coun'}};
    foreach my $country (keys %country) {
        $country1{$country{$country}[1]} = $country; 
    }
    my %genre1;
    my %genre = %{$select->{'genr'}};
    foreach my $genre (keys %genre) {
        $genre1{$genre{$genre}[1]} = $genre; 
    }
    for (1..$ds->{1}{1}{0}) {
        for my $n (0..12) {
            $cols{$cols[$n]} = $ds->{1}{1}{$_}{$cols[$n]};
        } 
        $cols{'magnet1'} = $ds->{1}{1}{$_}{'magnet'};
        my (@coun, @genr);
        push @coun, split (/ /, $ds->{1}{1}{$_}{'coun'});
        push @genr, split (/ /, $ds->{1}{1}{$_}{'genr'});
        $cols{'coun'} = $country1{$coun[0]}.':'.$country1{$coun[1]}.':'.$country1{$coun[2]}.':'.$country1{$coun[3]};
        $cols{'genr'} = $genre1{$genr[0]}.':'.$genre1{$genr[1]}.':'.$genre1{$genr[2]}.':'.$genre1{$genr[3]};
        $self->resultset('Films2')->update_or_create({ %cols });
       
    }
}
sub del {
    my ( $self, $ds, $dsl, $cent, $maxr, $love ) = @_;
    my ($side, $info, $left, $mess);
    my $count = $ds->{1}{3}{0} + 1;
    $ds->{1}{3}{$count} = $ds->{1}{$love}{$cent}{'code'};
    $ds->{1}{3}{0} = $count;
    
    delete $ds->{1}{$love}{$cent};
    $ds->{1}{$love}{0} = $maxr-1;
    if ($ds->{1}{$love}{0}== 0) {
        ($side, $cent, $left) = (0, 1, 0);
        $info = $dsl->{1}{1}{$cent};
    }
    else {
        $side = 1;
        my $n = 1;
        while ($ds->{1}{$love}{$cent + $n}) {
            my $next = $ds->{1}{$love}{$cent+$n};
            $ds->{1}{$love}{$cent+$n-1} = {%$next};
            delete $ds->{1}{$love}{$cent+$n};
            $n++;
        }
        if ($cent > 1) {
            $cent = $cent-1;
        }
        else {
            $cent = $cent;
        }
        $info = $ds->{1}{$love}{$cent};
    }
    return $cent, $side, $info, $left
}
sub base {
    my ( $self, $selec, $userPath) = @_;
    my ($ds) = LoadFile($userPath.'all');
    my $max = $ds->{1}{1}{0};
    my $info;
    $info->{1}{0} = $max;
    for ( 1..$max ) {
        $info->{1}{2}{$_} = $ds->{1}{1}{$_}{'code'};
    }
    for ( 1..$max ) {
        $info->{1}{1}{$ds->{1}{1}{$_}{'code'}} = {
            year      => $ds->{1}{1}{$_}{'year'},
            coun      => $ds->{1}{1}{$_}{'coun'},
            code      => $ds->{1}{1}{$_}{'code'},
            genr      => $ds->{1}{1}{$_}{'genr'},
            time      => $ds->{1}{1}{$_}{'time'},
            reit      => $ds->{1}{1}{$_}{'reit'},
            runame    => $ds->{1}{1}{$_}{'runame'},
            orname    => $ds->{1}{1}{$_}{'orname'},
            director  => $ds->{1}{1}{$_}{'director'},
            actor1    => $ds->{1}{1}{$_}{'actor1'},
            actor2    => $ds->{1}{1}{$_}{'actor2'},
            actor3    => $ds->{1}{1}{$_}{'actor3'},
            actor4    => $ds->{1}{1}{$_}{'actor4'},
            actor5    => $ds->{1}{1}{$_}{'actor5'},
            review    => $ds->{1}{1}{$_}{'review'},

        };
    }

    DumpFile($userPath.'base', $info);
    chmod 0666, $userPath.'base';
}
__PACKAGE__->meta->make_immutable;

1;
