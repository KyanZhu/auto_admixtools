import sys

def combination(li):
    if "# Combination" in li or "#Combination" in li or "# combination" in li or "#combination" in li:
        new_li = []
        tmp_li = []
        for i in li:
            if "#" not in i:
                tmp_li.append(i)
            else:
                if tmp_li:
                    new_li.append(tmp_li)
                tmp_li = []
        new_li.append(tmp_li)
        return new_li
    else:
        return False


def remove_comment(li):
    new_li = []
    for i in li:
        if '#' not in i:
            new_li.append(i)
    return new_li


def count_cls(cls_li, *li):
    count = 0
    for i in li:
        if i in cls_li:
            count += 1
    return count


def pairwise(li):
    li = remove_comment(li)  # 去除'#'号
    result = []
    for i in range(len(li) - 1):
        for j in range(i + 1, len(li)):
            result.append([li[i], li[j]])
    return result


def c2_src(li):
    li = remove_comment(li)  # 去除'#'号
    result = []
    for i in range(len(li) - 1):
        for j in range(i + 1, len(li)):
            result.append([li[i], li[j]])
    return result


def c1(li):
    li = remove_comment(li)
    result = []
    for i in li:
        result.append([i])
    return result


def c2(li):
    cls_li = combination(li)
    li = remove_comment(li)  # 去除'#'号
    result = []
    for i in range(len(li) - 1):
        for j in range(i + 1, len(li)):
            if cls_li:
                for cls in cls_li:
                    if count_cls(cls, li[i], li[j]) > 1:
                        break
                else:
                    result.append([li[i], li[j]])
            else:
                result.append([li[i], li[j]])
    return result


def c3(li):
    cls_li = combination(li)
    li = remove_comment(li)  # 去除'#'号
    result = []
    for i in range(len(li) - 2):
        for j in range(i + 1, len(li) - 1):
            for k in range(j + 1, len(li)):
                if cls_li:
                    for cls in cls_li:
                        if count_cls(cls, li[i], li[j], li[k]) > 1:
                            break
                    else:
                        result.append([li[i], li[j], li[k]])
                else:
                    result.append([li[i], li[j], li[k]])
    return result


def convert(li):
    if type(li) == list:
        return li
    if type(li) == str:
        return [li]

def is_include(comb, src_li, target):
    flag = False
    for i in src_li:
        if i == target:
            flag = True  # 找到起始位置
            continue
        if flag:  # 开始判断是否包含目标人群
            if '#' in i:  # 到下个人群了, 退出
                return False
            for pop in comb:
                if pop == i:  # 包含指定人群
                    return True
    if flag == False:
        print('没有目标人群分组', target)
        sys.exit()
    return False