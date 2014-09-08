# This script will plot authorBrain maps on the SOM grid of neuroSynth images.  This
# is done by matching the authorBrains to each of the best matching units,
# and rendering the scores as the color on the plot.  We will save these images to file
# under "img" to incorporate with a d3

library("RColorBrewer")
rbPal <- colorRampPalette(brewer.pal(8,"YlOrRd"))

# Here is for 124 Authors
# Load the network variables, as well as the SOM (pAgF)
setwd("/home/vanessa/Documents/Dropbox/Code/Python/authorSynth/app")
load("som_pAgF.Rda")

# Load the author match scores to the SOM
load("/home/vanessa/Documents/Work/NEUROSYNTH/authorSynth/scoresNeuroSynth/allScoresPIAuthors3383.Rda")
authors = sort(rownames(somMatch$euc))

for (author in authors) {
  dat = somMatch$cos[author,]
  dat = (dat - min(dat)) / (max(dat)-min(dat))
  dat = c(0,as.numeric(dat),1)
  color = rbPal(10)[as.numeric(cut(dat,breaks = 10))]
  color = color[-c(1,508)]
  png(file=paste("img/",gsub(" ","",author),".png",sep=""),width=14,height=14,units="in",res=300)
  plot(brainMap$som$grid$pts,main=paste("Summary of Neuroscience Work for Author",author),col=color,xlab="Meta Brain Map Nodes",ylab="Meta Brain Map Nodes",pch=15,cex=8)
  text(brainMap$som$grid$pts,brainMap$labels,cex=.5)   
  dev.off()
}

# Here is for PI (3K) Authors
authors = as.character(gsub("_pAgF_z_FDR_0.05_score.Rda","",sort(rownames(somMatch$euc))))
auth = read.csv("/home/vanessa/Documents/Dropbox/Code/Python/authorSynth/data/authors.txt",sep="\t",head=TRUE)
labels = as.character(auth$AUTHOR[match(authors,auth$UUIDS)])
imgdir = "/home/vanessa/Documents/Work/NEUROSYNTH/authorSynth/imgNeuroSynth/euc/"
authors = sort(rownames(somMatch$euc))

# Output images
for (a in 1:length(authors)) {
  author = authors[a]
  dat = somMatch$cos[author,]
  dat = (dat - min(dat)) / (max(dat)-min(dat))
  dat = c(0,as.numeric(dat),1)
  color = rbPal(10)[as.numeric(cut(dat,breaks = 10))]
  color = color[-c(1,508)]
  png(file=paste("/home/vanessa/Documents/Work/NEUROSYNTH/authorSynth/imgNeuroSynth/",gsub(" ","",author),".png",sep=""),width=14,height=14,units="in",res=300)
  plot(brainMap$som$grid$pts,main=paste("Summary of Neuroscience Work for Author",labels[a]),col=color,xlab="Meta Brain Map Nodes",ylab="Meta Brain Map Nodes",pch=15,cex=8)
  text(brainMap$som$grid$pts,brainMap$labels,cex=.5)   
  dev.off()
}
