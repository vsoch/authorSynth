library('RColorBrewer')
setwd('/scratch/users/vsochat/DATA/BRAINMAP/nsynth525pFgA/scores')

# Here are matching scores of authorBrains to 506 SOM images
inputfiles = list.files("/scratch/users/vsochat/DATA/BRAINMAP/nsynth525pFgA/scores",pattern="_score.Rda")
load(inputfiles[1])

# Create a matrix for each distance metric
data.euc = array(dim=c(length(inputfiles),length(match$euc)))
rownames(data.euc) = gsub("_pFgA_z_FDR_0.05_score.Rda","",inputfiles)
colnames(data.euc) = names(match$euc)
data.cos = data.euc
data.so = data.euc
data.func = data.euc

# Fill in the data matrices
for (f in inputfiles){
  load(f)
  uuid = gsub("_pFgA_z_FDR_0.05_score.Rda","",f)
  data.euc[uuid,names(match$euc)] = match$euc
  data.cos[uuid,names(match$cos)] = match$cos
  data.so[uuid,names(match$so)] = match$so
  data.func[uuid,names(match$func)] = match$func
}

note = c("euc:Euclidean Distance,cos:cosine distance,so:shared voxels as % SOM map,func:shared voxels as % authorBrain map")
somMatch = list(euc=data.euc,cos=data.cos,so=data.so,authorMap=data.func,readme=note)
save(somMatch,file = 'allScores124.Rda')

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