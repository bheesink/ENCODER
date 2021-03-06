### Generate annotation files (GC-content, mappability and bed files) for desired binSize

preENCODER<-function(MAPA_GC_location, outputFolder, binSize, reference){
	
	####### Checks
	## Check whether folders exist.
	if(file.exists(paste(outputFolder))==FALSE){
	stop("The outputFolder could not be found. Please change your outputPath.")}
	
	if(file.exists(paste(MAPA_GC_location))==FALSE){
	stop("The annotation folder could not be found. Please change your MAPA_GC_location path.")}
		
	## Check MAPA_GC_location for 1kb files
	# For hg19 (human)
	if (reference=="hg19"){
		if(file.exists(paste(MAPA_GC_location, "/hg19_1kb/", sep=""))){
			cat("Reference folder hg19_1kb detected", "\n")
		}
	}
	# For mouse (mm10)
	if (reference=="mm10"){
		if(file.exists(paste(MAPA_GC_location, "/mm10_1kb/", sep=""))){
			cat("Reference folder mm10_1kb detected", "\n")
		}
	}
	if (!(reference == "hg19" || reference == "mm10")){
		stop("The reference is not recognised. Please provide a suitable reference (mm10 or hg19).")
	}
	
	## Check if binSize is factor of 1kb
	if(!.is.wholenumber(binSize/1000)){
		stop("Please provide a binSize which is a multiplication of 1000.")
	}
	
	####### 
	## Generate files with desired binSize (MAPA, GC, bed, blacklist)
	
	# Load blacklist, CG-content and mapability files
	load(paste(MAPA_GC_location, "/hg19_1kb/mapa_1kb.rda", sep=""))
	load(paste(MAPA_GC_location, "/hg19_1kb/GCcontent_1kb.rda", sep=""))
	bed_file<-read.table(paste(MAPA_GC_location, "/hg19_1kb/blacklist-nochr.bed", sep=""), sep="\t")

	## Create output files

	###### Create bins with desired bin size

	MERGEBINNUMBER <- binSize/1000
	
	newBin <- NULL
	options(warn = -1)
	options(scipen = 999)
	for(chr in unique(mapa[,1])) {
		col2 <- colMins(matrix(mapa[mapa[,1] == chr,2], nrow = MERGEBINNUMBER))
		col3 <- colMaxs(matrix(mapa[mapa[,1] == chr,3], nrow = MERGEBINNUMBER))
		tmp <- cbind(chr, col2, col3)
		tmp <- tmp[1:(nrow(tmp)-1),]
		newBin <- rbind(newBin, tmp)
	}
	options(scipen = 0)
	options(warn = 0)
	
	cat("Generated", binSize, "bp bins for all chromosomes", "\n")
	
	
	###### Create mapabillity file with desired bin size

	MERGEBINNUMBER <- binSize/1000

	newMapa <- NULL
	options(warn = -1)
	options(scipen = 999)
	for(chr in unique(mapa[,1])) {
		col2 <- colMins(matrix(mapa[mapa[,1] == chr,2], nrow = MERGEBINNUMBER))
		col3 <- colMaxs(matrix(mapa[mapa[,1] == chr,3], nrow = MERGEBINNUMBER))
		col4 <- colMeans(matrix(mapa[mapa[,1] == chr,4], nrow = MERGEBINNUMBER))
		tmp <- cbind(chr, col2, col3, col4)
		tmp <- tmp[1:(nrow(tmp)-1),]
		newMapa <- rbind(newMapa, tmp)
	}
	options(scipen = 0)
	options(warn = 0)
	
	cat("Generated mapabillity file for binSize of", binSize,"bp", "\n")	
	
	###### Create GC-content file with desired bin size

	newGC <- NULL
	options(warn = -1)
	options(scipen = 999)
	for(chr in unique(mapa[,1])) {
		col2 <- colMins(matrix(GC2[GC2[,1] == chr,2], nrow = MERGEBINNUMBER))
		col3 <- colMaxs(matrix(GC2[GC2[,1] == chr,3], nrow = MERGEBINNUMBER))
		col4 <- colMeans(matrix(GC2[GC2[,1] == chr,4], nrow = MERGEBINNUMBER))
		col5 <- colMeans(matrix(GC2[GC2[,1] == chr,5], nrow = MERGEBINNUMBER))
		tmp <- cbind(chr, col2, col3, col4, col5)
		tmp <- tmp[1:(nrow(tmp)-1),]
		newGC <- rbind(newGC, tmp)
	}
	options(scipen = 0)
	options(warn = 0)

	newGC<-newGC[-which(newGC[,1]=="MT"),]
	cat("Generated GC-content file for binSize of", binSize,"bp", "\n")		
	
	
	
	# Create folder for output files
	file_name<-paste(reference, "_", binSize/1000, "kb", sep="")
	dir.create(paste(outputFolder, file_name, sep=""))
	if(file.exists(paste(outputFolder, file_name, sep=""))==FALSE){
		stop("No output folder created, please check `outputFolder` and folder permissions.")
	}

	## Write files to folder
	# Blacklist
	write.table(bed_file, file=paste(outputFolder, file_name,"/blacklist.bed", sep=""), quote=F, row.names=F, sep="\t", col.names=F)
	# GC-content
	write.table(newGC, file=paste(outputFolder, file_name,"/GC_content.bed", sep=""), quote=F, row.names=F, sep="\t", col.names=F)
	# Mapability
	write.table(newMapa, file=paste(outputFolder, file_name,"/mapability.bed", sep=""), quote=F, row.names=F, sep="\t", col.names=F)	
	# bed file with bins
	write.table(newBin, file=paste(outputFolder, file_name,"/bins.bed", sep=""), quote=F, row.names=F, col.names=F, sep="\t")

	
}

