require 'torch'
local ffi = require 'ffi'
local mat = require 'matio.ffi'

local matio = {}
matio.ffi = mat

-- optional setting: loads lua strings instead of CharTensor
matio.use_lua_strings = false

-- compression mode for saving
matio.compression = mat.COMPRESSION_ZLIB

-- mapping of MAT matrix types into torch tensor
local tensor_types_mapper = {
   [mat.C_CHAR]   = {constructor='CharTensor',  sizeof=1},  
   [mat.C_INT8]   = {constructor='CharTensor',  sizeof=1},
   [mat.C_UINT8]  = {constructor='ByteTensor',  sizeof=1},
   [mat.C_INT16]  = {constructor='ShortTensor', sizeof=2},
   [mat.C_UINT16] = {constructor='ShortTensor', sizeof=2},
   [mat.C_INT32]  = {constructor='IntTensor',   sizeof=4},
   [mat.C_UINT32] = {constructor='IntTensor',   sizeof=4},
   [mat.C_INT64]  = {constructor='LongTensor',  sizeof=8},
   [mat.C_UINT64] = {constructor='LongTensor',  sizeof=8},
   [mat.C_SINGLE] = {constructor='FloatTensor', sizeof=4},
   [mat.C_DOUBLE] = {constructor='DoubleTensor',sizeof=8}
}

-- mapping of torch tensor into MAT matrix types
local tensor_types_invmapper = {
   ['torch.CharTensor']   = {c_type=mat.C_CHAR,   t_type=mat.T_CHAR},
   ['torch.ByteTensor']   = {c_type=mat.C_UINT8,  t_type=mat.T_UINT8},
   ['torch.ShortTensor']  = {c_type=mat.C_INT16,  t_type=mat.T_INT16},
   ['torch.IntTensor']    = {c_type=mat.C_INT32,  t_type=mat.T_INT32},
   ['torch.LongTensor']   = {c_type=mat.C_INT64,  t_type=mat.T_INT64},
   ['torch.FloatTensor']  = {c_type=mat.C_SINGLE, t_type=mat.T_SINGLE},
   ['torch.DoubleTensor'] = {c_type=mat.C_DOUBLE, t_type=mat.T_DOUBLE}
}

local function save_tensor(file, tensor, name, compression)

   -- get type of tensor
   local mapper = tensor_types_invmapper[tensor:type()]
   local c_type, t_type
   if mapper then
      c_type = mapper.c_type
      t_type = mapper.t_type
   else
      print('Unsupported type of tensor: ' .. tensor:type())
      return
   end

   -- every vector is at least 2d in matlab
   if tensor:dim() == 1 then
      tensor = tensor:view(-1,1)
   end
   local dims = tensor:dim()
   local sizes = tensor:size()

   -- transpose, because matlab is column-major
   if dims > 1 then
      for i=1,math.floor(dims/2) do
         tensor=tensor:transpose(i, dims-i+1)
      end
      tensor = tensor:contiguous()
   end

   local var = mat.varCreate(name, c_type, t_type, dims,
                             sizes:data(), tensor:data(), 0)
   mat.varWrite(file, var, compression)
   mat.varFree(var)
end

local function load_tensor(file, var)
   local out
   local sizeof
   -- type check
   local mapper = tensor_types_mapper[tonumber(var.class_type)]
   if mapper then
      out = torch[mapper.constructor]()
      sizeof = mapper.sizeof   
   else
      print('Unsupported type of tensor: ' .. var.class_type)
      return nil
   end

   -- rank check
   if var.rank > 8 or var.rank < 1 then
      print('Rank of input matrix is invalid: ' .. var.rank)
      
      return nil
   end
   
   local sizes = {}
   for i=0,var.rank-1 do
      table.insert(sizes, tonumber(var.dims[i]))
   end
   -- reverse initialize because of column-major order of matlab
   local revsizes = {}
   for i=1, var.rank do
      revsizes[i] = sizes[var.rank-i+1]
   end

   -- resize tensor
   out:resize(torch.LongStorage(revsizes))

   -- memcpy
   ffi.copy(out:data(), var.data, out:nElement() * sizeof);
   mat.varFree(var);
   
   -- transpose, because matlab is column-major
   if out:dim() > 1 then
      for i=1,math.floor(out:dim()/2) do
         out=out:transpose(i, out:dim()-i+1)
      end
   end
   return out
end

local function load_struct(file, var)
   local out = {}
   local n_fields = mat.varGetNumberOfFields(var)
   local field_names =  mat.varGetStructFieldnames(var)
   for i=0,n_fields-1 do
      local field_name = ffi.string(field_names[i])
      local field_value = mat.varGetStructFieldByIndex(var, i, 0)
      out[field_name] = mat_read_variable(file, field_value)
   end  
   return out
end

local function load_cell(file, var)
   local out = {};
   local index = 0
   while true do
      local cell = mat.varGetCell(var, index) 
      if cell == nil then
         break
      end 
      index = index + 1
      -- using array index starting at 1 (lua standard)
      out[index] = mat_read_variable(file, cell)
   end
   return out
end


local function load_string(file, var)
   return var.data~=nil and ffi.string(var.data) or ''
end

function mat_read_variable(file, var) 

   -- will load C_CHAR sequence as a lua string, instead of torch tensor
   if matio.use_lua_strings == true and var.class_type == mat.C_CHAR then
      return load_string(file, var)
   end

   if var.data == nil then
      return nil
   end

   if tensor_types_mapper[tonumber(var.class_type)] then
      return load_tensor(file, var)
   end

   if var.class_type == mat.C_CELL then
      return load_cell(file, var)
   end
 
   if var.class_type == mat.C_STRUCT then
      local nelems = 1
      for i=0,var.rank-1 do nelems = nelems*tonumber(var.dims[i]) end

      if nelems>1 and var.rank==2 then
         local array = {}
         for i=0,tonumber(var.dims[0])-1 do
            array[i+1] = {}
            for j=0,tonumber(var.dims[1])-1 do
               local fieldvar = mat.varGetStructsLinear(var,i+j*tonumber(var.dims[0]),1,1,0)
               array[i+1][j+1] = load_struct(file, fieldvar)
               mat.varFree(fieldvar);
            end
         end
         return array
      elseif var.rank>2 then
         print('Multidimensional structs currently not implemented.')
      else
          return load_struct(file, var)
      end
   end
   
   print('Unsupported variable type: ' .. tonumber(var.class_type))
   return nil

end

--[[
   Load all variables (or just the requested ones) from a given .mat file 
   It supports structs, cell arrays and tensors of the appropriate types.
   Sequences of characters can optionally be loaded as lua strings instead
   of torch CharTensors.

   matio.load(filename, variableName)
   matio.load(filename)
   matio.load(filename,{'var1','var2'})

   Example:
   local img1 = matio.load('data.mat', 'img1')
--]]
function matio.load(filename, name)

   local file = mat.open(filename, mat.ACC_RDONLY);
   if file == nil then
      print('File could not be opened: ' .. filename)
      return
   end

   local names
   local string_name
   -- if name is not given then load everything
   if not name then
      names = {}
   elseif type(name) == 'string' then
      names = {name}
      string_name = true
   elseif type(name) == 'table' then
      names = name
   end

   if #names == 0 then
      -- go over the file and get the names
      local var = mat.varReadNextInfo(file)
      while var ~= nil do
         local var_name_str = ffi.string(var.name)
         table.insert(names, var_name_str)
         var = mat.varReadNextInfo(file)
      end
   end

   if #names == 0 then
      print('No variables in this file')
      return
   end

   local out = {}
   for i, varname in ipairs(names) do
      local var = mat.varRead(file, varname);

      if var ~= nil then
         local x = mat_read_variable(file, var)
         if x ~= nil then
            out[varname] = x
         end
      else   
         print('Could not find variable with name: ' .. varname .. ' in file: ' .. ffi.string(mat.getFilename(file)))
      end

   end

   mat.close(file)

   -- conserve backward compatibility
   if #names == 1 and string_name then
      return out[names[1]]
   else
      return out
   end
end

--[[
   Save Torch tensors to a .mat file.
   It supports all Torch tensor types (except cuda tensors).
   If you provide a table, it saves all tensors in the table
   as separate variables, whose name in the .mat file is the
   key of the table.
   By default, save the tensors in MAT5 format using ZLIB
   compression. The compression can be changed by setting 
   matio.compression variable to matio.ffi.COMPRESSION_NONE
   or matio.ffi.COMPRESSION_ZLIB

   matio.save(filename, tensor)
   matio.save(filename, {name1=tensor1, name2=tensor2})

   Example:
   local data = torch.rand(5,5)
   matio.save('data.mat', data)
--]]
function matio.save(filename, data)
   local file = mat.createVer(filename, nil, mat.FT_MAT5)

   local compression = matio.compression
   if type(data) == 'table' then
      for k,v in pairs(data) do
         if torch.isTensor(v) then
            save_tensor(file, v, k, compression)
         else
            -- closing file and asserting error
            mat.close(file)
            error('only tensor or table of tensors supported!')
         end
      end
   elseif torch.isTensor(a) then
      save_tensor(file, data, 'x', compression)
   else
      -- closing file and asserting error
      mat.close(file)
      error('only tensor or table of tensors supported!')
   end

   mat.close(file)
end

return matio
