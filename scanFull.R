#!/usr/bin/env Rscript

#vignette(rehh)

## iHS and cross-Population or whole genome scans

args <- commandArgs(TRUE)

#--------------------------------------------------------------------------------
##		Initialize parameter and output file names			
##										
if (length(args) < 6) {
   print("", quote=F)
   print("Usage: scanFull.R [hapmap prefix] [outname] [#chr] [thresh] [threads] [MAF-threshold]", quote=F)
   print("",quote=F)
   quit(save="no")
} else {

require(rehh)
numchr <- as.numeric(args[3])
thresh <- as.numeric(args[4])
threds <- as.numeric(args[5])
mf <- as.numeric(args[6])
snpInfo <- read.table("snp.info", header = F, as.is = T)
iHSplot <- paste(args[2],"iHS.png", sep="")
iHSresult <- paste(args[2],"iHSresult.txt", sep="")
iHSfrq <- paste(args[2],"iHSfrq.txt", sep="")
qqPlot <- paste(args[2],"qqDist.png", sep="")
iHSmain <- paste(args[2],"-iHS", sep="")
sigOut <- paste(args[2],"Signals.txt",sep="")


#--------------------------------------------------------------------------------
##              Load .hap and .map files to create hap dataframe
##              Run genome scan and iHS analysis                

for(i in 1:numchr) {

  hapFile <- paste(args[1],i,".hap",sep="")
  mapFile <- mapFile <- paste(args[1],i,".map",sep="")
  data <- data2haplohh(hap_file=hapFile, map_file=mapFile, recode.allele = F,
		       min_perc_geno.hap=100, min_maf=mf, 
		       haplotype.in.columns=TRUE, chr.name=i)
  res <- scan_hh(data, threads = 10)
  if(i==1){wg.res<-res}else{wg.res<-rbind(wg.res,res)}

}

wg.ihs<-ihh2ihs(wg.res)

# Candidate regions
cr.cam <- calc_candidate_regions(wg.ihs, 
                                  threshold=4, 
                                  pval=T, 
                                  window_size=1E6, 
                                  overlap=1E5, 
                                  min_n_extr_mrk=2)

#--------------------------------------------------------------------------------
##              Extract iHS results ommitting missing value rows
##              Merge iHS results with .map file information
##		Extract positions with strong signal of selection iHS(p-val)>=4

ihs <- na.omit(wg.ihs$ihs)
mapF <- snpInfo
ns <- length(wg.res$POSITION)
print("", quote=F)
print("Effive number of SNPs (Total Number of SNPs that passed rehh filters)", quote=F)
print(ns, quote=F)
print("", quote=F)
thr <- as.numeric(-log10(0.05/ns))

# if (thr >= 8) {
# 	thresh <- 8
# } else {thresh <- thr}

print("", quote=F)
print("Bonferoni Corrected threshold", quote=F)
print(thresh, quote=F)
print("", quote=F)
map <- data.frame(ID=mapF$V1, POSITION=mapF$V3, Anc=mapF$V4, Der=mapF$V5)
ihsMerge <- merge(map, ihs, by = "POSITION")
signals <- ihsMerge[ihsMerge[,7]>=thresh,]
signals <- signals[order(signals[,5]),]
sigpos <- signals[,2]

#--------------------------------------------------------------------------------
##             			 Save results 
##             
##              

write.table(ihs, file = iHSresult, col.names=T, row.names=F, quote=F, sep="\t")
write.table(wg.ihs$frequency.class, file = iHSfrq, col.names=T, row.names=F, quote=F, sep="\t")
write.table(signals, file = sigOut, col.names=T, row.names=F, quote=F, sep="\t")

#----Add Multiple test corrections
lopP <- read.table(iHSresult, header=T)
lopP$P <- as.numeric(10^-(lopP$LOGPVALUE))
lopP$BH_adj_P <- p.adjust(lopP$P, method="BH")
lopP$Bonf <- p.adjust(lopP$P, method="bonferroni")
write.table(lopP, file = iHSresult, col.names=T, row.names=F, quote=F, sep='\t')

# Manhattan PLot of iHS results
png(iHSplot, height = 700, width = 640, res = NA, units = "px")
layout(matrix(1:2,2,1))
manhattanplot(wg.ihs, pval = F, main = iHSmain, threshold = c(-thresh, thresh))
manhattanplot(wg.ihs, pval = T, main = iHSmain, threshold = c(-thresh, thresh))
dev.off()

# Gaussian Distribution and Q-Q plots
IHS <- wg.ihs$ihs[["IHS"]]
png(qqPlot, height = 700, width = 440, res = NA, units = "px", type = "cairo")
layout(matrix(1:2,2,1))
distribplot(IHS, main="iHS", qqplot = F)
distribplot(IHS, main="iHS", qqplot = T)
dev.off()

# Frequency bin plot
freqbinplot(wg.ihs)
}
