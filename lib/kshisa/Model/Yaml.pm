package kshisa::Model::Yaml;
use Moose;
use namespace::autoclean;

extends 'Catalyst::Model';

use utf8;
use YAML::Any qw(LoadFile DumpFile);
sub user {
    my ( $self, $userPath, $name, $avat, $mail) = @_;
    my ($ds) = LoadFile($userPath.0);
    my $count = $ds->{0};
    my ($text);
    my $flag = 1;
    for (1..$count) {
        if ($name eq $ds->{$_}{2}) {
           $text = 'This name exists';
           $flag = 0; 
        }
        if ($mail eq $ds->{$_}{3}) {
           $text = $text.'<p>This email exists'; 
           $flag = 0;
        }
    }
    if ($flag == 1) {
        my ( $pass, $info );
        newpass: while (1) {
            my @chars = split( " ","A B C D E F G H I J K L" );
            for (0..5){
                $pass .= $chars[int(rand 12)]
            }
            for (1..$count) {
                if ($pass eq $ds->{$count}{1}) {
                    next newpass
                }
            }
            last
        }
        $count++;
        $ds->{$count}{0} = $count;
        $ds->{$count}{1} = $pass;
        $ds->{$count}{2} = $name;
        $ds->{$count}{3} = $mail;
        $ds->{0} = $count;
        DumpFile($userPath.0, $ds);
        my $auth = 100;
        $info->{0}{0} = $name;
        $info->{0}{1} = $avat;
        $info->{0}{2} = $mail;
        $info->{0}{3} = 1;
        for (0..7) {
            $info->{1}{0}{$_} = 0;
        }
        $info->{1}{0}{3} = 1;
        $info->{1}{0}{7} = 1;
        $info->{1}{1}{0} = $auth;
        $info->{1}{2}{0} = 0;
        $info->{1}{3}{0} = 0;
        my ($ds1) = LoadFile($userPath.'best');
        for (1..$auth) {
            my $film = $ds1->{$_};
            $info->{1}{1}{$_} = {%$film};
        }

        my $num = 1;
        for my $rs ( 1.. $count-1) {                                          # MAKING FRIENDSFILES
            my $rs1 = $ds->{$rs}{0};
            my ($ds1) = LoadFile($userPath.$rs1);
            $info->{2}{0} = $num;
            $info->{2}{$num} = {
                0 => $rs1,
                1 => $ds1->{0}{0},
                2 => $ds1->{0}{1},
                3 => 'G',
            };
            $num++;
            my $coun = $ds1->{2}{0};
            $ds1->{2}{0} = $coun+1;
            $ds1->{2}{$coun+1} = {
                0 => $ds->{$count}{0},
                1 => $info->{0}{0},
                2 => $info->{0}{1},
                3 => 'G',
            };
            DumpFile($userPath.$rs1, $ds1);    
        }
        DumpFile($userPath.$count, $info);
    }
    return $text;
}
sub tempIn {
    my ($self, $cols0, $userPath) = @_;
    my $path = $userPath.'temp';
    my $mediainfo = {%$cols0};
    DumpFile($path, $mediainfo);
}
sub tempOut {
    my ($self, $cols, $userPath) = @_;
    my %cols;
    my $path = $userPath.'temp';
    my $ds = LoadFile($path);
    $cols{$_} = $ds->{$_} foreach (@$cols);
    return %cols
}
sub create {
    my ($self, $cols, $userPath) = @_;
    my $ds = LoadFile($userPath.'base');
    my $max = $ds->{0}+1;
    $ds->{$max} = {%$cols};
    $ds->{0} = $max;
    DumpFile($userPath.'base', $ds);
}
sub step {
    my ($self, $param, $next, $count) = @_;
    if    ( $param->{'Next_l.x'} or $param->{'Next_r.x'} ) {
        $next = $next + 4;
        $next = 0             if $next > ($count-$count%3);
    }
    elsif ( $param->{'Last_l.x'} or $param->{'Last_r.x'} ) {
        $next = $next - 4;
        $next = ($count-$count%3)            if $next < 0;
    }
    return $next
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
sub magic {
    my ( $self, $ds, $cout, $dsl, $dsb ) = @_;
    my $count = $ds->{1}{2}{0}+1;                                       # USER CHOOSE COUNTER
    my $new = $dsl->{1}{1}{$cout};
    my ( @dna, @dna1, @dna2, %dna, @seen, @tosee, @tosee0, @code );
    my ( $dna4, $dna5 ) = ( 'a0a0', '9999' );
    
    push @dna, substr ($ds->{1}{1}{$cout}{'code'}, 4*$_, 4) for (1..3); # DNA
    if ($ds->{0}{'DNA1'}) {                                             
        push @dna1, split ':', $ds->{0}{'DNA1'};
        push @dna2, split ':', $ds->{0}{'DNA2'};
        $dna{$dna1[$_]} = $dna2[$_] for (1..@dna1-1);
        foreach my $four1 (0..2) {
            foreach my $four2 (keys %dna){
                if ($dna[$four1] eq $four2 ){
                    $dna{$four2} = $dna{$four2} + 1;
                    $dna[$four1] = undef
                } 
            }
        }           
        for ( @dna ) {
            $dna{$_} = 1001 if($_);
        }
        foreach (sort {$dna{$b}<=>$dna{$a}} keys %dna){
            $dna4 = $dna4.':'.$_;
            $dna5 = $dna5.':'.$dna{$_};
        }
        $ds->{0}{'DNA1'} = $dna4;
        $ds->{0}{'DNA2'} = $dna5;
    } 
    else {
        $ds->{0}{'DNA1'} = 'a0a0:'.$dna[0].':'.$dna[1].':'.$dna[2];
        $ds->{0}{'DNA2'} = '9999:1001:1001:1001';
        $dna{$dna[$_]} = '1001' for 0..2;
    }
    $ds->{1}{2}{0} = $count;    
    $ds->{1}{2}{$count} = {%$new};                                      # USER CHOOSE
    $ds->{1}{2}{$count}{'grey'} = 'G';    

    if ($ds == $dsl) {
        push @seen, $ds->{1}{1}{$_}{'code'} for (1..$ds->{1}{1}{0});
        push @seen, $ds->{1}{2}{$_}{'code'} for (1..$count);
        push @seen, $ds->{1}{3}{$_}{'code'} for (1..$ds->{1}{3}{0});
        push @tosee0, $dsb->{1}{2}{$_} for (1..$dsb->{1}{0});
        foreach my $tosee (@tosee0) {
            my $equal = 0;
            foreach my $seen (@seen) {
                if ($tosee eq $seen){
                    $equal = 1;
                }
            }
            push @tosee, $tosee if $equal == 0;
        }
        my (%ureit1, $winer);
        $ureit1{$_} = 0 for (@tosee);
        foreach my $tosee (@tosee) {                                    # REITS
            my @parts;
            for (1..3) {
                push @parts, substr $tosee, $_*4, 4;
            }
            foreach my $part (@parts) {
                while ( my ( $dna1, $dna2 ) = each %dna ) {
                    $ureit1{$tosee} = $ureit1{$tosee} + $dna2 if ($part eq $dna1)
                }
            }
        }
        foreach (sort {$ureit1{$b}<=>$ureit1{$a}} keys %ureit1) {
            $ureit1{$_} = $ureit1{$_} + $dsb->{1}{1}{$_}{'reit'};
            last if %ureit1 eq 4;
        }
        foreach (sort {$ureit1{$b}<=>$ureit1{$a}} keys %ureit1) {
            $winer = $_;
            last;
        }
        my $num = 1;
        my $dsc;
        $dsc->{0}{0} = $winer;
        $dsc->{0}{1} = $ureit1{$winer};
        $dsc->{0}{2} = $dsb->{1}{1}{$winer}{'runame'};    
        for (@tosee) {
            $dsc->{1}{$num}{0} = $ureit1{$_};
            $dsc->{1}{$num}{1} = $dsb->{1}{1}{$_}{'reit'};
            $dsc->{1}{$num}{2} = $_;
            $dsc->{1}{$num}{3} = $dsb->{1}{1}{$_}{'runame'};
            $dsc->{1}{$num}{4} = 'WWWWWWWWWWWWWWWWWWWWWWWW' if $dsc->{1}{$num}{2} eq $winer;
            $num++;
        }
        delete $ds->{1}{1}{$cout};
        $ds->{1}{1}{$cout} = $dsb->{1}{1}{$winer};
        return $dsc, $winer;
    }
}
sub del {
    my ( $self, $ds, $rcent, $maxr ) = @_;
    my $side;
    my $count = $ds->{1}{3}{0}+1;
    $ds->{1}{3}{$count} = $ds->{1}{2}{$rcent}{'code'};
    $ds->{1}{3}{0} = $count;
    delete $ds->{1}{2}{$rcent};
    $ds->{1}{2}{0} = $maxr-1;
    if ($ds->{1}{2}{0}== 0) {
        $side = 0;
    }
    else {
    my $n = 1;
        while ($ds->{1}{2}{$rcent+$n}) {
            my $next = $ds->{1}{2}{$rcent+$n};
            $ds->{1}{2}{$rcent+$n-1} = {%$next};
            delete $ds->{1}{2}{$rcent+$n};
            $n++;
        }
    }
    return $side
}
=head1 NAME
kshisa::Model::Yaml - Catalyst Model
=head1 DESCRIPTION
Catalyst Model.
=encoding utf8
=head1 AUTHOR
Marat,,,
=head1 LICENSE
This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.
=cut
__PACKAGE__->meta->make_immutable;

1;
