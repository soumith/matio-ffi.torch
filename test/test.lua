mat = require 'matio'

a=mat.load('test.mat', 'a')
print(a)

print(a[1][1][1])
print(a[1][1][2])
print(a[1][1][3])

print(a[2][2][3])


a1 = mat.load('test.mat')

OK = a:dist(a1['a']) == 0
print(OK and 'OK' or 'Error on valriable number of arguments to read')

a2 = mat.load('test.mat',{'a'})

OK = a:dist(a2['a']) == 0
print(OK and 'OK' or 'Error on given number of arguments to read')

a3 = mat.load('test.mat','b')
OK = a3 == nil
print(OK and 'OK' or 'Error on wrong argument name')
