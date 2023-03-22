import sys


pop=open(sys.argv[1],'r')
ref=sys.argv[2]
li = set()
for i in pop:
    li.add(i.strip())
li = list(li)
t = len(li)
for i in range(t-1):
    for j in range(i+1, t):
        print(li[i],"\t",li[j],"\t", ref)


