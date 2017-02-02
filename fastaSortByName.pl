#!/usr/bin/perl -w

my $usage="\nUsage: $0 [-hrg] [fastaFileName1 ...]\n".
    "  -h: help\n".
    "  -r: reverse\n" .
    "  -g: remove gaps '-' from the sequence\n".
    "Sort FASTA sequences alphabetically by names.  If multiple files are \n".
    "given, sequences in all files are marged before sorting.  If no \n".
    "argument is given, it will take STDIN as the input\n";

our($opt_h, $opt_g, $opt_r);

use Bio::SeqIO;

use Getopt::Std;
getopts('hgr') || die "$usage\n";
die "$usage\n" if (defined($opt_h));

my $format = "fasta";
my @seqArr = ();

@ARGV = ('-') unless @ARGV;
while (my $file = shift) {
    my $seqio_obj = Bio::SeqIO->new(-file => $file, -format => $format);
    while (my $seq = $seqio_obj->next_seq()) {
	push(@seqArr, $seq);
    }
}

if (defined($opt_r)) {
    @seqArr = sort { - ($a->id() cmp $b->id()) } @seqArr;
} else {
    @seqArr = sort { $a->id() cmp $b->id() } @seqArr;
}


my $seqOut = Bio::SeqIO->new(-fs => \*STDOUT, -format => $format);
foreach my $s (@seqArr) {
    if(defined($opt_g)) {
	my $tmp = $s->seq();
	$tmp =~ s/-//g;
	$s->seq($tmp);
    }
    $seqOut->write_seq($s);
}

exit;


