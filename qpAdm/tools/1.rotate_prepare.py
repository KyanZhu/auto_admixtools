# coding:utf-8
# @Time : 2021/9/24 11:03
# @Author : cewinhot
# @Version：V 0.1
# @File : 1.qpadm_prepare.py
import os


par_template = '''\
genotypename: ../../extract.geno
snpname: ../../extract.snp
indivname: ../../extract.ind
popleft: {}.pops
popright: right.pops
details: YES
allsnps: YES
inbreed: YES
'''
parfile = 'parfile'
if not os.path.exists(parfile):
    os.mkdir(parfile)
targets = open('0.targets').read().strip().split()
sources = open('0.sources').read().strip().split()
outgroups = open('0.outgroups').read().strip().split()
# outgroups
file = open(parfile + '/' + 'right.pops', 'w')
file.write('\n'.join(outgroups) + '\n')
file.close()
# sources
for target in targets:
    pops = target + '-' + '-'.join(sources)
    # 写pops文件
    file = open(parfile + '/' + pops + '.pops', 'w')
    file.write(target + '\n' + '\n'.join(sources) + '\n')
    file.close()
    # 写par文件
    file = open(parfile + '/' + pops + '.par', 'w')
    file.write(par_template.format(pops))
    file.close()