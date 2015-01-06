#!/usr/bin/python

# import authorSynth module
import authorSynth as AS

# Init Neurosynth database, either "525" or "3000" terms
db = AS.neurosynthInit("3000")
email = "myname@email.com"
outdirectory = "/home/vanessa/Documents/Work/NEUROSYNTH/authorSynth/brainmaps"


# SINGLE AUTHOR EXAMPLE--------------------------------------------------

# Query pubmed for author of interest
# will return dictionary of DOIs and author order
# Note: this author ID is present in the NeuroSynth (and thus AuthorSynth) database
author = "Calhoun VD"

# You will likely get a message that you need to download and save DTDs
# This returns a tuple, papers, with papers[0] == dois, papers[1] == pmid
papers = AS.getArticles(author,email)
metaAnalysis = AS.neurosynthMatch(db,papers,author,outdirectory)


# MULTIPLE AUTHOR EXAMPLE-----------------------------------------------

# Get list of authors
authors = AS.getAuthorDatabase()

# We will keep lists of uuids and author names
uuids = authors["uuids"]
ids = authors["ids"]
numpapers = authors["numpapers"]
authors = authors["authors"]

# Now run authorSynth for each author, save files with uuid as name
for i in range(5,len(authors)):
  print "Starting on " + str(i) + ": " + authors[i]
  papers = AS.getArticles(authors[i],email)
  ma = AS.neurosynthMatch(db,papers,author,outdirectory,uuids[i])
