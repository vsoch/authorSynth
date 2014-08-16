#!/usr/bin/python

# import authorSynth module
import authorSynth as AS

# Init Neurosynth database, either "525" or "3000" terms
db = AS.neurosynthInit("525")

# Query pubmed for author of interest
# will return dictionary of PMIDs and author order
author = "Hariri AR"
email = "vsochat@stanford.edu"
papers = AS.getArticles(author,email)

# NOT YET WRITTEN
someresult = AS.neurosynthMatch(papers)
# output a result? input arg to specify output?
