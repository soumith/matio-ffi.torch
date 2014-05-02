matio-ffi
========

A LuaJIT interface to MATIO

# Installation #

First, make sure MATIO is installed on your system. This package only requires the binary shared libraries (.so, .dylib, .dll).
Please see your package management system to install MATIO. 
You can also download and compile matio from [MATIO web page](http://matio.sourceforge.net)

```sh
# OSX
brew install libmatio

# Ubuntu
sudo apt-get install libmatio2
```


```sh
luarocks install https://raw.githubusercontent.com/soumith/matio-ffi.torch/master/rocks/matio-scm-1.rockspec
```

# Usage #

```lua
local matio = require 'matio'
testTensor = matio.load('test.mat', 'var_a')
```

All MATIO C functions are available in the `matio.ffi.` namespace returned by require. The only difference is the naming, which is not prefixed
by `Mat_` anymore. 
