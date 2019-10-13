#!/usr/bin/perl -w
#
# script AGPFILE FASTA

use strict;

use Bio::DB::Fasta;
use Bio::Seq;
use Bio::SeqIO; 
    
open(AGP,shift()) or die $!;

my %chr;
      
my $db = Bio::DB::Fasta->new(shift());

my $seq_out = Bio::SeqIO->new('-file' => ">supercontigs.fa",'-format' => 'fasta');
my ($lastid,$last_seq);
while(<AGP>){
        chomp;
	my @F = split /\s+/;

	$lastid=$F[0] unless $lastid;

        if ($F[0] ne $lastid){
	 print_seq($lastid,$last_seq);
	 $lastid=$F[0];
         $last_seq='';
	}


	# extend temp string if it's too short
	do{$last_seq.= ' ' x 10_000;} while length $last_seq < $F[2] ;
	if($F[4] !~ m/N/){
		my ($start,$stop) = $F[8] eq '+'?($F[6], $F[7]):($F[7], $F[6]);
		my $s = substr $last_seq, $F[1], $F[7], $db->seq($F[5],$start,$stop);
	}else{
	        my $s = substr $last_seq, $F[1], $F[5], "N" x $F[5] ;
	}
} 

print_seq($lastid,$last_seq);

sub print_seq{
         my($id,$seq)=@_;	
	 $seq=~s/\s+//g;
         my $seqobj = Bio::Seq->new( -display_id => "$id", -seq => $seq);
         $seq_out->write_seq($seqobj);
}
