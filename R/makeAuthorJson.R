# This script will print a json file of author names and uuids for the authorSynth web interface.

setwd("/home/vanessa/Documents/Dropbox/Code/Python/authorSynth/data")

# Here is out directory for authors.json
outdir = "/var/www/authorSynth/data"

# Here is author data, filter to just PIs
authors = read.csv("authors.txt",sep="\t",head=TRUE)
authors = authors[authors$PI ==1,]

# [{"label" : "United Arab Emirates","value":"00001"},]
sink(paste(outdir,"/authors2.json",sep=""))
cat("[")
for (i in 1:(nrow(authors)-1)){
  if (authors$NUMPAPERS[i] >= 2){
    cat('{"label" :"',as.character(authors$AUTHOR[i]),'","value" : "',as.character(authors$UUIDS[i]),'"},\n',sep="")
  }
}
for (i in nrow(authors)){
  if (authors$NUMPAPERS[i] >= 2){
    cat('{"label" : "',as.character(authors$AUTHOR[i]),'","value" :"',as.character(authors$UUIDS[i]),'"}]\n')
  }
}
sink()