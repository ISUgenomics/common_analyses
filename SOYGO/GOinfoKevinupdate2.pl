#!/usr/bin/perl
($infile1,$infile2)=@ARGV;
open (DATAHASH,$infile2) || die "Cannot open $infile2 \n";
while (<DATAHASH>) {
    @tmp=split /\t/;
    chomp @tmp;
   $gmid=$tmp[0];
    chomp $affyid;
    $GOBP= $tmp[2];
    chomp $GOBP;
    $GOMF=$tmp[3];
    chomp $GOMF;
    $GOCC=$tmp[4];
    chomp $GOCC;
    $data= $gmid . "\t" . $GOBP . "\t" . $GOMF . "\t" . $GOCC;
    $data=$gmid . "\t" . $GOBP . "\t" . $GOMF;
#    print "$data\n";
    foreach $gmid (@tmp) {
	if ($gmid ne "") {
	    $data_lookup{$gmid} = $data;
	}
	
    }
#    $data='';
    $gmid='';
    $GOBP='';
    $GOMF='';
    $GOCC='';
    $data=''
}
close (DATAHASH);
open (QUERY,$infile1) || die "Cannot open $infile1 \n";

while (<QUERY>) {
    @fields= split /\t/;
    chomp @fields;
    $requested_gm_id=$fields[0];
    chomp $requested_gm_id;
    if($requested_gm_id =~ /(Glyma\.\d{0,}\D{1}\d{6})/){
	$new_requested_gm_id=$1;
    }

#    print MYOUT "$requested_gm_id\n";
    

    else {
	$new_requested_gm_id=$requested_gm_id;
    }
    if (defined($data_lookup{$new_requested_gm_id})){
	print $data_lookup{$new_requested_gm_id};
	print "\n";
    }
    else {
	# DO NOTHING

    }
    

	
    
}


close (QUERY);
close (MYOUT);
exit 0;



