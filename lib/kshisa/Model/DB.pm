package kshisa::Model::DB;
use base 'Catalyst::Model::DBIC::Schema';
use utf8;
use YAML::Any qw(DumpFile);
use LWP;
use LWP::Simple qw(getstore);
use Image::Magick;

__PACKAGE__->config(
    schema_class => 'kshisa::Schema',
    connect_info => [
        'dbi:mysql:kshisa',
        'root',
        '63477463',
        {
            AutoCommit        => 1,
            RaiseError        => 1,
            mysql_enable_utf8 => 1,
        },
    ]
);
sub pass {
    my ( $self, $selec, $userPath) = @_;
    my ( $password, $mediainfo );
    my @chars = split( " ","a b c d e f g h i j k l " );
    for (0..5){
        $password .= $chars[int(rand 12)]
    }
    my $rs = $self->resultset('User')->create({ 
        password => $password, 
        status   => 'user',
    });
    my $userId = $rs->id;
    
    my @rs = $self->resultset('Films2')->search(undef, {rows => 99});
    my $num = 0;
    foreach my $rs ( @rs ) {
        my @code_coun = split ':', uc $rs->coun;
        my @code_genr = split ':', uc $rs->genr;
        my $coun0 = $selec->{'coun'}{$code_coun[0]}[1];
        my $coun1 = $selec->{'coun'}{$code_coun[1]}[1];
        my $coun2 = $selec->{'coun'}{$code_coun[2]}[1];
        my $coun3 = $selec->{'coun'}{$code_coun[3]}[1];

        my $genr0 = $selec->{'genr'}{$code_genr[0]}[1];
        my $genr1 = $selec->{'genr'}{$code_genr[1]}[1];
        my $genr2 = $selec->{'genr'}{$code_genr[2]}[1];
        my $genr3 = $selec->{'genr'}{$code_genr[3]}[1];
        $mediainfo->{password} = $password;
        $mediainfo->{new}{$num} = {
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
            actor2   => $rs->actor3,
            actor4   => $rs->actor4,
            actor5   => $rs->actor5,
            review   => $rs->review,
        };
        $num++;
    }
    DumpFile($userPath.$userId, $mediainfo);
    chmod 0666, $userPath.$userId;
    my $pass;
    for (0..2) {
        $pass .= substr ($password, 2*$_, 2);
    }
    return $userId;
}
sub _findd {
    my ($img_path3) = @_;
    my (%cols0, @entries);
    opendir(my $dh, $img_path3);
    while ( my $entry = readdir $dh ) {
        if ( $entry =~ m{(.*?)kad(\d+)\.jpg}) {
            $entries[$2] = $1;
        }
    }
    closedir $dh;
    for (0..4){
        if ($entries[$_]){
            $cols0{'code'.$_} = '/images/find/'.$entries[$_];
        }else{
            $cols0{'code'.$_} = '/images/buttons/blank'
        }
    }
    return %cols0;
}
sub _set {
    my ($cols, $rs) = @_;
    my (%cols1);
    foreach (@$cols){                                                   # хеш заполнения полей
        if ($_ =~ /(\D+)_(\d+)/){
            my @set = split ':', $rs->$1 if ($rs);
            $cols1{$_} = uc $set[$2];
        }
        else{
            $cols1{$_} = $rs->$_ if ($rs);
        }
    }
    $cols1{'id'} = $rs->id || 0;
    return %cols1;
}
sub start {
    my ($self, $cols, $img_path3) = @_;
    my (%cols0, %cols1, @entries);
    my $max = $self->resultset('Films2')->get_column('id')->max() || 0;
    my $rs  = $self->resultset('Films2')->find({id => $max});
    %cols0 = _findd($img_path3);
    %cols1 = _set($cols, $rs);
    return \%cols0, \%cols1;
}

sub step {
    my ( $self, $nextval1, $cols, $par, $img_path3 ) = @_;
    my ( $rs, %cols0, %cols1 );
    my $max = $self->resultset('Films2')->get_column('id')->max();
    if ( $par eq 'next.x' ) {
        while ( $nextval1 < $max + 1 ) {                                # поиск следующей записи
            $nextval1 ++;
            $nextval1 = 1 if $nextval1 == $max + 1;
            $rs = $self->resultset('Films2')->find({id => $nextval1});
            last if ($rs);
        }
    }
    elsif ( $par eq 'prev.x' ) {
        while ( $nextval1 > -1 ) {                                      # поиск предыдущей записи
            $nextval1 --;
            $nextval1 = $max + 1  if $nextval1 == 0;
            $rs = $self->resultset('Films2')->find({id => $nextval1});
            last if ($rs);
        }
    }
    %cols0 = _findd($img_path3);
    %cols1 = _set($cols, $rs);
    return \%cols0, \%cols1;
}
sub magic {
    my ( $self, $seen, $dna ) = @_;
    my @tosee;
    my @code = $self->resultset('Films2')->search();
    foreach my $code (@code) {
        my $equal = 0;
        foreach my $seen (@$seen) {
            if ($code->code eq $seen){
                $equal = 1;
            }
        }
        push @tosee, $code->code if $equal == 0;
    }
    my (%ureit1, %ureit2, $winer);
    $ureit1{$_} = 0 for (@tosee);                                       # хэш рейтингов
    
    foreach my $tosee (@tosee) {                                        # вычисление индивидуальных рейтингов по фильмам
        my @parts;
        for (1..3) {
            push @parts, substr $tosee, $_*4, 4;
        }
        foreach my $part (@parts) {
            while ( my ( $dna1, $dna2 ) = each %$dna ) {
               $ureit1{$tosee} = $ureit1{$tosee} + $dna2 if ($part eq $dna1)
            }
        }
    }
    foreach (sort {$ureit1{$b}<=>$ureit1{$a}} keys %ureit1) {
        my $reit1 = $self->resultset('Films2')->find({code=>$_});
        my $reit2 = $ureit1{$_} + $reit1->reit;
        $ureit2{$_} = $reit2;
        last if %ureit2 == 4;
    }
    foreach (sort {$ureit2{$b}<=>$ureit2{$a}} keys %ureit2) {
        $winer = $_;
        last;
    }
    return $winer;
}
sub search {
    my ($self, $find, $img_path3, $nextval1, $cols) = @_;
    my (%cols0, %cols1, @film0, @film1);
    unlink glob "$img_path3*.*";
    
    my $ua = LWP::UserAgent->new;
    my $address = 'https://afisha.mail.ru/search/?region_id=42&q='.$find;
    my $req = HTTP::Request->new( 'GET', $address);
    $req->header('User-Agent' => 'Opera/9.80 (X11; Linux i686) Presto/2.12.388 Version/12.16');
    $req->header('Accept-Language' => 'ru,en;q=0.9');
    $req->header('Accept-Encoding' => 'gzip, deflate');
    my $resp = $ua->request($req);
    my $content = $resp->decoded_content;
    my $filename = '/home/marat/images/find/mail.html';
    open my $fh, '>', $filename;
    print $fh $content; 
    
    for (split /\n/, $content) {
        if ( $_ =~ m{/(\d+)/.*?movies/(.*?)/.*?}){
            @film0 = ( $1 );
            @film1 = ( $2 );
         }
        if ( $_ =~ m{/(\d+)/.*?movies/(.*?)/.*?/(\d+)/.*?movies/(.*?)/.*?}){
            @film0 = ( $1, $3 );
            @film1 = ( $2, $4 );
        }
        if ( $_ =~ m{/(\d+)/.*?movies/(.*?)/.*?/(\d+)/.*?movies/(.*?)/.*?/(\d+)/.*?movies/(.*?)/.*?}){
            @film0 = ( $1, $3, $5 );
            @film1 = ( $2, $4, $6 );
        }
        if ( $_ =~ m{(\d+)/\)" href="/cinema/movies/(.*?)/.*?/(\d+)/\)" href="/cinema/movies/(.*?)/.*?/(\d+)/\)" href="/cinema/movies/(.*?)/.*?/(\d+)/\)" href="/cinema/movies/(.*?)/}){
            @film0 = ( $1, $3, $5, $7 );
            @film1 = ( $2, $4, $6, $8 );
        }

    }
    for ( 0..4 ) {
        my $dir = $img_path3.$film1[$_].'kad'.$_.'.jpg';
        getstore( 'https://pic.afisha.mail.ru/'.$film0[$_].'/', $dir );
    } 
    my $rs  = $self->resultset('Films2')->find({id => $nextval1});
    %cols0 = _findd($img_path3);
    %cols1 = _set($cols, $rs);
    return \%cols0, \%cols1
}
sub mail {
    my ($self, $cols, $par, $selec, $img_path1, $img_path3, $nextval1) = @_;
    my (@entries, $pics, %cols0, %cols1, @pic0, @pic1, @pic2, @pic3, $am, @country, @genre, @actors, $rew);
    unlink glob "$img_path1*.*";
    opendir(my $dh, $img_path3);
    while ( my $entry = readdir $dh ) {
        if ( $entry =~ m{(.*?)kad(\d+)\.jpg}) {
            $entries[$2] = $1;
        }
    }
    closedir $dh;

    $par =~ s/.x//;
    $par =~ s/kadr//;
    my $address = $entries[$par];
    $address = 'https://afisha.mail.ru/cinema/movies/'.$address;
    for (0..4){
        if ($entries[$_]){
            $cols1{'code'.$_} = '/images/find/'.$entries[$_];
        }else{
            $cols1{'code'.$_} = '/images/buttons/blank'
        }
    }

    my $browser = LWP::UserAgent->new;
    my $response = $browser->get( $address, 
    'User-Agent'      => 'Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:44.0) Gecko/20100101 Firefox/44.0', 
    'Accept-Language' => 'ru-RU,ru;q=0.8,en-US;q=0.5,en;q=0.3'); 
    my $content= $response->decoded_content;
    my $filename = '/home/marat/images/find/mail1.html';
    open my $fh, '>', $filename;
    print $fh $content;
    
    foreach my $line (split /\n/, $content) {
        if ( $line =~ m{<div class="block_posrel">(.*?)<span class="countyellow">(\d+)</span>.*?} ){
            $am = $2;
            my $piece = $1;
            @pic0 = $piece =~ m/https:\/\/pic.kino.mail.ru\/\d+\//g;
        }
        $cols1{'runame'} = $1 if ( $line =~ m{<h1 class="movieabout__name" itemprop="name">(.*?)</h1>} );
        $cols1{'orname'} = $1 if ( $line =~ m{<h2 class="movieabout__nameeng" itemprop="alternativeHeadline">(.*?)</h2>} );
        if ( $line =~ m{IMDb</b>(.*?)</span>} ) {
            my $reit = $1;
            $reit =~ tr[.][]d;
            $reit = $reit.0;
            $cols1{'reit'} = $reit;
        }
        push @country, $2, $4, $6, $8 if ( $line =~ m{(<div class="itemevent__head__info"><a href="/cinema/all/.*?>(.*?)</a>)(, <a href="/cinema/all/.*?>(.*?)</a>)?(, <a href="/cinema/all/.*?>(.*?)</a>)?(, <a href="/cinema/all/.*?>(.*?)</a>)?} );
        for (0..3) {
            my %coun = %{$selec->{'coun'}};
            while (my ($fcode, $engrus) = each %coun) {
                if ($engrus->[1] eq $country[$_]) {
                    $cols1{'coun_'.$_} = $fcode;
                    last;
                }
            }
        }
        $cols1{'year'} = $1 if ( $line =~ m{class="itemevent__head__sep">/</span><a href="/cinema/all/.*?>(.*?)</a>} );
        
        my ($hour, $mints);
        
        $mints = $1 if ( $line =~ m{head__sep".*?></i>.*?ч. (.*?)&nbsp;мин.<meta} );;
        $cols1{'time'} = $1*60+$mints if ( $line =~ m{head__sep".*?></i>(.*?)&nbsp;ч.*?} );
        
        push @genre, $2, $4, $6, $8 if ( $line =~ m{(itemprop="genre"><a href="/cinema/all/.*?>(.*?)</a>)( <a href="/cinema/all/.*?>(.*?)</a>)?( <a href="/cinema/all/.*?>(.*?)</a>)?( <a href="/cinema/all/.*?>(.*?)</a>)?} );
        for (0..3) {
            my %genr = %{$selec->{'genr'}};
            while (my ($fcode, $engrus) = each %genr) {
                if ($engrus->[1] eq $genre[$_]) {
                    $cols1{'genr_'.$_} = $fcode;
                    last;
                }
            }
        }
        $cols1{'director'} = $1 if ( $line =~ m{itemprop="director"><a href.*?>(.*?)</a>} );
        push @actors, $2, $4, $6, $8, $10 if ( $line =~ m{(itemprop="actors"><a href="/person.*?>(.*?)</a>)(, <a href="/person.*?>(.*?)</a>)?(, <a href="/person.*?>(.*?)</a>)?(, <a href="/person.*?>(.*?)</a>)?(, <a href="/person.*?>(.*?)</a>)?(, <a href="/person.*?>(.*?)</a>)?} );
        $cols1{'actor1'} = $actors[0];
        $cols1{'actor2'} = $actors[1];
        $cols1{'actor3'} = $actors[2];
        $cols1{'actor4'} = $actors[3];
        $cols1{'actor5'} = $actors[4];
        $rew = $1 if ( $line =~ m{itemprop="description"><p>(.*?)</p>} );
        $rew =~ tr[&nbsp;][ ]d;
        $rew =~ tr[&mdash;]["—]d;
        $rew =~ tr[&hellip;]["..."]d;
        $rew =~ tr[&laquo;][""]d;
        $rew =~ tr[&raquo;]["""]d;
        $cols1{'review'} = $rew;
        $cols1{'size'} = 0;
        $cols1{'No'} = $entries[$par];
        $cols1{'kad0'} = $1 if ( $line =~ m{class="movieabout__pic photo__inner">.*?href="(.*?)".*?data-module="Gallery"} );
    }     
    for ( 0..$am*2 ) {
        if ( $_%2 == 0 ) {
            push @pic1, $pic0[$_];
        }
        else {
            push @pic2, $pic0[$_];
        }
    }
    @pic3 = grep {s/\//S/g} @pic1;
    @pic3 = grep {s/\./D/g} @pic1;
    for ( 0..$#pic3 ) {
        my $dir = $img_path1.$pic3[$_].'.jpg';
        getstore( $pic2[$_], $dir );
    }
    my $rs = $self->resultset('Films2')->find({id => $nextval1});
    %cols0 = _set($cols, $rs);

    return \%cols1, \%cols0, \@pic3
}
sub pics {
    my ($self, $cols, $img_path1, $img_path3, $nextval1) = @_;
    my (%cols0, %cols1, @entries, @pics);
    my $rs = $self->resultset('Films2')->find({id => $nextval1});
    %cols0 = _findd($img_path3);
    %cols1 = _set($cols, $rs);
    opendir(my $dh, $img_path1);
    while ( my $entry = readdir $dh ) {
        if ( $entry =~ m{(.*?)kad(\d+)\.jpg}) {
            $entries[$2] = $1;
        }
        if ( $entry =~ m{(https:SSpicDkinoDmailDruS\d+S)\.jpg}) {
            push @pics, $1;
        }
    }
    closedir $dh;
    return \%cols0, \%cols1, \@pics;
}

sub ins {
    my ($self, $nextval1, $par, $side, $cols, $img_path2, $img_path3, $img_path4) = @_;
    my ($rs1, $rs2, %cols0, %cols1, @code, @time, @entries);

    foreach (@$cols){                                                               # хэш для занесения в базу
        $cols0{$_} = $par->param_value($_.$side) if ! ($_ =~ /(.*?)_(\d+)/)                             
    }    
    
    $cols0{'coun'} = lc $par->param_value('coun_0'.$side).':'.$par->param_value('coun_1'.$side).':'.$par->param_value('coun_2'.$side).':'.$par->param_value('coun_3'.$side);
    $cols0{'genr'} = lc $par->param_value('genr_0'.$side).':'.$par->param_value('genr_1'.$side).':'.$par->param_value('genr_2'.$side).':'.$par->param_value('genr_3'.$side);

    my $code1 = $par->param_value('orname'.$side);                                  # код фильма
    my $code2 = substr $code1, 0, 3;
    $code1 = substr $code1, 4 if $code2 eq 'The';
    $code[0] = substr lc $code1, 0, 4;       
    $code[0] =~ tr/ /_/;
    $code[0] = $code[0].'_' if length $code[0] < 4;
    $code[1] = substr lc $par->param_value('year'.$side), 0, 4;
    $code[2] = substr lc $cols0{'coun'}, 0, 4;
    $code[3] = substr lc $cols0{'genr'}, 0, 4;
    my $code = $code[0].$code[1].$code[2].$code[3];
    $cols0{'code'} = $code;
   
    my $rs = $self->resultset('Films2')->update_or_create({ %cols0 });              # загрузка формы в базу данных

    my @foto = qw/kad0 kad1 kad2 kad3 kad4/;                                        # загрузка картинок
    foreach my $kadr ( @foto ) {
        my $dir = $img_path2.$code.$kadr.'.jpg';
        getstore( $par->param_value($kadr.$side), $dir );
    }
    my $image = Image::Magick->new;	
    my $dir = $img_path2.$code.'kad0.jpg';
    my $dirG = $img_path2.$code.'kad0G.jpg';
    my $dir1 = $img_path4.$code.'kad0.jpg';
    my $dirG1 = $img_path4.$code.'kad0G.jpg';
    $image->Read($dir);
    $image->Resize(width=>320, height=>455);
    $image->Write($dir);
    $image->Write($dir1);
    $image->Quantize(colorspace=>'gray');
    $image->Write($dirG);
    $image->Write($dirG1);
    for (1..4){
        my $image = Image::Magick->new;
        my $dir = $img_path2.$code.'kad'.$_.'.jpg';
        my $dir1 = $img_path4.$code.'kad'.$_.'.jpg';
        $image->Read($dir);
        $image->Resize(geometry => '330x210');
        $image->Crop(width=>272, height=>178);
        $image->Write($dir);
        $image->Write($dir1);
    }
    %cols0 = _findd($img_path3);
    %cols1 = _set($cols, $rs); 
    
    return \%cols0, \%cols1;
}

1;
