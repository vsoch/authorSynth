# Here we will use KNN of match scores to return the top 10 closest (most similar) researchers
# We need to compare pAgF and pFgA maps before deciding on final ones to use

library(rjson)

# Read in match scores for each
load("/home/vanessa/Documents/Work/NEUROSYNTH/authorSynth/scoresNeuroSynth/allScoresPI17KAuthorspFgA.Rda")
pFgA = somMatch
load("/home/vanessa/Documents/Work/NEUROSYNTH/authorSynth/scoresNeuroSynth/allScoresPIAuthors3383.Rda")
pAgF = somMatch
rownames(pAgF$cos) = gsub("_pAgF_z_FDR_0.05_score.Rda","",rownames(pAgF$cos))

# Read in authors and coauthor files
setwd("/home/vanessa/Documents/Dropbox/Code/Python/authorSynth/data")
authors = read.csv("authors.txt",sep="\t",head=TRUE)
cauth = read.table("coauthnet.txt",sep="\t",head=FALSE,skip=1)
colnames(cauth) = c("UUID","PMID","NUMPAPERS")
authors = authors[-which(authors$UUIDS %in% out$UUID),]

# Prepare author labels
labels.pagf = as.character(authors$AUTHOR[match(rownames(pAgF$cos),auth$UUIDS)])
labels.pfga = as.character(authors$AUTHOR[match(rownames(pFgA$cos),auth$UUIDS)])
rownames(pFgA$cos) = labels.pfga
rownames(pAgF$cos) = labels.pagf

# Select author of interst, Ahmad Hariri
idx.pagf = 187
idx.pfga = 182

# Calculate euc distances (from cosine to SOM map), get 10 closest authors
dist.pagf = dist(pAgF$cos)
dist.pfga = dist(pFgA$cos)
dist.pfga = as.matrix(dist.pfga)
dist.pagf = as.matrix(dist.pagf)

# Get 10 closest authors for Ahmad
hist(sort(dist.pfga[idx.pfga,]))
hist(sort(dist.pagf[idx.pagf,]))

sort(dist.pfga[idx.pfga,])[1:10]
sort(dist.pagf[idx.pagf,])[1:10]

save(dist.pfga,file="edist_scores_pFgA_cosSOM.Rda")
save(dist.pagf,file="edist_scores_pAgF_cosSOM.Rda")

# PFGA:  
Hariri AR   Manuck SB Bullmore ET Arfanakis K      Hall J    Mowry BJ    Tolosa E Fletcher PC 
0.0000000   0.2345186   0.2563571   0.3238242   0.3241898   0.3253001   0.3358677   0.3383745 
Anderson AW   Bormans G 
0.3419282   0.3435117 

# PAGF: THIS IS DEFINITELY THE BETTER LIST
Hariri AR       Wolf OT      Aleman A      Wager TD     Hendler T    Miltner WH     Straube T 
0.0000000     0.6717728     0.6994389     0.7057453     0.7622759     0.7960195     0.8099508 
McDonald C Weinberger DR     Mattay VS 
0.9016525     0.9239695     0.9267434 