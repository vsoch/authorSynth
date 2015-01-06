#!/usr/bin/python

# This script will use authorExtract to 
# return a file with "coauthor relationships" in the form of:
# uuid1 uuid2 pmids raw_num_papers
# uuid combinations with no shared papers will be ignored

keyfile = open('data\\authors.txt')
keyfile = keyfile.readlines()

header = keyfile.pop(0).strip("\n").split("\t")
pindex = header.index("PMIDS")
uindex = header.index("UUIDS")

copmid = dict()

ids = []
pids = []
for entries in keyfile:
 ids.append(entries.strip("\n").split("\t")[uindex])
 pids.append(entries.strip("\n").split("\t")[pindex])
 
for foo in range(len(pids)):
 pids[foo] = pids[foo].split(",")

for foo in range(len(pids)-1):
 for fee in range(foo+1,len(pids)):
  copmide = list(set(pids[foo]) & set(pids[fee]))
  if copmide:
   copmid[",".join((ids[foo],ids[fee]))] = copmide
   
copmid = copmid.items()
outfile = open('data\\coauthnet.txt','w')
outfile.writelines("UUID\tPMIDS\tNUMPAPERS\n")

for foo in range(len(copmid)):
 uuid = copmid[foo][0]
 pmid = copmid[foo][1]
 numpap = len(pmid)
 pmid = ",".join(pmid)
 line = uuid + "\t" + pmid + "\t" + str(numpap) + "\n"
 outfile.writelines(line)
