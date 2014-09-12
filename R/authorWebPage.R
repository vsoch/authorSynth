# This script will create data for a d3 webpage for a single PI author, including:
# - data for brain lattice image
# - data for score table (author name, uuid, total collaboration score)
# - for publications table, use script metaExtract.py

# For the color palette
library("RColorBrewer")
rbPal <- colorRampPalette(brewer.pal(8,"YlOrRd"))

setwd("/home/vanessa/Documents/Dropbox/Code/Python/authorSynth/data")

# Here is out directory for brainlattice image data
latticeoutdir = "/home/vanessa/Documents/Work/NEUROSYNTH/authorSynth/d3/brainlattice"

# Here is output directory for match score data
matchoutdir = "/home/vanessa/Documents/Work/NEUROSYNTH/authorSynth/d3/matchscores"

# Here are text files with lab mates - collaborators who are not PIs
laboutdir = "/home/vanessa/Documents/Work/NEUROSYNTH/authorSynth/d3/lab"

# Here is where we get the list of highest uid matches to each node
load("brainLattice506MatchedAuthorsColors.Rda") # brainLattice$UIDS

# Here is author and coauthor data
authors = read.csv("authors.txt",sep="\t",head=TRUE)
authors = authors[authors$PI ==1,]

# WORK WITH CAUTHORS.TXT --------------------------------------
cauth = read.table("coauthnet.txt",sep="\t",head=FALSE,skip=1) 
colnames(cauth) = c("UUID","PMID","NUMPAPERS")

# Here are the match scores to compare authors dist.pagf
# This is a distance matrix (euc) based on COSINE similarity to SOM map!
load("/home/vanessa/Documents/Dropbox/Code/Python/authorSynth/data/edist_scores_pAgF_cosSOM.Rda")

# Here are the match scores to the SOM map, for pAgF
load("/home/vanessa/Documents/Work/NEUROSYNTH/authorSynth/scoresNeuroSynth/allScoresPIAuthors3383.Rda")
rownames(somMatch$cos) = gsub("_pAgF_z_FDR_0.05_score.Rda","",rownames(somMatch$cos))

# PUBLICATIONS TABLES -------------------------------------------------------------------
# Here is the directory with meta information for each author publication
# These files are created with metaExtract.py - these will be rendered to d3 table
metadir = "/home/vanessa/Documents/Work/NEUROSYNTH/authorSynth/d3/publications"

# TOP MATCHES ---------------------------------------------------------------------------
# For each author, print table of author, uuid, score, and if is one of collaborators
# AUTHOR_NAME COLLAB_NAME AUTHOR_UUID COLLAB_UUID SCORE COAUTHOR

# Here we need to parse the cauth file to have a list of uuids for each PI that shows
# who they have actually worked with
labcollab = list()         # People who have collaborated, not a PI
picollab = list()    # People who have collaborated who are PI
allcollab = list()   # All of the above!

for (a in 1:length(authors$UUIDS)){
  cat(a,"of",length(authors$UUIDS),"\n")
  uuid = as.character(authors$UUIDS[a])
  name = as.character(authors$AUTHOR[a])
  metafile = paste(metadir,"/",uuid,"_pubs.txt",sep="")
  allpubs = read.csv(metafile,head=TRUE,sep="\t")   
  tmp = as.character(unique(allpubs$COAUTHORS))
  
  # First we need to find coauthors that are NOT PI
  coauth = c()
  for (t in tmp){
    tmp2 = gsub("^ ","",strsplit(t,",")[[1]])
    coauth = c(coauth,tmp2)
  }
  coauth = coauth[-which(coauth %in% name)]
  pis = as.character(authors$AUTHOR[which(as.character(authors$AUTHOR) %in% coauth)])
  
  if (length(pis)>0){
    # Here are lab mates
    lab = coauth[-which(coauth %in% pis)]
  } else {
    lab = coauth
  }
  
  # Save to objects
  labcollab[[uuid]] = paste(lab,collapse=",")          
  picollab[[uuid]] = paste(pis,collapse=",")
  allcollab[[uuid]] = gsub(" $","",paste(labcollab[[uuid]],picollab[[uuid]],collapse=","))
}

save(labcollab,picollab,allcollab,file="collaboratorLists3383.Rda")
  
# Now let's calculate scores, and save to file
for (a in 1:length(authors$UUIDS)){
  cat("Processing",a,"of",length(authors$UUIDS),"\n")
  uuid = as.character(authors$UUIDS[a])
  name = as.character(authors$AUTHOR[a])
  
  # Get scores from matrix
  sim.score = as.numeric(sort(dist.pagf[name,]))
  sim.name = names(sort(dist.pagf[name,]))

  # Which of these are actual collaborators?
  contenders = strsplit(picollab[[uuid]],",")[[1]]
  sim.binary = array(0,dim=length(sim.name))
  sim.binary[which(sim.name %in% contenders)] = 1
  
  # Calculate a score at each level - number of total overlap / spot in list
  sim.sumscore = array(0,dim=length(sim.name))
  if (length(contenders) > 0){
    for (s in 1:length(sim.sumscore)){
      sim.sumscore[s] = sum(sim.binary[1:s]) / length(contenders)     
    }
  }
  
  # Get the list of UIDS for everyone else
  idx = match(sim.name,as.character(authors$AUTHOR))
  sim.uuids = as.character(authors$UUIDS[idx])
        
  # Add a column with lab collaborators
  labbies = data.frame(LAB=labcollab[[uuid]],PI=picollab[[uuid]],ALL=allcollab[[uuid]])
  
  # Now parse together into one file 
  res = data.frame(AUTHOR=rep(name,length(sim.binary)),COLLABORATOR=sim.name,UUIDS=sim.uuids,MATCHSCORE=sim.score,ACTUAL_COLLABORATOR=sim.binary,RUNNING_SCORE=sim.sumscore)
  
  # Write table to file
  write.table(res,file=paste(matchoutdir,"/",uuid,"_match.tsv",sep=""),quote=FALSE,sep="\t",row.names=FALSE)
  
  # Write lab collaborators to file
  write.table(labbies,file=paste(laboutdir,"/",uuid,"_collabs.tsv",sep=""),quote=FALSE,sep="\t",row.names=FALSE)
}

# MATCH SCORE MATRIX ---------------------------------------------------------------------------
# For each author, print flat file of match scores to create d3!

# Here is the XY coordinates and terms for each node to make the D3 - length 506
load("som_pAgF_d3.Rda")

# Here is the som itself
load("/home/vanessa/Documents/Dropbox/Code/Python/authorSynth/app/som_pAgF.Rda")

# For each author, we need to output a file with
# AUTHOR  UUID  X Y TERM  SCORE COLOR
for (a in 2759:length(authors$UUIDS)){
  cat("Processing",a,"of",length(authors$UUIDS),"\n")
  uuid = as.character(authors$UUIDS[a])
  author = as.character(authors$AUTHOR[a])
  dat = somMatch$cos[uuid,]
  dat = (dat - min(dat)) / (max(dat)-min(dat))
  dat = c(0,as.numeric(dat),1)
  color = rbPal(10)[as.numeric(cut(dat,breaks = 10))]
  color = color[-c(1,508)]
  dat = dat[-c(1,508)]
  #png(file=paste("/home/vanessa/Documents/Work/NEUROSYNTH/authorSynth/imgNeuroSynth/",uuid,".png",sep=""),width=14,height=14,units="in",res=300)
  #plot(brainMap$som$grid$pts,main=paste("Summary of Neuroscience Work for Author",labels[a]),col=color,xlab="Meta Brain Map Nodes",ylab="Meta Brain Map Nodes",pch=15,cex=8)
  #text(brainMap$som$grid$pts,brainMap$labels,cex=.5)   
  #dev.off()
  
  # Now write scores and colors to file
  res = cbind(rep(uuid,length(color)),rep(author,length(color)),d3,color,dat,brainLattice$UIDS)
  colnames(res) = c("UUID","AUTHOR","X","Y","TERMS","COLOR","SCORE","UIDS")
  write.table(res,file=paste(latticeoutdir,"/",uuid,"_lattice.tsv",sep=""),quote=FALSE,row.names=FALSE,sep="\t")
}