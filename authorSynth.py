# authorSynth: This script produces a brain map that represents
# the brain spatial coverage published by a particular author.
# It includes functions to query pubmed for an author of interest,
# and then crosslist the doi's of those articles with NeuroSynth

# 1) query pubmed for an author of interest, and returns dois 
# and orders
# 2) cross list dois with those in the neuroSynth database
# 3) produce a brainmap for the list of PMIDs 

__author__ = "Vanessa Sochat"
__copyright__ = "Copyright 2014"
__credits__ = ["Vanessa Sochat"]
__license__ = "GPL"
__version__ = "1.0.1"
__maintainer__ = "Vanessa Sochat"
__email__ = "vsochat@stanford.edu"
__status__ = "Development"

import numpy as np
from neurosynth.base.dataset import Dataset
from neurosynth.base.dataset import FeatureTable
from neurosynth.base import imageutils
from neurosynth.analysis import meta
import nibabel as nb
from nibabel import nifti1
from Bio import Entrez
import re
import sys


# -- AUTHORSYNTH DATABASE FUNCTIONS --------------------------------------------------------------

def getAuthorDatabase():
    """Return all authors in authorSynth database"""
  filey = open("data/authors.txt","r")
  filey = filey.readlines()
  header = filey.pop(0).strip("\n").split("\t")
  pindex = header.index("AUTHOR")
  uindex = header.index("UUIDS")
  iindex = header.index("PMIDS")
  nindex = header.index("NUMPAPERS")
  piindex = header.index("PI")

  # We will keep lists of uuids and author names
  uuids = []
  authors = []
  ids = []
  numpapers = []
  pi = []
  for f in filey:
    uuids.append(f.strip("\n").split("\t")[uindex])
    authors.append(f.strip("\n").split("\t")[pindex])
    ids.append(f.strip("\n").split("\t")[iindex])
    numpapers.append(f.strip("\n").split("\t")[nindex])
    pi.append(f.strip("\n").split("\t")[piindex])

  authorSynth = dict()
  authorSynth["uuids"] = uuids
  authorSynth["authors"] = authors
  authorSynth["ids"] = ids
  authorSynth["numpapers"] = numpapers
  authorSynth["pi"] = pi
  return authorSynth

def getCoauthorDatabase():
    """Return all coauthors in authorSynth database"""
    print "Function not yet written!"

# -- NEUROSYNTH FUNCTIONS --------------------------------------------------------------

def neurosynthInit(dbsize):
    """Initialize Neurosynth Database, return database object"""
    print "Initializing Neurosynth database..."
    db = Dataset('data/' + str(dbsize) + 'terms/database.txt')
    db.add_features('data/' + str(dbsize) + 'terms/features.txt')

    #print "Loading standard space brain..."
    #img = nb.load("data/MNI152_T1_2mm_brain.nii.gz")
    #standard = img.get_data()
    return db

def neurosynthMatch(db,papers,author,outdir=None,outprefix=None):
    """Match neurosynth id with papers id"""

    # Get all IDs in neuroSynth
    neurosynth_ids = getIDs(db)
    
    # LIST OF IDS ---------------------------------------------------------
    # Input is DOI with list of papers
    if bool(re.search("[/]",papers[0])):
      # NeuroSynth is also DOI
      if bool(re.search("[/]",neurosynth_ids[0])):
        print "Search for " + str(len(papers)) + " ids in NeuroSynth database..."
        # Find intersection
        valid_ids = [x for x in papers if x in neurosynth_ids]
      # Neurosynth is PMID
      else:
        print "ERROR: Please provide doi to use the 525 database!"
        sys.exit()
    # Input is pmid with list of papers
    else:
      # NeuroSynth is also pmid
      if not bool(re.search("[/]",neurosynth_ids[0])):
        print "Search for " + str(len(papers)) + " ids in NeuroSynth database..."
        # Find intersection
        valid_ids = [x for x in papers if x in neurosynth_ids]
      # Neurosynth is doi
      else:
        print "ERROR: Please provide pmid to use the 3000 database!"
        sys.exit()

    if (len(valid_ids) > 0):
      # Do meta analysis
      ma = meta.MetaAnalysis(db,valid_ids)
      # 1) the z score map corresponding to the probability that a study in the database is tagged with a particular feature given that activation is present at a particular voxel, FDR corrected .05
      dataFDR = ma.images[ma.images.keys()[1]]
      # 2) the probability of feature given activation with uniform prior imposed
      dataPRIOR = ma.images[ma.images.keys()[6]]
      # 3) the probability of feature given activation
      data = ma.images[ma.images.keys()[7]]
      # 4) the probability of feature given activation, Z score
      dataZ = ma.images[ma.images.keys()[8]]
      # 5) z score map corresponding to the probability of activation given that a study is tagged with the feature (author)
      datapAgF = ma.images[ma.images.keys()[4]]
      # If user specifies an output directory
      if outdir:
        print "Saving results to output directory " + outdir + "..."
        if not outprefix:
          outprefix = author.replace(" ","")
        imageutils.save_img(datapAgF, '%s/%s_pAgF_z_FDR_0.05.nii.gz' % (outdir, outprefix), db.volume)
        imageutils.save_img(dataFDR, '%s/%s_pFgA_z_FDR_0.05.nii.gz' % (outdir, outprefix), db.volume)
        imageutils.save_img(dataPRIOR, '%s/%s_pFgA_given_pF=0.50.nii.gz' % (outdir, outprefix), db.volume)
        imageutils.save_img(data, '%s/%s_pFgA.nii.gz' % (outdir, outprefix), db.volume)
        imageutils.save_img(dataZ, '%s/%s_pFgA_z.nii.gz' % (outdir, outprefix), db.volume)
      return ma.images
    else:
      print "No overlapping studies found in database for author " + author + "."

def getFeatures(dataset):
    """Return features in neurosynth database"""
    return dataset.get_feature_names()

def getIDs(db):
    """Extract pubmed IDs or dois from Neurosynth Database"""
    # Get all IDs in neuroSynth
    neurosynth_ids = db.image_table.ids

    # Determine if we have dois or pmids
    if bool(re.search("[/]",neurosynth_ids[0])):
      print "Found dois in NeuroSynth database..."
      ids = neurosynth_ids
      # Find intersection
    else:
      print "Found pmids in NeuroSynth database..."
      ids = neurosynth_ids
    return ids

def getAuthor(db,id):
   """Extract author names for a given pmid or doi"""
   article = db.get_mappables(id)
   meta = article[0].__dict__
   tmp = meta['data']['authors']
   tmp = tmp.split(",")
   authors = [ x.strip("^ ") for x in tmp]
   return authors

def getAuthors(db):
   """Extract all author names in database"""
   articles = db.mappables
   uniqueAuthors = []
   for a in articles:
     meta = a.__dict__
     tmp = meta['data']['authors']
     tmp = tmp.split(",")
     authors = [ x.strip("^ ") for x in tmp]
     for a in authors:
       uniqueAuthors.append(a)
   uniqueAuthors = list(np.unique(uniqueAuthors))
   return uniqueAuthors

def getPaperMeta(db,pmid):
   """Extract activation points and all meta information for a particular pmid"""
   articles = db.mappables
   m = []
   for a in articles:
       tmp = a.__dict__
       if tmp['data']['id'] == str(pmid):
         journal = tmp['data']['journal']
         title = tmp['data']['title']
         year = tmp['data']['year']
         doi = tmp['data']['doi']
         auth = tmp['data']['authors']
         peaks = tmp['data']['peaks']
         pmid = tmp['data']['id']
         tmp = (journal,title,year,doi,pmid,auth,peaks)
         m.append(tmp)
   return m

# -- PUBMED FUNCTIONS --------------------------------------------------------------
# These functions will find papers of interest to crosslist with Neurosynth

def getArticles(author,email):
    """Return dictionaries of dois, pmids, each with order based on author name (Last FM)"""

    print "Getting pubmed articles for author " + author
    
    Entrez.email = email
    handle = Entrez.esearch(db='pubmed',term=author,retmax=5000)
    record = Entrez.read(handle)

    # If there are papers
    if "IdList" in record:
      if record["Count"] != "0":
        # Fetch the papers
        ids = record['IdList']
        handle = Entrez.efetch(db='pubmed', id=ids,retmode='xml',retmax=5000)
        records = Entrez.read(handle)
        # We need to save dois for database with 525, pmid for newer
        dois = dict(); pmid = dict()
        for record in records:
          authors = record["MedlineCitation"]["Article"]["AuthorList"]
          order = 1
          for p in authors:
            # If it's a collective, won't have a last name
            if "LastName" in p and "Initials" in p:
              person = p["LastName"] + " " + p["Initials"]
              if person == author:

                # Save the pmid of the paper and author order
                # it's possible to get a different number of pmids than dois
                if order == len(authors):
                  pmid[int(record["MedlineCitation"]["PMID"])] = order
                else:
                  pmid[int(record["MedlineCitation"]["PMID"])] = "PI"

                # We have to dig for the doi
                for r in record["PubmedData"]["ArticleIdList"]:
                  # Here is the doi
                  if bool(re.search("[/]",str(r))):
                    # If they are last, they are PI
                    if order == len(authors):
                      dois[str(r)] = "PI"
                    else:
                      pmid[int(record["MedlineCitation"]["PMID"])] = order
                      dois[str(r)] = order

            order = order + 1

      # If there are no papers
      else:
        print "No papers found for author " + author + "!"

    # Return dois, pmids, each with author order
    print "Found " + str(len(pmid)) + " pmids for author " + author + " (for NeuroSynth 3000 database)."
    print "Found " + str(len(dois)) + " dois for author " + author + " (for NeuroSynth 525 database)."
    return (dois, pmid)

if __name__ == "__main__":
  print "Please import as a module"
