mat = require 'matio'

a=mat.load('test.mat', 'a')
print(a)

OK = a[1][3][4] == 23

print(OK and 'OK' or 'Error reading tensor values in the right order')

a1 = mat.load('test.mat')

OK = a:dist(a1['a']) == 0
print(OK and 'OK' or 'Error on variable number of arguments to read')

a2 = mat.load('test.mat',{'a'})
OK = a:dist(a2['a']) == 0
print(OK and 'OK' or 'Error on given number of arguments to read')


a3 = mat.load('test.mat','b')
OK = a3 == nil
print(OK and 'OK' or 'Error on wrong argument name')



mat.use_lua_strings = true

vars = mat.load('test2.mat')

OK = vars and vars['c'] and vars['s'] and vars['m']

print(OK and 'OK' or 'Error reading all variables')

OK = table.getn(vars.c) == 3

print(OK and 'OK' or 'Error reading cell array')

OK = vars.c[1] == 'one' 

print(OK and 'OK' or 'Error reading strings')

OK = vars.s['matrix']

print(OK and 'OK' or 'Error reading struct with a tensor field')

OK = vars.s['matrix'][3][1] == 13

print(OK and 'OK' or 'Error at reading tensor value')


------------------------------------------------------
--save
------------------------------------------------------
-- save one variable
a = torch.rand(2,3,4)
filename = paths.tmpname()
mat.save(filename,a)
aa = mat.load(filename,'x')
assert(torch.isTensor(aa))
assert(a:eq(aa):all())
assert(aa:size(1)==2 and aa:size(2)==3 and aa:size(3)==4)

-- save a set of variables of different types and dimensions
a = torch.rand(2,3,4)
b = torch.rand(3,4):float()
filename = paths.tmpname()
mat.save(filename,{x1=a,x2=b})
aa = mat.load(filename)
assert(torch.isTensor(aa.x1) and torch.isTensor(aa.x2))
assert(a:eq(aa.x1):all() and b:eq(aa.x2):all())
assert(aa.x1:size(1)==2 and aa.x1:size(2)==3 and aa.x1:size(3)==4)
assert(aa.x2:size(1)==3 and aa.x2:size(2)==4)

print('Saving is OK!')
