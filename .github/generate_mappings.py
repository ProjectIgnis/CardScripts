#!/usr/bin/python
import sys
import os
import json

maps=[]

for elem in [sys.argv[n+1:n+3] for n in range(2, len(sys.argv), 3)]:
    try:
        oldname,oldextension=os.path.splitext(os.path.basename(elem[0]))
        newname,newextension=os.path.splitext(os.path.basename(elem[1]))
        if oldname != newname and oldextension == newextension == ".lua":
            maps.append((int(oldname[1:]),int(newname[1:])))
    except Exception:
        pass
if len(maps)==0:
    quit()
try:
    with open(sys.argv[1],'r') as json_file:
        data = json.load(json_file)
except Exception:
    data = json.loads('{"mappings" : []}')

for elem in maps:
    data["mappings"].append(elem)

with open(sys.argv[1], 'w') as outfile:
    json.dump(data, outfile)