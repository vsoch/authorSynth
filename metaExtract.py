#/usr/bin/python

# This script will use authorSynth to extract PI meta information, including
# AuthorName	UUID	pmid	Journal	Title	x	y	z

# import authorSynth module
import authorSynth as AS
import os
import uuid

# Here is the output folder for the data files
outfolder = "/home/vanessa/Documents/Work/NEUROSYNTH/authorSynth/d3/publications"

# Init Neurosynth database, either "525" or "3000" terms
db = AS.neurosynthInit("3000")

# Read in author data file
authors = AS.getAuthorDatabase()

# For each author, we will keep a dictionary of meta
#TODO This is slow
meta = dict()
for a in range(0,len(authors["uuids"])):
  if authors["pi"][a] == "1":
    print "Adding author " + authors["authors"][a]
    pmids = authors["ids"][a].split(",")
    singleAuthor = []
    if len(pmids) > 1:
      for p in pmids:
        singleAuthor.append(AS.getPaperMeta(db,p))
    else:
        singleAuthor.append(AS.getPaperMeta(db,pmids[0]))
    meta[authors["uuids"][a]] = singleAuthor

# For each author, print to file
for a, dat in meta.iteritems():
  outfile = outfolder + "/" + a + "_pubs.txt"
  if len(dat[0]) > 0:
    filey = open(outfile,"w")
    filey.writelines("AUTHOR\tCOAUTHORS\tPMID\tTITLE\tJOURNAL\tYEAR\tDOI\tX\tY\tZ\n")
    for dd in range(0,len(dat)):
      # (journal,title,year,doi,pmid,auth,peaks)
      d = dat[dd]
      peaks = d[0][6]
      for p in range(0,len(peaks)):
        x = peaks[p][0]; y = peaks[p][1]; z=peaks[p][2]
        filey.writelines(a + "\t" + d[0][5] + "\t" + d[0][4] + "\t" + d[0][1] + "\t" + d[0][0] + "\t" + d[0][2] + "\t" + d[0][3] + "\t" + d[0][4] + "\t" + x + "\t" + y + "\t" + z + "\n")
    filey.close()
  else:
    print "Skipping " + a
