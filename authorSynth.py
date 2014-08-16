# authorSynth: This script produces a brain map that represents
# the brain spatial coverage published by a particular author.
# It includes functions to query pubmed for an author of interest,
# and then crosslist the doi's of those articles with NeuroSynth

# 1) query pubmed for an author of interest, and returns dois 
# and orders
# 2) cross list dois with those in the neuroSynth database
# 3) produce a brainmap for the list of PMIDs 

__author__ = "Vanessa Sochat, Peter Lee"
__copyright__ = "Copyright 2014"
__credits__ = ["Vanessa Sochat", "Peter Lee"]
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

# -- NEUROSYNTH FUNCTIONS --------------------------------------------------------------

def neurosynthInit(dbsize):
    """Initialize Neurosynth Database, return database object"""
    print "Initializing Neurosynth database..."
    dataset = Dataset('data/' + str(dbsize) + 'terms/database.txt')
    dataset.add_features('data/' + str(dbsize) + 'terms/features.txt')    

    #print "Loading standard space brain..."
    #img = nb.load("data/MNI152_T1_2mm_brain.nii.gz")
    #standard = img.get_data()
    return dataset

def neurosynthMatch(db,papers,author,outdir=None):
    """Match neurosynth doi with papers doi"""
    dois = papers.keys()
    # Get all IDs in neuroSynth
    neurosynth_ids = db.image_table.ids
    print "Search for " + str(len(papers)) + " ids in NeuroSynth database..."
    # Find intersection
    valid_ids = list(set(dois) - set(neurosynth_ids))
    print "Found " + str(len(valid_ids)) + "."
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
      # If user specifies an output directory
      if outdir:
        print "Saving results to output directory " + outdir + "..."
        outprefix = author.replace(" ","")
        imageutils.save_img(dataFDR, '%s/%s_pFgA_z_FDR_0.05.nii.gz' % (outdir, outprefix), db.volume)
        imageutils.save_img(dataPRIOR, '%s/%s_pFgA_given_pF=0.50.nii.gz' % (outdir, outprefix), db.volume)
        imageutils.save_img(data, '%s/%s_pFgA.nii.gz' % (outdir, outprefix), db.volume)
        imageutils.save_img(dataZ, '%s/%s_pFgA_z.nii.gz' % (outdir, outprefix), db.volume)
      return ma.images
    
def getFeatures(dataset):
    """Return features in neurosynth database"""
    return dataset.get_feature_names()

# -- PUBMED FUNCTIONS --------------------------------------------------------------
# These functions will find papers of interest to crosslist with Neurosynth

def getArticles(author,email):
    """Return dictinary of dois and order based on author name (Last FM)"""

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
        papers = dict()
        for record in records:
          authors = record["MedlineCitation"]["Article"]["AuthorList"]
          order = 1
          for p in authors:
            # If it's a collective, won't have a last name
            if "LastName" in p and "Initials" in p:
              person = p["LastName"] + " " + p["Initials"]
              if person == author:
                # Only really old papers won't have a doi
                for r in record["PubmedData"]["ArticleIdList"]:
                  if bool(re.search("[/]",str(r))):
                    # If they are last, they are PI
                    if order == len(authors):
                      papers[str(r)] = "PI"
                    else:
                      papers[str(r)] = order
            order = order + 1

      # If there are no papers
      else:
        print "No papers found for author " + author + "!"
        
    # Return dictionary of dois and author order
    print "Found " + str(len(papers)) + " papers for author " + author + "."
    return papers

if __name__ == "__main__":
  print "Please import as a module"
