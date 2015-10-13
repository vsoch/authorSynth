# authorSynth
[![DOI](https://zenodo.org/badge/doi/10.5281/zenodo.32058.svg)](http://dx.doi.org/10.5281/zenodo.32058)
[publication](http://journal.frontiersin.org/article/10.3389/fninf.2015.00006/abstract)

AuthorSynth is a tool to query neuroSynth to associate authors with brain maps.  Functions to query pubmed are included, but not used in the original implementation.

The first workflow (the python scripts in the top directory) works with the NeuroSynth database to create the maps, and the second workflow (the R scripts) use NeuroSynth to define a subset of functional behaviorally-relevant brain images, reduce these images to a 2D space, calculate match scores of the author brain maps to these images, and then display. All scripts for production of data for use in the [authorSynth web interface](https://github.com/vsoch/authorSynth-www) are included.

## Creation of Author Brain Maps

### authorExtract.py
This script will extract Authors from the NeuroSynth database, including Name, a unique ID, PI status, pmids, and number of publications, to create the data/authors.txt file.

### authorSynth.py
This is the main module to import into a script that includes the following functions:
- neurosynthInit(dbsize): Takes "dbsize" (3000 or 525)
- getFeatures(db): returns features (behavioral terms)
- getArticles(author,email): returns dictionaries of dois nd pmids for author query ("Last FM")
- neurosynthMatch(db,papers,author,outdir,outprefix): matches papers to neurosynth and makes brain map
- getAuthor(db,pmid): returns list of authors for a single pmid or doi
- getAuthors(db): returns all authors in the NeuroSynth database
- getIDs(db): returns all pmid or doi from the NeuroSynth database

### authorSynth_local.py
Includes examples for running authorSynth locally for one or more authors to create the brain maps

### run_authorSynthc_cluster.py
Includes examples for running authorSynth in a cluster environment using the authors in the authors.txt file.  It works by submitting multiple jobs of:

### authorSynth_cluster.py
Takes command line arguments uuid, author, email, outdirectory, and paper ids to batch process creation of author brain maps.  

Usage : authorSynth_cluster.py uuid "author" email outdirectory id1,id2,id3


## Creation of 2D Space to Visualize Author Brain Maps

This second workflow moves the author brain maps through the particular analysis done to produce the visualizations in the current AuthorSynth web portal.  You should only need the first workflow to produce author brain maps, and this second work flow is to reproduce the work in the authorSynth paper.

To understand the author brain maps on the level of behavior, we first use NeuroSynth to conduct meta analysis of functional studies, creating maps of 525 behaviorally relevant terms (eg, "anxiety") to describe what the neuroscience literature has to say about each terms in a brain image (FDR corrected .05, voxel values are Z scores of the probability of the term given activation).  The workflow is as follows:

1. Create pFgA maps from NeuroSynth database (these are in MNI 152 standard space) - these are not the author brain maps, but a set of behavioral maps you are interested in.  It doesn't have to be NeuroSynth necessarily.
2. Resample these images into 8mm to reduce the dimensionality
3. Read these images into a matrix to make an SOM with:

### R/makeTermSOM.R
Will read in NeuroSynth 8mm resampled images, create an SOM, save node coordinates and labels, use transformation matrix to sample back to 2mm images, and write SOM 2mm images to file.

4. We then calculate match scores for our author brain maps to the SOM, and parse into matrices with:

### R/matchToSOM.R
calculates match scores of each authorBrain map to these SOM 2mm images

### R/run_matchToSOM.R
submits multiple of the above, intended to be run on the Sherlock Cluster at Stanford.  Each run produces an output .Rda file with a vector of match scores of the authorMap to each of the SOM images, and this is done for several metrics, including:
- Euclidean Distance (euc)
- Cosine Distance (cos)
- Overlap of Author Map and SOM Map as a % of Author Map (func)
- Overlap of Author Map and SOM Map as a % of SOM Map (so)

### R/parseMatchScores.R
reads in individual output files produced by matchToSOM, and compiles different match scores into group matrices.

### R/plotSOM.R
Maps scores onto the SOM to make static images

### R/exportD3.R
Calculates author similarity based on being co-authors on same publication, output is json file to drive d3 network visualization.

### R/make_d3_groups.R
Produces groups (colorings) of network based on different levels of clustering for exportD3.

### R/makeAuthorJson.R
Produces a single author json for the d3 visualization single author page

### R/authorWebPage.R
Produces data for the d3 lattice and author similarity comparison page.
