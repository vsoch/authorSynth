# pmidExtract: This script extracts all unique pmids currently available from
# neurosynth database.

# import authorSynth module
import authorSynth as AS

def idExtract(dbsize):

	db = AS.neurosynthInit(dbsize)
	neurosynth_ids = db.image_table.ids
	ns_ids_set = set(neurosynth_ids)

	if bool(re.search("[/]",neurosynth_ids[0])):
	  print "Processing conversion of dois to pmid"
	  # Some code to convert dois to pmid using http://www.pubmedcentral.nih.gov/utils/idconv/v1.0/?ids=10.1093/nar/gks1195
	else:
	  print "Extracted pmids"
	  
	return ns_ids_set