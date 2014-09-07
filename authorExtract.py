#/usr/bin/python

# This script will use authorSynth to extract author meta information, including:
# AuthorName	UUID	pmid	FirstAuthor	NumberPapers

# import authorSynth module
import authorSynth as AS
import os
import uuid

# Output file
outfile = "/home/vanessa/Desktop/authors.txt"

# Init Neurosynth database, either "525" or "3000" terms
db = AS.neurosynthInit("3000")

# Get all pmids in database
ids = AS.getIDs(db)
ids = ids["pmid"]

# Get unique authors
authors = AS.getAuthors(db)

# For each unique author, create uuid
uuids = [ uuid.uuid3(uuid.NAMESPACE_DNS, x) for x in authors ]

# Now go through each pmid, add to dictionary of authors
pmids = dict()  # pmid["authorName"] = ["pmid1","pmid2","pmid3"]
pi = dict()  # 0 if first author, 1 otherwise
for x in authors:
  pi[x] = 0

for i in ids:
  tmp = AS.getAuthor(db,i)
  # Save last author
  pi[tmp[-1]] = 1
  for t in tmp:
    # If we already have the author in the dictionary
    if t in pmids:
      holder = pmids[t]
      # If we just have one
      if isinstance(holder, basestring):
        holder = [holder,i]
      else:
        holder.append(i)
      pmids[t] = holder
    # If we don't'
    else:
      pmids[t] = i

# Here is the output file
filey = open(outfile,'w')
filey.writelines("AUTHOR\tUUIDS\tPMIDS\tPI\tNUMPAPERS\n")
# Now for each author, print to file
for a in range(0,len(authors)):
  aa = authors[a]
  if isinstance(pmids[aa], basestring):
    p = pmids[aa]
    numpapers = "1"
  else:
    p = ",".join(pmids[aa])
    numpapers = str(len(pmids[aa]))
  line = aa + "\t" + str(uuids[a]) + "\t" + str(p) + "\t" + str(pi[aa]) + "\t" + str(numpapers) + "\n"
  filey.writelines(line)
