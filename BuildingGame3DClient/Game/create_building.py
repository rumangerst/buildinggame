#!/bin/env python

name = input("Name: ")
typename = input("Typename: ")
category = input("Category: ")

res_per_progress = {}

while True:
    
    res = input("Resource: ")
    amount = input("Amount: ")
    
    if not res or not amount:
        break
    
    res_per_progress[res] = amount
    
progress = input("Progress per resource: ")

f = open("template.json", "r")
w = open("definitions/building-" + category + "-" + typename + ".json", "w")

for line in f:
    
    line = line.replace("%NAME", name).replace("%TYPE", typename).replace("%CATEGORY", category).replace("%PROGRESS_AMOUNT", progress).replace("%RESOURCES_PER_PROGRESS", ", ".join( [ "\"" + k + "\" : " + res_per_progress[k]  for k in res_per_progress ] ))
    w.write(line)

w.close()
f.close()
