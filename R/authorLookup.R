# This script will read in a list of authors downloaded
# from highlycited, and look up their full pubmed name 
# using the API

setwd("/home/vanessa/Documents/Dropbox/Code/Python/authorSynth/data")
authors = read.csv("highly_cited_subset_2014.csv",head=TRUE,sep=",",strip.white=TRUE)

# We will save Rda objects here with paper details that we might need
datadir = "/home/vanessa/Documents/Work/NEUROSYNTH/authorSynth"

# For each author, query pubmed for the full name
library(RISmed)

# AbstractText(query.ris)
# Author(query.ris)
# ArticleTitle(query.ris)
# Title(query.ris)
# PMID(query.ris)

fullname = c()

for (r in 1:nrow(authors)){
  name = paste(authors$First_Name.Middle_Name[r],authors$Family_Name[r])
  cat("Processing articles for author",name,"\n","...")
  query <- EUtilsSummary(paste(name,"[Author - Full] ",sep=""),,db="pubmed")
  query.ris <- EUtilsGet(query, type="efetch", db="pubmed")
  contenders = Author(query.ris)
  
  # Look through the papers, find the author name, and save initials
  names = c()
  for (c in 1:min(10,length(contenders))){
    tmp = contenders[[c]]
    idx = grep(as.character(authors$First_Name.Middle_Name[r]),tmp$ForeName)[1]
    if ((length(idx) > 0) && !is.na(idx)){
      if (tmp[idx,1] == as.character(authors$Family_Name[r])){
        names = c(names,paste(tmp[idx,1],tmp[idx,3]))
      }
    }
  }
  # We will use the name that appears most often
  winner = names(which(table(names) == max(table(names))))
  fullname = c(fullname,winner)
  
  # Save the query in case we want to come back
  save(query.ris,file=paste(datadir,"/",winner,".Rda",sep=""))
}

save(fullname,file= "authorNames.Rda")

# Read in file with authorNames
authors = read.csv("highly_cited_subset_2014.csv",head=TRUE,sep="\t",strip.white=TRUE)

# Create unique ids
uuids = c()
library("uuid")
for (r in 1:nrow(authors)){
  z = UUIDgenerate()
  uuids = c(uuids,z)
}
authors = cbind(authors,uuids)  
write.table(authors,file="highly_cited_2014_final.tab",sep="\t",row.names=FALSE,col.names=TRUE)