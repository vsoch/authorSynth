#!/usr/bin/python

# import authorSynth module
import authorSynth as AS

# Init Neurosynth database, either "525" or "3000" terms
db = AS.neurosynthInit("3000")

# Query pubmed for author of interest
# will return dictionary of DOIs and author order
author = "Calhoun VD"
email = "vsochat@stanford.edu"

# You will likely get a message that you need to download and save DTDs
papers = AS.getArticles(author,email)
outdirectory = "/home/vanessa/Desktop"
metaAnalysis = AS.neurosynthMatch(db,papers,author,outdirectory)
