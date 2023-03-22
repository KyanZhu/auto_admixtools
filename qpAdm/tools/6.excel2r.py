# coding:utf-8
# @Time : 2022/4/10 17:45
# @Author : cewinhot
# @Version: 0.1
# @File : excel2r
"""Usage:
python excel2r.py plot.txt
plot.txt为qpadm_result.xlsx结果的格式
"""

import sys


with open('r_input.txt', 'wt', encoding='utf-8') as f1:
    f1.write("target\ttail\tsource\tpercent\tstd\tsum_per\n")
    with open(sys.argv[1], 'rt', encoding='utf-8') as f:
        for line in f:
            li = line.split()
            length = len(li)
            if length == 6:
                f1.write(
                    "\t".join([li[0], 'P=' + li[4], li[1], li[2], li[3], '1'])+'\n')
            if length == 10:
                f1.write(
                    "\t".join([li[0], 'P=' + li[7], li[1], li[3], li[5], li[3]])+'\n')
                f1.write(
                    "\t".join([li[0], '', li[2], li[4], li[6], '1'])+'\n')
            if length == 14:
                f1.write(
                    "\t".join([li[0], 'P=' + li[10], li[1], li[4], li[7], li[6]])+'\n')
                f1.write(
                    "\t".join([li[0], '', li[2], li[5], li[8], str(float(li[5]) + float(li[6]))])+'\n')
                f1.write(
                    "\t".join([li[0], '', li[3], li[6], li[9], '1'])+'\n')
