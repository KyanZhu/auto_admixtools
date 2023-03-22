import sys


# coding:utf-8
# @Time : 2022/1/15 17:22
# @Author : cewinhot 
# @Version：v1
# @File : gen_scripts.py


pop=open(sys.argv[1],'r')
li = []
for i in pop:
    li.append(i.strip())
t = len(li)
for i in range(t-1):
    for j in range(i+1, t):
        print("cd result ; if [ ! -f {0}-{1}.result ];then echo -e \"{0}\\n{1}\" > {0}-{1}.left ; cat parqpWave.template | sed 's/replaceleft/{0}-{1}.left/g' > {0}-{1}.par ; qpWave -p {0}-{1}.par > {0}-{1}.result ; fi ".format(li[i],li[j]))
