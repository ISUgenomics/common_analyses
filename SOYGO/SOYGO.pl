#####################################################################################
#												#
#Program to write a table for R to calculate p-values due to Fisher-exact Test	#
#for GO-annotations. 									#
#												#
#Usage: perl SOYGO.pl database list_of_ID_to_analyze					#
#												#
#Modifications by Luis Pedro Iñiguez Rábago (liniguez@lcg.unam.mx)			#
#Original written by Michelle Graham, USDA-ARS (michelle.graham@ars.usda.gov) 	#
#												#
#####################################################################################


#################################################################################################################
#																#
#NOTE:The important files are the database, the list of genes, and both _MF_fisher.txt and _BP_fisher.txt	#
#																#
#################################################################################################################


##############################################################################
#											#
#Read database and count total of GO's in db					#
#											#
#database:										#
#ID\tName\tBiological_Process(GOnumber)\tMolecular_Function(GOnumber)\n	#
#											#
##############################################################################

open(DB, "$ARGV[0]")||die "I cannot open file $ARGV[0]\n"; #database of the GO's anotations (Glyma2GODB_TAIR10)
while(<DB>){
	@vec=split("\t",$_);
	$ID=$vec[0];
#	print "$ID\n";
	$GOBP=$vec[2];
	$GOMF=$vec[3];
#	print "$GOBP\n";
#	print "$GOMF\n";
	@tempBP=split(/\s/,$GOBP);
	@tempMF=split(/\s/,$GOMF);
#	print @tempBP;
#	print "\n";
#	print @tempMF;
#        print "\n";
	undef %saw;
	@uniquedataBP = grep(!$saw{$_}++, @tempBP);		# Ensures each GOID represented only once for each gene
	undef %saw;
	@uniquedataMF = grep(!$saw{$_}++, @tempMF);
	foreach $key (@uniquedataBP){
		if(!$key){next;}
		$GOcountBP{$key}++;					# Counts the number of time the same GO appears in database		
	}
	foreach $key (@uniquedataMF){
		if(!$key){next;}
		$GOcountMF{$key}++;
	}
	$dataBP = join(" ",@uniquedataBP);
	chomp $dataBP;
	$dataMF = join(" ",@uniquedataMF); 
	chomp $dataMF;
#	print "$dataBP\n";
	$data_lookupBP{$ID}= $dataBP;
	$data_lookupMF{$ID}= $dataMF;
	undef $GMID; undef $GOBP; undef $GOMF; undef @vec; undef @tempBP; undef @tempMF;undef @uniquedataBP; undef @uniquedataMF;
}
close DB;

#############################
#				#
#Read list of ID to analyze	#
#				#
#list:				#
#ID\n				#
#				#
#############################

open(LS, "$ARGV[1]")||die "I cannot open file $ARGV[0]\n"; #list with names of genes
open(GOMF, ">$ARGV[1]_MF.txt")|| die "I cannot create the file MF\n";
open(GOBP, ">$ARGV[1]_BP.txt")|| die "I cannot create the file BP\n";
open(ERROR, ">$ARGV[1]_ERROR.txt")|| die "I cannot create the error file\n";


while(<LS>){
	$line=$_; chomp($line);
	@vec= split(/\t/,$line);
	$req_ID=$vec[0];
	if($req_ID =~ /(Glyma\.\d{0,}\D{1}\d{6})/){
		$req_ID=$1;
	}
	if($checkrep{$req_ID}){next;}					  #Ignores duplicate Glyma IDs in input list
	if(defined($data_lookupBP{$req_ID})||defined($data_lookupMF{$req_ID})){	#Determines if GlymaID present in GO database
		$resultsMF=$data_lookupMF{$req_ID};
		$resultsBP=$data_lookupBP{$req_ID};
		$resultsMF =~ s/\s/\n/g;
		$resultsBP =~ s/\s/\n/g;
		print GOMF "$resultsMF\n";							#Prints the lists of GOIDs into two files for BP and MF
		print GOBP "$resultsBP\n";
	}else{
	    print ERROR "ERROR $req_ID not found in database\n";      #Prints GlymaID to error file if not found in database. 

	}
	$checkrep{$req_ID}=1;
}
close(LST, GOMF, GOBP);

#############################
#				#
#Read pevious list of GO'se	#
#				#
#list:				#
#GO_number\n			#
#				#
#############################


open(GOMF, "$ARGV[1]_MF.txt")|| die "I cannot create the file MF\n";
open(GOBP, "$ARGV[1]_BP.txt")|| die "I cannot create the file BP\n";
#open(COUMF, ">$ARGV[1]_MF_count.txt")|| die "I cannot create the file MF_count\n";
#open(COUBP, ">$ARGV[1]_BP_count.txt")|| die "I cannot create the file BP_count\n";
#open(CMPMF, ">$ARGV[1]_MF_compared.txt")|| die "I cannot create the file MF_compared\n";
#open(CMPBP, ">$ARGV[1]_BP_compared.txt")|| die "I cannot create the file BP_compared\n";

while(<GOMF>){ 							#Counts the number of times a GO appears in the input list (Molecular Function)
	$line=$_; chomp $line;
	if(!$line){next;}
	$MF{$line}++;
	$totexprMF++;							#Counts the total number of GO categories in the input list (Molecular Function)
}
while(<GOBP>){							#Same as above but for the Biological Process
	$line=$_; chomp $line;
	if(!$line){next;}
	$BP{$line}++;
	$totexprBP++;							
}
foreach $key (keys %MF){ 						
	if(!$key){next;}
	#print COUMF "$key\t$MF{$key}\n";				#Print a file with the GO number and the number of times it appears in the input list. (Molecular Function)
	print CMPMF "$key\t$GOcountMF{$key}\t$MF{$key}\n";
	$totMF=$totMF+$GOcountMF{$key};				#Calculates the sum of GO in the DB (Molecular Function)
	
}
foreach $key (keys %BP){ 						#Same as above but for the Biological Process
	if(!$key){next;}
	#print COUBP "$key\t$BP{$key}\n";				
	print CMPBP "$key\t$GOcountBP{$key}\t$BP{$key}\n";
	$totBP=$totBP+$GOcountBP{$key};				
}
#close(GOMF, GOBP, COUMF, COUBP, CMPMF, CMPBP);
close (GOMF, GOBP);
#######################################################################
#										#
#Uses info previously saved to create a table that would be read in R	        #
#										#
#######################################################################


open(FSHMF, ">$ARGV[1]_MF_fisher.txt")|| die "I cannot create the file MF_fisher\n";
open(FSHBP, ">$ARGV[1]_BP_fisher.txt")|| die "I cannot create the file BP_fisher\n";
open(OUTMF, ">$ARGV[1]_MF_out.txt")|| die "I cannot create the file MF_out\n";
open(OUTBP, ">$ARGV[1]_BP_out.txt")|| die "I cannot create the file BP_out\n";
open(NMSMF, ">$ARGV[1]_MF_names.txt")|| die "I cannot create the file MF_names\n";
open(NMSBP, ">$ARGV[1]_BP_names.txt")|| die "I cannot create the file BP_names\n";

foreach $key (keys %MF){ 
	$noexpgoMF=$GOcountMF{$key}-$MF{$key};						#Calculates all the numbers you need for the fisher's exact test (Molecular Function)
	$expnogoMF=$totexprMF-$MF{$key};
	$noexpnogoMF=$totMF-$GOcountMF{$key};
	print FSHMF "$key\t$MF{$key}\t$noexpgoMF\t$expnogoMF\t$noexpnogoMF\n";	#Print the infomation in the file _MF_fisher.txt (Molecular Function)
	print NMSMF "$key\n";								#file with the names (Molecular Function)
	print OUTMF "$MF{$key}\t$noexpgoMF\t$expnogoMF\t$noexpnogoMF\n";		#file with the values (Molecular Function)
}
foreach $key (keys %BP){ 									#Same as above but for the Biological Process
	$noexpgoBP=$GOcountBP{$key}-$BP{$key};
	$expnogoBP=$totexprBP-$BP{$key};
	$noexpnogoBP=$totBP-$GOcountBP{$key};
	print FSHBP "$key\t$BP{$key}\t$noexpgoBP\t$expnogoBP\t$noexpnogoBP\n";
	print NMSBP "$key\n";
	print OUTBP "$BP{$key}\t$noexpgoBP\t$expnogoBP\t$noexpnogoBP\n";
}
close(FSHMF, FSHBP, OUTMF, OUTBP, NMSMF, NMSBP);


