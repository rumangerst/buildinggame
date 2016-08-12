#!/bin/env python

import math

name = input("Name: ")
description = input("Description: ")
typename = input("Typename: ")
category = input("Category: ")
erosion_type = input("Erosion type: ")

res_ = {}
res_per_progress = {}

while True:
    
    res = input("Resource: ")
    amount = input("Amount: ")
    
    if not res or not amount:
        break
    
    res_[res] = int(amount)
    
progress_duration = int(input("Build duration: "))

while 100 % progress_duration != 0:
    print("Invalid! 100 must be dividable by this number!")
    progress_duration = int(input("Build duration: "))

progress = 100 / progress_duration

for k in res_:
    
    res_per_progress[k] = str(int(math.ceil(float(res_[k]) / float(progress_duration))))
    print(k + " per progress: " + str(res_per_progress[k]))

f = open("template.json", "r")
w = open("definitions/building-" + category + "-" + typename + ".json", "w")

progress = str(progress)

for line in f:
    
    line = line.replace("%NAME", name).replace("%DESCR", description).replace("%TYPE", typename).replace("%CATEGORY", category).replace("%PROGRESS_AMOUNT", progress).replace("%RESOURCES_PER_PROGRESS", ", ".join( [ "\"" + k + "\" : " + res_per_progress[k]  for k in res_per_progress ] )).replace("%EROSION_T", erosion_type)
    w.write(line)

w.close()
f.close()
