# authorSynth
authorSynth is a tool to query neuroSynth and pubmed to associate authors with brain maps (in dev)
The first workflow works with Pubmed and the NeuroSynth database to create the maps, and the second workflow uses NeuroSynth to define a subset of functional behaviorally-relevant brain images, reduce these images to a 2D space, calculate match scores of the author brain maps to these images, and then display.  We are currently working on the network, and a demo of the mapping of authors to functional maps is available in the R Markdown file in the "app" folder.

## Creation of Author Brain Maps

### pmidExtract.py
Given a database size, this script will return all PMIDs from the neurosynth database of that size.

### authorExtract.py
Given a list of PMIDs and a user email address, this script will query Entrez Pubmed and return an array of unique authors along with their frequency of PMID mentions

### authorSynth.py
This is the main module to import into a script that includes the following functions:
- neurosynthInit(dbsize): Takes "dbsize" (3000 or 525)
- getFeatures(db): returns features (behavioral terms)
- getArticles(author,email): returns dictionaries of dois nd pmids for author query ("Last FM")
- neurosynthMatch(db,papers,author,outdir,outprefix): matches papers to neurosynth and makes brain map

### run_authorSynth_local.py
Includes examples for running authorSynth locally for one or more authors to create the brain maps

### run_authorSynthc_cluster.py
Includes examples for running authorSynth in a cluster environment by submitting multiple jobs of:

### authorSynth_cluster.py
Takes command line arguments uuid, author, email, and outdirectory to batch process creation of author brain maps.

Usage : authorSynth_cluster.py uuid "author" email outdirectory


## Analysis of Author Brain Maps

### clusterBrainMaps.R
Loads the matrix of author brain maps and performs different kinds of clustering to explore the result.  The first method (clustering of all voxels) is too detailed a resolution to capture authors with similar maps (see script for details), however clustering by either the match scores of author maps to SOM best matching units, OR by regional brain features (created with script makeBrainFeatures.R) results in a nice clustering.

### makeBrainFeatures.R
Create regional atlas features based on a set of white and gray matter brain atlas, and subcortical structure atlases.  The workflow is to 1) create feature matrix, 2) count number of voxels in author maps for each feature, and then we can cluster.


## Creation of 2D Space to Visualize Author Brain Maps

To understand the author brain maps on the level of behavior, we first use NeuroSynth to conduct meta analysis of functional studies, creating maps of 525 behaviorally relevant terms (eg, "anxiety") to describe what the neuroscience literature has to say about each terms in a brain image (FDR corrected .05, voxel values are Z scores of the probability of the term given activation).  The script to create the brain maps themselves is currently not included.  The workflow is as follows:

1. Create pFgA maps from NeuroSynth database (these are in MNI 152 standard space)
2. Use Matlab to resample these images into 8mm to reduce the dimensionality (script resize_img)
3. Read these images into a matrix with:

### makeTermSOM.R
Will read in NeuroSynth 8mm resampled images, create an SOM, save node coordinates and labels, use transformation matrix to sample back to 2mm images, and write SOM 2mm images to file.

4. We then calculate match scores and parse into matrices with:

### matchToSOM.R
calculates match scores of each authorBrain map to these SOM 2mm images

### run_matchToSOM.R
submits multiple of the above, intended to be run on the Sherlock Cluster at Stanford.  Each run produces an output .Rda file with a vector of match scores of the authorMap to each of the SOM images, and this is done for several metrics, including:
- Euclidean Distance (euc)
- Cosine Distance (cos)
- Overlap of Author Map and SOM Map as a % of Author Map (func)
- Overlap of Author Map and SOM Map as a % of SOM Map (so)

### parseMatchScores.R
reads in individual output files produced by matchToSOM, and compiles different match scores into group matrices.

### plotSOM.R
Maps scores onto the SOM (finally)

*Coming soon* We want to create a network in d3 that shows the relationship between authors (the clustering), and clicking on an author will show the SOM plot to describe the work.

