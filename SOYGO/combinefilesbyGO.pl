#!/usr/bin/perl
($infile1,$infile2,$infile3)=@ARGV;
open (MATH, $infile1) || die "Cannot open $infile1 on attempt 1\n";
@genome='';
@exp='';
$count=0;
$flag='';
while (<MATH>) {
    @fields= split /\t/;
    $name=$fields[0];
    $expGO=$fields[1];
    $noexpGO=$fields[2];
    chomp $expGO;
    chomp $noexpGO;
    push (@genome, $noexpGO);
    push (@exp, $expGO);
    $chipcount='';
    $expressedcount='';
    if ($name=~ /GO/) {
	$count++;
    }
}
close MATH;
$sumexpGO=0;
for (@exp) {
    $sumexpGO += $_;
}

$sumnoexpGO = 0;
for ( @genome) {
    $sumnoexpGO += $_;
}
$genomeGO=$sumexpGO+$sumnoexpGO;
#print "$genomeGO\t$sumexpGO\t$sumnoexpGO\t$count\n";

open (DATAHASH,$infile1) || die "Cannot open $infile1 on attempt 2\n";
while (<DATAHASH>) {
    @tmp=split /\t/;
    $goid=$tmp[0];
    chomp $goid;
    $F1= $tmp[1];
    chomp $F1;
    $F2=$tmp[2];
    chomp $F2;
    $F3=$tmp[3];
    chomp $F3;
    $F4=$tmp[4];
    chomp $F4;
    if ($goid=~ /GO/){
	$GOwholechip=$F1 + $F2;
	$expected_expression=($sumexpGO * $GOwholechip)/$genomeGO;
	if ($expected_expression >= $F1) {
	    $flag= 'Underrepresented';
	}
	else {
	    $flag='Overrepresented';
	}
	$data= $goid . "\t" . $GOwholechip . "\t" . $F1 . "\t" . $F1 . "\t" . $F2 . "\t" . $F3 . "\t" . $F4 .  "\t" . $expected_expression . "\t" . $flag;

	foreach $goid (@tmp) {
	    if ($goid ne "") {
		$data_lookup{$goid} = $data;
	    }
	
	}
    }	
    $flag='';
    $expected_expression='';
    $goid='';
    $F1='';
    $F2='';
    $F3='';
    $F4='';
    $wholechip='';
    $data='';
	
}
close DATAHASH;
open (GODATA, $infile2) || die "Cannot open file $infile2 \n";
while (<GODATA>) {
    @GOinfo= split /\t/;
    $go_desc=$GOinfo[4];
    $go=$GOinfo[5];
    chomp $go;
    
    foreach $go (@GOinfo) {
	if ($go ne "") {
	    $go_lookup{$go} = $go_desc;
	}
	
    }

    $go_desc='';
    $go='';
}


close GODATA;
#print "Go_term\tGenome_count\tExp_count\tFA\tFB\tFC\tFD\tExpected_EXP\tRepresentation\tTwo_Tail_P\tCorrected_P\tGO_description\n";
open (STATS,$infile3) || die "Cannot open $infile3 \n";
open (TMP, ">TMP.data") || die "Cannot open $infile3 \n"; #creates temporary file for data storage
 
while (<STATS>) {
    @fields= split /\t/;
    chomp @fields;
#    print @fields;
    $requested_go_id=$fields[1];
    chomp $requested_go_id;
    $pvalue=$fields[2];
    chomp $pvalue;
    $correctedP=$pvalue * $count;
#    print "$requested_go_id\t$pvalue\n";
    if ($requested_go_id =~ /GO/){
	if (defined($data_lookup{$requested_go_id})){
	    print TMP $data_lookup{$requested_go_id};
	    print TMP "\t$pvalue\t$correctedP";
	    
	}
	if (defined($go_lookup{$requested_go_id})) {
	    print TMP "\t";
	    print TMP $go_lookup{$requested_go_id};
	    print TMP "\n";
	}
	
	else {
	    print TMP "ERROR $requested_go_id not found\n";
	}
    } 
    $requested_go_id='';
    $pvalue='';
    $correctedP='';

    

}


close STATS;
close TMP;
print "GO_id\tGenome_GO_count\tExpressed_GO\tFisherA\tFisherB\tFisherC\tFisherD\tExpected_expression\tStatus\tTwo_Tail_P\tCorrected_P\tGO_desc\n";
open(TMPSORT, "TMP.data")||die "I cannot open file TMP.data \n";
my @data= map{[split/\t/]}<TMPSORT>;
close TMPSORT;
chomp @data;

@data=sort{$$a[10]<=>$$b[10]}@data;


#@data=sort{$$a[1]cmp$$b[1]||$$a[3]cmp$$b[3]}@data;
@data=map{join("\t",@{$_})}@data;
print "@data";

close (TMPSORT);
exit 0;




