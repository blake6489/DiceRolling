#!/usr/bin/env perl
#writen by substack
use warnings;
use strict;
use List::MoreUtils qw/zip/;
$|++;

print "Type how many dice the attacker, and the defender will roll and press enter.  If **more** apears, press enter again until you are satisfied, type 'q' to end the dice rolling turn. \n";
print "> ";
while (my $line = <STDIN>) {
	#magic regexp to parse input of force strengths
    my ($attack, $defend) = grep defined, $line =~ m/^ (?:
        (\d)(\d) | (\d+)\W+(\d+)
    ) $/x;
    if (not defined $attack or not defined $defend) {
        print "> ";
        next;
    }
    
    my %lost = (attack => 0, defend => 0);
    until ($attack - $lost{attack} == 0 or $defend - $lost{defend} == 0) {
        my $xa = $attack - $lost{attack};
        my $xd = $defend - $lost{defend};
        my @lost = roll(
            ($xa > 3 ? 3 : $xa),
            ($xd > 2 ? 2 : $xd),
        );
        $lost{attack} += $lost[0];
        $lost{defend} += $lost[1];
        $xa -= $lost[0];
        $xd -= $lost[1];
        
        print "    -- attacker lost $lost[0], has $xa\n";
        print "    -- defender lost $lost[1], has $xd\n";
        unless ($xa == 0 or $xd == 0) {
            print "    ** more **\n";
            my $cmd = <STDIN>;
            chomp $cmd;
            last if $cmd eq "q";
        }
    }
    my $ax = $attack - $lost{attack};
    my $dx = $defend - $lost{defend};
    print "attacker lost $lost{attack}, has $ax\n";
    print "defender lost $lost{defend}, has $dx\n";
    print "> ";
}

sub roll {
    my @ax = sort { $b <=> $a } map { int 1 + rand 6 } 1 .. shift;
    my @dx = sort { $b <=> $a } map { int 1 + rand 6 } 1 .. shift;
    print "    attacker rolled: @ax\n";
    print "    defender rolled: @dx\n";
    my ($lost_a, $lost_d) = (0, 0);
    for my $i (0 .. (@ax > @dx ? @dx : @ax) - 1) {
        if ($ax[$i] > $dx[$i]) {
            $lost_d ++;
        }
        else {
            $lost_a ++;
        }
    }
    return $lost_a, $lost_d;
}
