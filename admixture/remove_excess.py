# coding:utf-8
# @Time : 2022/9/28 16:30
# @Version: 1
# @File : remove_excess.py
# @Author : zky


pop_li = []
counts_li = []
ind_file = "tmp.ind"
with open("remove.counts", "r") as file:
	for line in file:
		a, b = line.split()
		pop_li.append(a)
		counts_li.append(int(b))

with open(ind_file, "r") as file:
	for line in file:
		a, b, c = line.split()
		if c in pop_li and counts_li[pop_li.index(c)] != 0:
			print(a, b, c + "_ignore")
			counts_li[pop_li.index(c)] -= 1
		else:
			print(line, end="")
	

