require 'torch'
local ffi = require 'ffi'
local mat = require 'matio.ffi'

local matio = {}
matio.ffi = mat


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

local function load_tensor(file, var)
   local out
   local sizeof
   -- type check
   mapper = tensor_types_mapper[tonumber(var.class_type)]
   if mapper then
      out = torch[mapper.constructor]()
      sizeof = mapper.sizeof   
   else
      print('Unsupported type of tensor: ' .. var.class_type)
      print('Only matrices are supported')
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
   
   -- -- transpose, because matlab is column-major
   if out:dim() > 1 then
      for i=1,math.floor(out:dim()/2) do
         out=out:transpose(i, out:dim()-i+1)
      end
   end
   return out
end

local function mat_read_variable(file, var)
   print(var.class_type)   

   if tensor_types_mapper[tonumber(var.class_type)] then
      print('loading tensor')
      return load_tensor(file, var)
   end

   if var.class_type == mat.C_CELL then
      print('loading cell')
      -- todo: finish support for cells (currently incorrect)
      local cell = mat.varGetCell(var, 0)
      return mat_read_variable(file, cell)
   end

   local out = {}
 
   if var.class_type == mat.C_STRUCT then
       print('loading struct')
       n_fields = mat.varGetNumberOfFields(var)
       field_names =  mat.varGetStructFieldnames(var)
       for i=0,n_fields-1 do
         field_name = ffi.string(field_names[i])
         print(field_name)
         field_value = mat.varGetStructFieldByIndex(var, i, 0)
         out[field_name] = mat_read_variable(file, field_value)
      end   
   end 
   
   return out

end

--[[
   Load a given variable from a given .mat file as a torch tensor of the appropriate type
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
         var_name_str = ffi.string(var.name)
         table.insert(names, var_name_str)
         print(var_name_str)
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
      local x = mat_read_variable(file, var)
      if x == nil then
         print('Could not find variable with name: ' .. name .. ' in file: ' .. ffi.string(mat.getFilename(file)))
      end
      out[varname] = x
   end

   mat.close(file)

   -- conserve backward compatibility
   if #names == 1 and string_name then
      return out[names[1]]
   else
      return out
   end
end

return matio
