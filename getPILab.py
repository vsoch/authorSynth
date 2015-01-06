#!/usr/bin/python

# This script will take in authors and coauthors to return PI lab groups in the form of:
# PIUUID UUIDS PAPERNUMS in order of descending paper numbers
# NOTE: Because last author/paper associations have not been kept,
# it is not possible to distinguish which author was in which labs
# when two authors defined as last author at some point, co-published
# This script was developed by not used in the original authorSynth application

keyfile = open('data\\authors.txt')
keyfile = keyfile.readlines()

header = keyfile.pop(0).strip("\n").split("\t")
pibool = header.index("PI")
uindex = header.index("UUIDS")

coauthfile = open('data\\coauthnet.txt')
coauthfile = coauthfile.readlines()

header = coauthfile.pop(0).strip("\n").split("\t")
couindex = header.index("UUID")
numcopap = header.index("NUMPAPERS")

ids = []
pids = []
for entries in keyfile:
 ids.append(entries.strip("\n").split("\t")[uindex])
 pids.append(entries.strip("\n").split("\t")[pibool])

piuuids = []
for foo in range(len(ids)):
 if int(pids[foo]):
  piuuids.append(ids[foo])

couuids = []
numcopapers = []
for entries in coauthfile:
 couuids.append(entries.strip("\n").split("\t")[couindex])
 numcopapers.append(entries.strip("\n").split("\t")[numcopap])

labmembers = dict()
#membernum = dict()

for pis in piuuids:
 labmembers[pis]= []
# membernum[pis] = []

for pis in piuuids:
 for indy, coauths in enumerate(couuids):
  if pis in coauths.split(","):
   labpos = int(not(coauths.split(',').index(pis)))
   labmembers[pis].append((coauths.split(',')[labpos],(numcopapers[indy])))
#   membernum[pis].append(numcopapers[indy])

for pis in piuuids:
 labmembers[pis] = sorted(labmembers[pis], key=lambda t:int(t[1]), reverse=1)

labmembers = labmembers.items()
outfile = open('data\\pilabmembers.txt','w')
outfile.writelines("PIUUID\tUUIDS\tNUMPAPERS\n")

for foo in range(len(labmembers)):
 uuid = labmembers[foo][0]
 labmem = labmembers[foo][1]
 if labmem:
  labnames,labpapers = zip(*labmem)
  labnames = ",".join(labnames)
  labpapers = ",".join(labpapers)
  line = uuid + "\t" + labnames + "\t" + labpapers + "\n"
  outfile.writelines(line)
