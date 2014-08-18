# authorSynth
authorSynth is a tool to query neuroSynth and pubmed to associate authors with brain maps (in dev)

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
Includes examples for running authorSynth locally for one or more authors

### run_authorSynthc_cluster.py
Includes examples for running authorSynth in a cluster environment by submitting multiple jobs of

### authorSynth_cluster.py
Takes command line arguments uuid, author, email, and outdirectory.

Usage : authorSynth_cluster.py uuid "author" email outdirectory
