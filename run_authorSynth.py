#!/usr/bin/python

# import authorSynth module
import authorSynth as AS

# Init Neurosynth database, either "525" or "3000" terms
db = AS.neurosynthInit("3000")
email = "vsochat@stanford.edu"
outdirectory = "/home/vanessa/Documents/Work/NEUROSYNTH/authorSynth/brainmaps"

# SINGLE AUTHOR EXAMPLE--------------------------------------------------

# Query pubmed for author of interest
# will return dictionary of DOIs and author order
author = "Calhoun VD"

# You will likely get a message that you need to download and save DTDs
# This returns a tuple, papers, with papers[0] == dois, papers[1] == pmid
papers = AS.getArticles(author,email)
metaAnalysis = AS.neurosynthMatch(db,papers,author,outdirectory)


# MULTIPLE AUTHOR EXAMPLE-----------------------------------------------

# Read in our list of authors
filey = open("data/highly_cited_2014_final.csv","r")
filey = filey.readlines()
header = filey.pop(0).strip("\n").split("\t")
pindex = header.index("Pubmed_Name")
uindex = header.index("uuids")

# We will keep lists of uuids and author names
uuids = []
authors = []
for f in filey:
  uuids.append(f.strip("\n").split("\t")[uindex])
  authors.append(f.strip("\n").split("\t")[pindex])

# Now run authorSynth for each author, save files with uuid as name
for i in range(5,len(authors)):
  print "Starting on " + str(i) + ": " + authors[i]
  papers = AS.getArticles(authors[i],email)
  ma = AS.neurosynthMatch(db,papers,author,outdirectory,uuids[i])

