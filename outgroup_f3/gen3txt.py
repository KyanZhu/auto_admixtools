# coding:utf-8
# @Time : 2022/12/03 01:29
# @Author : zky
# @Version: 0.1
# @File : gen3txt.py


import sys


pop = ""
with open(sys.argv[1], 'rt', encoding='utf-8') as file:
    for line in file:
        if line[0] == "=":
            pop = line.strip().replace('=', '')
        else:
            print(line.strip(), 'black', pop, 'black', sep='\t')