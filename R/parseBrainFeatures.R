library('RColorBrewer')
setwd('/scratch/users/vsochat/DATA/BRAINMAP/authorSynth/regionalFeaturespAgF')

# AUTHORS 17931 WORK ----------------------------------------------------------
# Here are regional vectors
inputfiles = list.files(pattern="_features.Rda")
load(inputfiles[1])

# Create a matrix for raw scores
raw = array(dim=c(length(inputfiles),length(regions)))
rownames(raw) = gsub("_features.Rda","",inputfiles)
colnames(raw) = names(regions)

# Fill in the data matrices
for (i in 1:length(inputfiles)){
  cat("Processing",i,"of",length(inputfiles),"\n")
  f = inputfiles[i]
  load(f)
  uuid = gsub("_features.Rda","",f)
  raw[uuid,names(regions)] = as.numeric(regions)
}

# Save to file
save(raw,file="../regionalFeaturespAgFRaw17931.Rda")

# Find columns that are entirely empty
idx = which(colSums(raw)==0)
filter = raw[,-idx]
save(filter,file="../regionalFeaturesFilterpAgF17931.Rda")

# Look at distributions of features then...
# Normalize?

lookup = read.csv("/home/vsochat/SCRIPT/python/authorSynth/data/authors.txt",sep="\t",head=TRUE)
save(lookup,file="../authorlookup19697.Rda")
idx = which(lookup$UUIDS %in% rownames(filter))
lookup = lookup[idx,]
save(lookup,file="../authorlookupFilter19697.Rda")

# Try a simple clustering first
disty = dist(raw)
hc = hclust(disty)
plot(hc,main="Clustering Neuroscience Authors Based on Regional Features")



# AUTHORS 124 WORK ----------------------------------------------------------
# Quickly try clustering - this may be the beset way to do it!
load("/scratch/users/vsochat/DATA/BRAINMAP/authorSynth/authorNameLookup.Rda")
lookup = as.data.frame(lookup)
idx = match(rownames(data.euc),lookup$uuids)
names = as.character(lookup$labels[idx])
rownames(data.euc) = names
rownames(data.cos) = names
rownames(data.so) = names
rownames(data.func) = names

# Save in case we want with author names for later
somAuthorMatch = list(euc=data.euc,cos=data.cos,so=data.so,authorMap=data.func,readme=note)
save(somAuthorMatch,file = 'allScoresAuthorNames124.Rda')

disty = dist(data.so)
hc = hclust(disty)
plot(hc,main="Clustering Neuroscience Authors Based on Overlap SOM/authors as % of SOM Maps")
