# This script will read an authorSynth network object, and export 
# the data in the "long" format required by d3.

setwd("/home/vanessa/Documents/Dropbox/Code/Python/authorSynth/data")
outdir = "/home/vanessa/Documents/Work/NEUROSYNTH/authorSynth/d3"
groupdir = "/home/vanessa/Documents/Work/NEUROSYNTH/authorSynth/groups"

# Here are the different files for defining colors
groups =  list.files(groupdir,pattern="*.Rda",full.names=TRUE)
g = load(groups[1])

# WORK WITH AUTHORS.TXT --------------------------------------
authors = read.csv("authors.txt",sep="\t",head=TRUE)

# WORK WITH CAUTHORS.TXT --------------------------------------
cauth = read.table("coauthnet.txt",sep="\t",head=FALSE,skip=1) 
# Header is incorrect and extra space we need to fix
cauth = cauth[,-3]
colnames(cauth) = c("UUID","PMID","NUMPAPERS")

# We don't have maps for these
nix = c("1e97fd6a-3306-34b4-9e01-b1f202c38a86","728a261e-0bb5-3cbe-a695-377d080c6991") 
authors = authors[-which(authors$UUIDS %in% nix),]

# Filter down to those we have som match scores for
authors = authors[which(authors$UUIDS %in% out$UUID),]

# We will output d3 for the network
library(rjson)

# We will produce a json for each grouping, a level to cut on the tree
for (g in groups){
  # We will keep track of node id, names, unique IDs, and number of papers
  # Here we only want to create nodes for PIs
  name = c()
  author = c()
  id = c()
  publications = c()
  for (i in 1:nrow(authors)){
    if (as.numeric(authors$PI[i]) == 1) {
      # Only include PIs with at least 2 papers
      if (authors$NUMPAPERS[i] >= 2){
          name = c(name,as.character(authors$AUTHOR[i]))
          author = c(author,as.character(authors$AUTHOR[i]))
          id = c(id,as.character(authors$UUIDS[i]))
          publications = c(publications,authors$NUMPAPERS[i])
        }
    }
  }

  # Now define colors based on groups
  load(g)
  out$UUID = as.character(out$UUID)
  out = out[which(out$UUID %in% id),]
  idx = match(id,as.character(out$UUID))
  agroups = as.numeric(out$GROUP[idx])
  uniqueValues = sort(unique(agroups))
  colors = rainbow(length(uniqueValues))
  names(colors) = uniqueValues
  colors = colors[as.character(agroups)]  
  json = data.frame(name=name,author=author,id=id,publications=publications,colors=colors)
  
 # Here we need to identify the author unique IDs that share a link
  # For this we parse the cauth variable
  from = c()
  to = c()
  weight = c()
  for (i in 1:nrow(cauth)){
    cat("Processing",i,"of",nrow(cauth),"\n")
    link = strsplit(as.character(cauth$UUID[i]),",")[[1]]
    # ONLY add if both are PI, with greater than = 2 papers together
    if ((link[1] %in% id) && (link[2] %in% id)){
      if (cauth$NUMPAPERS[i] >= 2){
        from = c(from,link[1])
        to = c(to,link[2])
        weight = c(weight,cauth$NUMPAPERS[i]) 
      }
    }
  }
  links = data.frame(source=from,target=to,weight=weight)
  
  # Now let's write the file
  grouping = gsub("/home/vanessa/Documents/Work/NEUROSYNTH/authorSynth/groups/groups_","",gsub(".Rda","",g))
  grouping = gsub("[.]","_",grouping)
  sink(paste("/var/www/authorSynth/data/json/PInetwork_3258",grouping,".json",sep=""))
  cat('{\n"nodes": [')
  
  # Here are the nodes
  for (i in 1:nrow(json)-1){
    cat('\n{\n"name": "',as.character(json$name[i]),'",\n"artist": "',as.character(json$author[i]),'",\n"id": "',as.character(json$id[i]),'",\n"color": "',as.character(json$colors[i]),'",\n"playcount": "',json$publications[i],'"\n},',sep="")
  }
  for (i in nrow(json)){
    cat('\n{\n"name": "',as.character(json$name[i]),'",\n"artist": "',as.character(json$author[i]),'",\n"id": "',as.character(json$id[i]),'",\n"color": "',as.character(json$colors[i]),'",\n"playcount": "',json$publications[i],'"\n}',sep="")
  }
    
  # Close nodes
  cat('],\n"links": [')
  for (i in 1:nrow(links)-1){
    cat('\n{\n"source": "',as.character(links$source[i]),'",\n"target": "',as.character(links$target[i]),'",\n"weight": "',as.character(links$weight[i]),'"\n},',sep="")
  }
  for (i in nrow(links)){
    cat('\n{\n"source": "',as.character(links$source[i]),'",\n"target": "',as.character(links$target[i]),'",\n"weight": "',as.character(links$weight[i]),'"\n}',sep="")
  }
  # Close links
  cat('\n]\n}')
  sink()
}