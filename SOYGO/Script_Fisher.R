#usage:
#R CMD BATCH "--args list_of_ID_to_analyze" Script_Fisher.R



args<-commandArgs(trailingOnly = TRUE)
file<-args[1]
fileMF<-paste(file,"_MF_fisher.txt",sep="")
MF<-read.table(file=fileMF)
names<-as.data.frame(MF[,1])
MF<-MF[,-1]
MFmatrix<-data.matrix(MF)
dataout<-NULL
for (i in 1:dim(MFmatrix)[1]){ 					 #calculate the p-value with a fisher exact test for each line for the Molecular Function
	fi<-fisher.test(matrix(c(MFmatrix[i,1],MFmatrix[i,2],MFmatrix[i,3],MFmatrix[i,4]),nrow=2),"greater")$p.value
	dataout[i]<-fi
}
dataout<-as.data.frame(dataout)
df1<- data.frame(names[,1], dataout[,1])
outMF<-paste(file,"_MF_output.txt",sep="")
write.table(df1,file=outMF,sep="\t",quote=F) 			#print the p-values of the Molecular Functions in file _MF_output.txt

fileBP<-paste(file,"_BP_fisher.txt",sep="")
BP<-read.table(file=fileBP)
names<-as.data.frame(BP[,1])
BP<-BP[,-1]
BPmatrix<-data.matrix(BP)
dataout<-NULL
for (i in 1:dim(BPmatrix)[1]){ 					#calculate the p-value with a fisher exact test for each line for the Biological Process
	fi<-fisher.test(matrix(c(BPmatrix[i,1],BPmatrix[i,2],BPmatrix[i,3],BPmatrix[i,4]),nrow=2),"greater")$p.value
	dataout[i]<-fi
}
dataout<-as.data.frame(dataout)
df1<- data.frame(names[,1], dataout[,1])
outBP<-paste(file,"_BP_output.txt",sep="")
write.table(df1,file=outBP,sep="\t",quote=F) 			#print the p-values of the Biological Precess in file _BP_output.txt
q()
n
