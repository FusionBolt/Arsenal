# 1-n 阶乘
from functools import reduce
sum([reduce(lambda x,y:x*y, range(1, i+1)) for i in range(1,int(input()))])
reduce(lambda x,y:x+y, [reduce(lambda x,y:x*y, range(1, i+1)) for i in range(1,int(input()))])

