# coding:utf-8
# @Time : 2022/03/08 17:45
# @File : pcaRploter
# @Version: v4.5
# @Author : zky


import argparse


def joinn(var, sep=None, chr=""):
    if sep:
        return chr.join(var.split(sep=sep))
    else:
        return chr.join(var.split())


Usage = """
this procedure will create a Rscript file for further pca plotting
use -h for detailed
poplist format:
    ====pop1====
    ind1
    ind2
    ====pop2====
    ind3
    ind4
"""
print(Usage)
parser = argparse.ArgumentParser()
group = parser.add_argument_group()
group.add_argument('-p', '--poplist', help='specify poplist, default=poplist.txt',
                   default='poplist.txt', type=str)
group.add_argument('-o', '--output', help='specify output file, default=smartpca.r',
                   default='smartpca.r', type=str)
args = parser.parse_args()
print('poplist :', args.poplist)
print('output : ', args.output)
poptext = open(args.poplist).readlines()
pca = open(args.output, 'w')
pop_list = []
pca.writelines("""pdf("smartpca.pdf")
data=read.table("plot.txt")
pop=data[,1]
ind=data[,2]
PC1=data[,3]
PC2=data[,4]
# layout(matrix(c(1,2)),widths=c(2,1),heights=c(3,1))
# par(mar=c(4,4,1,5))
plot(PC1,PC2,type="n")
frame=data.frame(PC1=PC1,PC2=PC2,name=pop,region=pop)
light=c("#FFDAB9", "#ABF4DC", "#D3D3D3", "#b1c8f3", "#ffbbea", "#c8b0f5", "#e2ffa8", "#c1fffa", "#f3f3a9", "#fa9c9c")
deep=c("#CCCC00", "#3787B4", "#00CD66", "#6B8E23", "#D02090", "#FF8C69", "#905aff", "#20B2AA", "#FFC534", "#FFFF00", "#6F96F2", "#8D5223", "#FF1493")


# COLOR SETTINGS
""")


# target_pch = range(21, 27)
# target_col = ['red', 'red', 'blue', 'blue', 'black', 'black']
# target_bg = ['yellow', 'green', 'yellow', 'green', 'yellow', 'green']


j = -1
for i in poptext:
    i = i.strip()
    if i[0] == '=':
        j += 1
        pop_list.append([])
        pop_list[j].append(i.strip("="))
    elif i[0] == "#":
        continue
    else:
        pop_list[j].append(i)
light = 1
deep = 1
for i in range(0, len(pop_list)):
    if i == len(pop_list) - 1:  # target
        pca.writelines(joinn(joinn(pop_list[i][0], "-")) + '_col="#FF0000"\n')
    else:
        if "Ancient" in pop_list[i][0]:
            pca.writelines(
                joinn(joinn(pop_list[i][0], "-")) + f'_col=deep[{str(deep)}]\n')
            deep += 1
        else:
            pca.writelines(
                joinn(joinn(pop_list[i][0], "-")) + f'_col=light[{str(light)}]\n')
            light += 1

# PLOT POPs
pca.writelines("target_col = 'red'\ntarget_bg = 'yellow'\n\n# PLOT")
for i in pop_list:
    pca.writelines(f'# {i[0]}\n')
    if i == pop_list[-1]:  # target, color with border, start from pch=21
        for j in range(1, len(i)):
            pca.writelines(f'reg="{i[j]}"\n')
            pca.writelines(
                'points(subset(frame,region==reg)$PC1,subset(frame,region==reg)$PC2,pch={},col=target_col,bg=target_bg,cex=0.6,lwd=1.2)\n'.format(
                    str(j+20)))

    else:  # not target
        for j in range(1, len(i)):
            pca.writelines(f'reg="{i[j]}"\n')
            if j < 26:
                col_tmp = joinn(joinn(i[0], "-"))
                pca.writelines(
                    'points(subset(frame,region==reg)$PC1,subset(frame,region==reg)$PC2,pch={},col={}_col,bg={}_col,cex=0.6)\n'.format(
                        str(j), col_tmp, col_tmp))
            else:
                col_tmp = joinn(joinn(i[0], "-"))
                pca.writelines(
                    'points(subset(frame,region==reg)$PC1,subset(frame,region==reg)$PC2,pch={},col={}_col,bg={}_col,cex=0.6)\n'.format(
                        str(j + 7), col_tmp, col_tmp))
pca.writelines("dev.off()\n\n# LEGEND\npdf(\"legend.pdf\")\npar(mar=c(5,5,5,5))\nplot.new()\n")
# pops
pops = []
for i in pop_list:
    pops.append('","'.join(i))
pops = '"'+'","'.join(pops)+'"'
pca.writelines(f'pops=c({pops})\n')
# cols,borders,symb,fonts
cols = []
bgs = []
symb = []
fonts = []
for i in pop_list:
    cols.append('NA')
    bgs.append('NA')
    symb.append('NA')
    fonts.append('2')
    if i == pop_list[-1]:
        le = len(i) - 1
        cols.append(f"rep(target_col, {le})")
        bgs.append(f"rep(target_bg, {le})")
        fonts.append(f"rep(1, {le})")
        [symb.append(str(j+21)) for j in range(le)]
    else:
        le = len(i) - 1
        pp = joinn(joinn(i[0], "-")) + "_col"
        cols.append(f"rep({pp}, {le})")
        bgs.append(f"rep({pp}, {le})")
        fonts.append(f"rep(1, {le})")
        [symb.append(str(j + 1)) if j < 25 else symb.append(str(j + 8)) for j in range(le)]
cols = ",".join(cols)
bgs = ",".join(bgs)
symb = ",".join(symb)
fonts = ",".join(fonts)

pca.writelines(f'cols=c({cols})\n')
pca.writelines(f'bgs=c({bgs})\n')
pca.writelines(f'symb=c({symb})\n')
pca.writelines(f'fonts=c({fonts})\n')
pca.writelines(
    'legend("top",pops,pch=symb,pt.bg=bgs,col=cols,ncol=3,cex=0.4,pt.cex=0.4,bty="o",text.font=fonts,xpd=TRUE)\n')
pca.writelines('dev.off()\n')
