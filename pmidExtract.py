# pmidExtract: This script extracts all unique pmids currently available from
# neurosynth database.

# import authorSynth module
import authorSynth as AS

db = AS.neurosynthInit("525")

neurosynth_ids = db.image_table.ids

if bool(re.search("[/]",neurosynth_ids[0])):
  print "Search for " + str(len(dois)) + " ids in NeuroSynth database..."
  # Find intersection
  valid_ids = [x for x in dois if x in neurosynth_ids]
else:
  print "Search for " + str(len(pmid)) + " ids in NeuroSynth database..."
  valid_ids = [str(x) for x in pmid if str(x) in neurosynth_ids]
print "Found " + str(len(valid_ids)) + "."

