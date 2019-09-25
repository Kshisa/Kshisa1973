package kshisa::Model::Main;
use Moose;
use namespace::autoclean;
use LWP;
use LWP::Simple qw(getstore);
use File::Copy;
use Image::Magick;

extends 'Catalyst::Model';
sub _left {
	my ($find0, $find2, $f, $l) = @_;
	my $left;
	opendir (my $dh0, $find0);
	my @files0 = grep { !/^\./ } readdir($dh0);
	$_ =~ s/.jpg// for (@files0);
	for ($f..$l) {
		$left = $left.'<div class="numb">'.($_+1).
				       '</div>
						<a title="'.$files0[$_].'">
						<input type="image"
						        class="image1"
							    name="'.$files0[$_].'"
								src="/images/'.$find2.$files0[$_].'.jpg">
						</a>' if $files0[$_];
 	}
  	return $left
}
sub pics {
	my ($self, $find1) = @_;
	my $pics;
	opendir (my $dh1, $find1);
	my @files1 = grep { !/^\./ } readdir($dh1);
	$_ =~ s/.jpg// for (@files1);
	for (0..$#files1) {
		#rename($find1.$files1[$_].'.jpg', $find1.$_.'.jpg');
		$pics = $pics.'	<a title="'.$_.'">
						<input type="image"
						        class="imageall"
							    name="'.$_.'"
								src="/images/find1/'.$_.'.jpg">
						</a>';
		$pics = $pics.'<input type="checkbox"
						       name="'.$_.'"
						/>';
		
	}
	return $pics
}
sub prew {
	my ($self, $dba2, $param, $imgs1) = @_;
	my $name = $param->{$dba2->[0][1][1][0].'2r'};
	my $code = $param->{$dba2->[0][1][0][0].'1r'};
	my @numbs;
	for (1..20) {
	    if ($param->{$_}) {
            push @numbs, $_;
		}
	}
	my $foto = '/images/imgs1/'.$name.'/'.$code;
	my $p = '<input type="image" class="post" name="post" src="'.$foto.'_0.jpg"/>';              # POSTER
    my $k = '<img class="kadr" name="kadr0" src="'.$foto.'_'.$numbs[0].'.jpg"/>
         	 <input name="numb0" type="text" value="'.$numbs[0].'" size="1"></span>'.            # FRAMES
            '<img class="kadr" name="kadr1" src="'.$foto.'_'.$numbs[1].'.jpg"/>
			 <input name="numb1" type="text" value="'.$numbs[1].'" size="1"></span>'. 
            '<img class="kadr" name="kadr2" src="'.$foto.'_'.$numbs[2].'.jpg"/>
			 <input name="numb2" type="text" value="'.$numbs[2].'" size="1"></span>'.
            '<img class="kadr" name="kadr3" src="'.$foto.'_'.$numbs[3].'.jpg"/>
			 <input name="numb3" type="text" value="'.$numbs[3].'" size="1"></span>';
    my $full = $p.'<div id="foto1">'.$k.'<hr>
	         <input type="image" name="prevl" src="/images/buttons/prev.jpg">
             <input type="image" name="find1" src="/images/buttons/find.jpg">
             <input type="image" name="add1"  src="/images/buttons/add0.jpg">
             <input type="image" name="nextl" src="/images/buttons/next.jpg"></div>';
    return $full
}
sub picset {
	my ($self, $dba00, $numb, $imgs) = @_;
	my $code = $dba00->[$numb][0][0];
	my $foto = '/images/imgs/'.$code;
	my $p = '<input type="image" class="post" name="post" src="'.$foto.'_0.jpg"/>';              # POSTER
    my $k = '<img class="kadr" name="kadr0" src="'.$foto.'_1.jpg"/>'.
            '<img class="kadr" name="kadr1" src="'.$foto.'_2.jpg"/>'.
            '<img class="kadr" name="kadr2" src="'.$foto.'_3.jpg"/>'.
            '<img class="kadr" name="kadr3" src="'.$foto.'_4.jpg"/>';
    my $full = $p.'<div id="foto1">'.$k.'<hr>
	         <input type="image" name="prevl" src="/images/buttons/prev.jpg">
             <input type="image" name="find1" src="/images/buttons/find.jpg">
             <input type="image" name="add1"  src="/images/buttons/add0.jpg">
             <input type="image" name="nextl" src="/images/buttons/next.jpg"></div>';
    return $full
}
sub imgs {
	my ($self, $dba2, $dba00, $numb, $param, $imgs0, $imgs1) = @_;
	my @numbs;
    my $name = $param->{$dba2->[0][1][1][0].'2r'};
	my $code = $param->{$dba2->[0][1][0][0].'1r'};
	my $image = Image::Magick->new;
	$image->Read($imgs1.$name.'/'.$code.'_0.jpg');
    $image->Resize(width=>260, height=>368);
    $image->Write($imgs0.$code.'_0.jpg');
	for (0..20) {
	    if ($param->{'numb'.$_}) {
            push @numbs, $param->{'numb'.$_};
		}
	}
	for (0..3) {
        my $image = Image::Magick->new;
        $image->Read($imgs1.$name.'/'.$code.'_'.$numbs[$_].'.jpg');
        $image->Resize(width=>255, height=>150);
        $image->Write($imgs0.$code.'_'.($_+1).'.jpg');
	}
	return $dba00
}
sub mail {
	my ($self, $dba2, $find, $find0, $find1, $find2) = @_;
	my (@f0, @s, @t, @d, $form, $response);
    my $sise = $#{$dba2->[0][1]};
	push @d, $dba2->[0][1][$_]    for 0..$sise;
	push @s, $dba2->[0][0][0][$_] for 0..5;
    push @t, $dba2->[0][0][2][$_] for 0..5;
	
    unlink glob "$find1*.*";
    my $browser = LWP::UserAgent->new;
    my $UA = 'Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:44.0) Gecko/20100101 Firefox/44.0';
    if ($find =~ /^(\d+_.*?)/) {
	    $response = $browser->get($d[0][1][1].$find, 'User-Agent' => $UA);
	}
    else {
		unlink glob "$find2*.*";
        $response = $browser->get($d[0][1][0].$find, 'User-Agent' => $UA);
        for ($response->decoded_content) {
            while ( $_ =~ m{$d[0][1][2]}mg) {
                getstore($d[0][1][3].$1, $find0.$2.'.jpg') if $1;
				getstore($d[0][1][3].$1, $find2.$2.'.jpg') if $1;
				push @f0, $2;
            }
        }
		$response = $browser->get($d[0][1][1].$f0[0], 'User-Agent' => $UA);
    }
	$form = $form.$s[0].$s[1].$d[0][0].$s[2].$d[0][0].'1l'.$s[3].($f0[0] || $find).$s[4].$s[5];
	my $left = _left($find2, 'find2/', 0, 10);
	#open my $fh, '>', '/home/marat/kshisa/mail.html';
    #print $fh $response->decoded_content;
    my @pics;
    for my $i (0..$#{$dba2->[0][1]}) {
        my $x = 0;
	    my $name = $dba2->[0][1][$i][0];
        for ($response->decoded_content) {
		    while ( $_ =~ m{$dba2->[0][1][$i][4]}mg) {
		        my $pers = $1;
		        while ( $pers =~ m{$dba2->[0][1][$i][5]}mg) {
					if ($i == 0) {
						push @pics, $1
					}
					else {
						if ($dba2->[0][1][$i][1] == 1) {
							$form = $form.$t[0].$t[1].$name.$t[2].$name.($x=++$x).'l'.$t[3].$1.$t[4].$t[5]
						}
						else {
							$form = $form.$s[0].$s[1].$name.$s[2].$name.($x=++$x).'l'.$s[3].$1.$s[4].$s[5]
						}
					}
                }
	        }
	    }
    }
    my $pics;
    for (0..$#pics){
	    getstore($pics[$_], $find1.$_.'.jpg');
	    $pics = $pics.'<img class="imageall"
	                    name="'.$_.'"
						src="/images/find1/'.$_.'.jpg"
						/>
						<input type="checkbox"
						       name="'.$_.'"
						/>';
	}
	return $left, $form, $pics
}
sub blank {
	my ($self, $dba2, $find0, $f, $l) = @_;
	my ($form, @s, @o, @t);
	push @s, $dba2->[0][0][0][$_] for 0..5;
    push @o, $dba2->[0][0][1][$_] for 0..12;
    push @t, $dba2->[0][0][2][$_] for 0..5;
	for (1..$#{$dba2->[0][1]}) {
		my $x = 0;
		my $name = $dba2->[0][1][$_][0];
		if ($dba2->[0][1][$_][1] == 0) {
			for my $e (1..$dba2->[0][1][$_][3]) {
		        $form = $form.$s[0].$s[1].$name.
							  $s[2].$name.($x=++$x).'l'.
							  $s[3].$s[4].$s[5];
		    }
		}
		if ($dba2->[0][1][$_][1] == 1) {
    		$form = $form.$t[0].$t[1].$name.
			              $t[2].$name.($x=++$x).'l'.
				          $t[3].$t[4].$t[5];
		}
		if ($dba2->[0][1][$_][1] > 1) {
		    for my $e (1..$dba2->[0][1][$_][3]) {
			    $form = $form.$o[0].$o[1].$o[2].$name.$o[3].$o[4].$name.($x=++$x).'l'.$o[5];
			    for my $list (0..119) {
				    my $targ = $dba2->[0][1][$_][1];
				    my $rows = $dba2->[0][0][$targ][$list];
				    $form = $form.$o[6].$rows;
				    $form = $form.$o[7].$rows.$o[8];
				}	
		    }
		    $form = $form.$o[9].$o[10].$o[11];
		}
	}
	my ($left) = _left($find0, 'find0/', $f, $l);
	return $form, $left;
}
sub fromDataset {
    my ($self, $dba2, $dba00, $numb, $imgs, $find0, $find1, $imgs1, $genr, $coun, $year) = @_;
    my (@s, @o, @t, @b, $form1, $form2, $rigt);
    my $size = $#{$dba00->[$numb]};
	my %files = ('genr' => $genr,
	             'coun' => $coun,
		         'year' => $year,			 
	);

    push @s, $dba2->[0][0][0][$_] for 0..5;
    push @o, $dba2->[0][0][1][$_] for 0..12;
    push @t, $dba2->[0][0][2][$_] for 0..5;
    push @b, $dba00->[$numb] for 0..$size;

    for (0..$#{$dba2->[0][1]}) {
		my $x = 0;
		my $name = $dba2->[0][1][$_][0];
		if ($dba2->[0][1][$_][2] == 1) {
			for my $e (0..$#{$dba00->[$numb][$_]}) {
		        $form1 = $form1.$s[0].$s[1].$name.
								$s[2].$name.($x=++$x).'r'.
								$s[3].$b[$_][$_][$e].
								$s[4].$s[5];
		    }
		}
		if ($dba2->[0][1][$_][2] == 2) {
		    for my $e (0..$#{$dba00->[$numb][$_]}) {
			    $form1 = $form1.$o[0].$o[1].$o[2].$name.$o[3].$o[4].$name.($x=++$x).'r'.$o[5];
			    for my $list (0..119) {
				    my $targ = $dba2->[0][1][$_][0];
				    my $rows = $files{$targ};
				    $form1 = $form1.$o[6].$rows->[0][$list][2];
				    $form1 = $form1.$o[12] if $rows->[0][$list][2] eq $b[$_][$_][$e];
				    $form1 = $form1.$o[7].$rows->[0][$list][2].$o[8];
			    }
			    $form1 = $form1.$o[9].$o[10].$o[11];
		    }
		}
		if ($dba2->[0][1][$_][2] == 3) {
		    $form1 = $form1.$t[0].$t[1].$name.
			                $t[2].$name.($x=++$x).'r'.
							$t[3].$b[$_][$_][0].
							$t[4].$t[5];
		}
    }
	opendir (my $dh1, $imgs1.$b[0][1][1]);
	my @files1 = grep { !/^\./ } readdir($dh1);
    my $post = '<input type="image" 
						class="image1" 
						name="0k'.$b[0][1][1].'f'.$b[0][0][0].'"
						src="'.$imgs.'/'.$b[0][1][1].'/'.$b[0][0][0].'_0.jpg"
					   />';
    for (1..$#files1) {
        $rigt = $rigt.'<input type="image" 
						      class="image1" 
						      name="'.$_.'k'.$b[0][1][1].'f'.$b[0][0][0].'"
						      src="'.$imgs.'/'.$b[0][1][1].'/'.$b[0][0][0].'_'.$_.'.jpg"
					   />
					   <input type="checkbox"
						       name="'.$_.'"
						/>'.$_;
    }
    return $form1, $rigt, $post
}
sub addpics {
	my ($self, $dba2, $dba00, $param, $find1, $imgs1, $imgs2, $numb) = @_;
	my $n = 0;
	my $time = $dba00->[$numb][0][0];
    mkdir $imgs1.$param->{$dba2->[0][1][1][0].'2r'};
	mkdir $imgs2.$param->{$dba2->[0][1][1][0].'2r'};
	copy ($find1.'0.jpg', $imgs1.$param->{$dba2->[0][1][1][0].'2r'}.'/'.$time.'_0.jpg');
	copy ($find1.'0.jpg', $imgs2.$param->{$dba2->[0][1][1][0].'2r'}.'/'.$time.'_0.jpg');
	for (1..50) {
	    if ($param->{$_}) {
	        copy ($find1.$_.'.jpg', $imgs1.$param->{$dba2->[0][1][1][0].'2r'}.'/'.$time.'_'.$n.'.jpg');
	        copy ($find1.$_.'.jpg', $imgs2.$param->{$dba2->[0][1][1][0].'2r'}.'/'.$time.'_'.$n.'.jpg');
	        ++$n;
	    }
	}
	$dba00->[$numb][14][0] = $n;
	return $dba00
}
sub addDataset {
    my ($self, $dba2, $dba, $param, $find1, $imgs1, $imgs2) = @_;
    my ($film, @time);

    ($time[0], $time[1], $time[2], $time[3], $time[4], $time[5]) = localtime();
    for (0..4) { $time[$_] = "0".$time[$_] if $time[$_] < 10}
    my $time = '0_'.($time[5]-100).++$time[4].$time[3].$time[2].$time[1].$time[0];
    $film->[0][0] = $time;
    $film->[0][1] = $param->{$dba2->[0][1][0][0].'1l'};

    my $n = 1;
    mkdir $imgs1.$param->{$dba2->[0][1][1][0].'2l'};
	mkdir $imgs2.$param->{$dba2->[0][1][1][0].'2l'};
	copy ($find1.'0.jpg', $imgs1.$param->{$dba2->[0][1][1][0].'2l'}.'/'.$time.'_0.jpg');
	copy ($find1.'0.jpg', $imgs2.$param->{$dba2->[0][1][1][0].'2l'}.'/'.$time.'_0.jpg');
    for (2..50) {
	    if ($param->{$_}) {
	        copy ($find1.$_.'.jpg', $imgs1.$param->{$dba2->[0][1][1][0].'2l'}.'/'.$time.'_'.$n.'.jpg');
	        copy ($find1.$_.'.jpg', $imgs2.$param->{$dba2->[0][1][1][0].'2l'}.'/'.$time.'_'.$n.'.jpg');
	        ++$n;
	    }
	}
    for my $i (1..$#{$dba2->[0][1]}) {
        if ($dba2->[0][1][$i][6]) {
            if ($param->{$dba2->[0][1][$i][0].'1l'} =~ m{$dba2->[0][1][$i][6]} ) {
	            $film->[$i][0] =  ($1 * $dba2->[0][1][$i][7][0] + $dba2->[0][1][$i][7][1]) + $2;
            }
        }
        else {
            foreach my $key (keys %$param) {
		        if ($key =~ /$dba2->[0][1][$i][0](\d+)l/) {
	                $film->[$i][$1-1] = $param->{$dba2->[0][1][$i][0].$1.'l'}
	            }
	        }
	    }
    }
    my $numb = $#{$dba}+1;
    $dba->[$numb] = $film;

    my @film = @$dba;
    @film = sort {                                                      # SORT BY YEAR AND REIT
        $a->[3][0] <=> $b->[3][0]
        ||
        $b->[2][0] <=> $a->[2][0]
    } @film;
    for (0..$#film) {
		if ($film[$_][1][1] eq $param->{$dba2->[0][1][1][0].'2l'}) {
			$numb = $_;
		}
	}
    return $numb, @film, 
}
=head1 NAME

kshisa::Model::Main - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.


=encoding utf8

=head1 AUTHOR

Marat Hakimov

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
