# https://edotor.net/
with open('file.dot', 'r', encoding='utf-8') as f:
    lines = f.readlines()

label_flag = False
edge_flag = False
admix_flag = False
edge_count = 0
admix_dict = {}
for line in lines:
    # <Label>
    if '<Label>' in line:
        label_flag = True
        continue
    if '</Label>' in line:
        label_flag = False
        print('')

    if label_flag and line.startswith('# '):
        print(line.strip('# ').strip())

    # <Edge>
    if '<Edge>' in line:
        edge_flag = True
        continue
    if '</Edge>' in line:
        edge_flag = False
        print('')

    if '--' in line and edge_flag:
        a, b = line.strip().split('--')
        print(f'edge e{edge_count} {a.strip()} {b.strip()}')
        edge_count += 1

    # <Admix>
    if '<Admix>' in line:
        admix_flag = True
        continue
    if '</Admix>' in line:
        admix_flag = False
    if '--' in line and admix_flag:
        a, b = line.strip().split('--')
        b = b.strip()
        if b in admix_dict:
            print(f'admix {b} {a.strip()} {admix_dict[b]}')
        else:
            admix_dict[b] = a.strip()
