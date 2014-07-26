mat = require 'matio'

a=mat.load('test.mat', 'a')
print(a)

print(a[1][1][1])
print(a[1][1][2])
print(a[1][1][3])

print(a[2][2][3])


aa = mat.load('test.mat')

OK = a:dist(aa) == 0
print(OK and 'OK' or 'Error on valriable number of things to read')
