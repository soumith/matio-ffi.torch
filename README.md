matio-ffi
========

A LuaJIT interface to MATIO

# Installation #

First, make sure MATIO is installed on your system. This package only requires the binary shared libraries (.so, .dylib, .dll).
Please see your package management system to install MATIO. 
You can also download and compile matio from [MATIO web page](http://matio.sourceforge.net)
If you are manually compiling matio from scratch (instead of using your package manager), please disable hdf5 support, [it seems to have a bug](https://github.com/soumith/matio-ffi.torch/issues/7). 

```sh
# OSX
brew install libmatio

# Ubuntu
sudo apt-get install libmatio2
```


```sh
luarocks install matio
```

# Usage #
###Load a tensor from matlab array
```lua
local matio = require 'matio'
-- load a single array from file
tensor = matio.load('test.mat', 'var_a')
-- load multiple arrays from file
tensors = matio.load('test.mat',{'var1','var2'})
-- load all arrays from file
tensors = matio.load('test.mat')
```

###Load structs, cell arrays and strings

There is some basic support for more complex data structures defined by the MAT file format.
Structs will be converted to lua tables, indexed by their field names. Cell arrays are converted to lua arrays (tables indexed by numerals).

```lua
local matio = require 'matio'
-- load a struct, which contains tensors, cell arrays and strings
my_complex_data = matio.load('test.mat')
```

If you want to read sequences of characters as lua strings instead of Torch CharTensor, enable the following flag:

```lua
matio.use_lua_strings = true
-- load data
data_with_strings = matio.load('test.mat')
```

###Save a tensor or a set of tensors to a .mat file
```lua
local matio = require 'matio'
-- save a single tensor to a .mat file
data = torch.rand(5,5)
matio.save('test1.mat',data)
-- save a set of tensors to a .mat file
data1 = torch.rand(5,5)
data2 = torch.rand(2,3):float()
matio.save('test2.mat',{t1=data1,t2=data2})
```
By default, the matlab files are saved in MAT5 format, using ZLIB compression. To save without compression, change the following variable:
```lua
matio.compression = matio.ffi.COMPRESSION_NONE -- without compression
matio.compression = matio.ffi.COMPRESSION_ZLIB -- default compression
```

### Calling MATIO C functions

All MATIO C functions are available in the `matio.ffi.` namespace returned by require. The only difference is the naming, which is not prefixed
by `Mat_` anymore. 

For example, look at matio.load in init.lua
