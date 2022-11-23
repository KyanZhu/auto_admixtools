import sys


input = "".join(sys.argv[1:])
result = (eval(input))
print(round(result, 3), end="")
