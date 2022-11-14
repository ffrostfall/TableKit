--[=[
	@class TableKit
	
	The container for everything inside of TableKit.
]=]
local TableKit = {}

--[=[
	This function "deep" copies a table, and all of its contents. This means that it will clone the entire table,
	and tables within that table- as opposed to shallow-copying with table.clone
	
	```lua
	local Dictionary = {
		SomethingInside = {
			A = 1,
			B = 2,
		},
	}
	
	local CopiedDictionary = TableKit.DeepCopy(Dictionary, SecondDictionary)
	
	print(CopiedDictionary) -- prints { ["SomethingInside"] = { ["A"] = 1, ["B"] = 1 } }
	```
	
	:::caution Recursive Function
	This function is recursive- this can cause stack overflows.

	@within TableKit
	@param tableToClone table
	@return table
]=]
function TableKit.DeepCopy<T>(tableToClone: T): T
	local result: T = {}

	for key: number, v in tableToClone do
		if typeof(v) == "table" then
			result[key] = TableKit.DeepCopy(v)
		else
			result[key] = v
		end
	end

	return result
end

--[=[
	This function merges two dictionaries.

	Keys *will* overwrite- if there are duplicate keys, dictionary2 will take priority.

	```lua
	local Dictionary = {
		A = 1,
		B = 2,
	}
	local SecondDictionary = {
		C = 3,
		D = 4,
	}
	
	print(TableKit.MergeDictionary(Dictionary, SecondDictionary)) -- prints { ["A"] = 1, ["B"] = 2, ["C"] = 3, ["D"] = 4 }
	```
	
	:::caution Potential overwrite
	Keys are overwritten when using .MergeDictionary()
	
	@within TableKit
	@param dictionary1 table
	@param dictionary2 table
	@return table
]=]
function TableKit.MergeDictionary<dictionary1, dictionary2>(dictionary1: {}, dictionary2: {}): dictionary1 & dictionary2
	local newTable = table.clone(dictionary1)

	for key, value in dictionary2 do
		newTable[key] = value
	end

	return newTable
end

--[=[
	This function returns a table with the keys of the passed dictionary.
	
	```lua
	local Dictionary = {
		A = 1,
		B = 2,
		C = 3,
	}
	
	print(TableKit.Keys(Dictionary)) -- prints {"A", "B", "C"}
	```

	@within TableKit
	@param dictionary table
	@return table
]=]
function TableKit.Keys<T>(dictionary: { [T]: any }): { T }
	local keyArray = {}

	for key, _ in dictionary do
		table.insert(keyArray, key)
	end

	return keyArray
end

--[=[
	This function returns a table with the values of the passed dictionary.
	
	```lua
	local Dictionary = {
		A = 1,
		B = 2,
		C = 3,
	}
	
	print(TableKit.Values(Dictionary)) -- prints {1, 2, 3}
	```

	@within TableKit
	@param dictionary table
	@return table
]=]
function TableKit.Values<T>(dictionary: { [any]: T }): { T }
	local valueArray = {}

	for _, value in dictionary do
		table.insert(valueArray, value)
	end

	return valueArray
end

--[=[
	Merges two arrays. array2 will be added to array1- this means that the indexes of array1 will be the same.
	
	```lua
	local FirstArray = {"A", "B", "C", "D"}
	local SecondArray = {"E", "F", "G", "H"}
	
	print(TableKit.MergeArray(FirstArray, SecondArray)) -- prints {"A", "B", "C", D", "E", "F", "G", "H"}
	```

	@within TableKit
	@param array1 table
	@param array2 table
	@return table
]=]
function TableKit.MergeArray<T>(array1: { [number]: T }, array2: { [number]: T }): { [number]: T }
	local newTable = table.clone(array1)

	for _, value in array2 do
		table.insert(newTable, value)
	end

	return newTable
end

--[=[
	Deep-reconciles a dictionary into another dictionary.
	
	```lua
	local template = {
		A = 0,
		B = 0,
		C = {
			D = "",
		},
	}

	local toReconcile = {
		A = 9,
		B = 8,
		C = {},
	}
	
	print(TableKit.Reconcile(toReconcile, template)) -- prints { A = 9, B = 8, C = { D = "" }
	```

	@within TableKit
	@param original table
	@param reconcile table
	@return table
]=]
function TableKit.Reconcile<T>(original: { [any]: any }, reconcile: T): T
	local tbl = table.clone(original)

	for key, value in reconcile do
		if tbl[key] == nil then
			if typeof(value) == "table" then
				tbl[key] = TableKit.DeepCopy(value)
			else
				tbl[key] = value
			end
		elseif typeof(reconcile[key]) == "table" then
			if typeof(value) == "table" then
				tbl[key] = TableKit.Reconcile(value, reconcile[key])
			else
				tbl[key] = TableKit.DeepCopy(reconcile[key])
			end
		end
	end

	return tbl
end

--[=[
	Detects if a table is an array, meaning purely number indexes.
	
	```lua
	local Array = {"A", "B", "C", "D"}
	local Dictionary = { NotAnArray = true }
	
	print(TableKit.IsArray(Array), TableKit.IsArray(Dictionary)) -- prints true, false
	```

	@within TableKit
	@param mysteryTable table
	@return boolean
]=]
function TableKit.IsArray(mysteryTable: { [any]: any }): boolean
	local count = 0
	for _, _ in mysteryTable do
		count += 1
	end
	return count == #mysteryTable
end

--[=[
	Detects if a table is a dictionary, meaning it is not purely number indexes.
	
	```lua
	local Array = {"A", "B", "C", "D"}
	local Dictionary = { NotAnArray = true }
	
	print(TableKit.IsDictionary(Array), TableKit.IsDictionary(Dictionary)) -- prints false, true
	```

	@within TableKit
	@param mysteryTable table
	@return boolean
]=]
function TableKit.IsDictionary(mysteryTable: { [any]: any }): boolean
	return not TableKit.IsArray(mysteryTable)
end

--[=[
	Converts a table into a string.
	
	```lua
	local DictionaryA = {
		A = "Z",
		B = "X",
		C = "Y",
	}
	
	print(TableKit.ToString(DictionaryA)) -- prints {
							--			[A]: Z
							--			[C]: Y
							--			[B]: X
							--		 }
	```

	@within TableKit
	@param obj {}
	@return string
]=]
function TableKit.ToString(obj: { [any]: any }): string
	local str = ""
	for key, value in obj do
		local stringifiedKey = tostring(key)
		local stringifiedValue = tostring(value)

		local newline = string.format("[%*]: %*\n", stringifiedKey, stringifiedValue)
		str ..= newline
	end
	return str
end

--[=[
	Takes in a data type, and returns it in array form.
	
	```lua
	local str = "Test"
	
	print(TableKit.From(str)) -- prints ("T", "e", "s", t")
	```

	@within TableKit
	@param value any
	@return { [number]: any }
]=]
function TableKit.From(value: any): { [number]: any }
	if typeof(value) == "string" then
		local arr = {}
		for i = 1, string.len(value) do
			table.insert(arr, string.sub(value, i, i))
		end
		return arr
	elseif typeof(value) == "Color3" then
		return { value.R, value.G, value.B }
	elseif typeof(value) == "Vector2" then
		return { value.X, value.Y }
	elseif typeof(value) == "Vector3" then
		return { value.X, value.Y, value.Z }
	elseif typeof(value) == "NumberSequence" then
		return value.Keypoints
	elseif typeof(value) == "Vector3int16" then
		return { value.X, value.Y, value.Z }
	elseif typeof(value) == "Vector2int16" then
		return { value.X, value.Y }
	else
		return { value }
	end
end

--[=[
	Creates a shallow copy of an array, passed through a filter callback- if the callback returns false, the element is removed.
	
	```lua
	local str = "Test"
	
	print(TableKit.From(str)) -- prints ("T", "e", "s", t")
	```

	@within TableKit
	@param arr { [number]: any }
	@param callback (value: value) -> boolean
	@return { [number]: any }
]=]
function TableKit.Filter<T>(arr: { [number]: T }, callback: (value: T) -> boolean)
	local tbl = {}

	for _, value in arr do
		if callback(value) then
			table.insert(tbl, value)
		end
	end

	return tbl
end

--[=[
	Loops through every single element, and puts it through a callback. If the callback returns true, the function returns true.
	
	```lua
	local array = {1, 2, 3, 4, 5}
	local even = function(value) return value % 2 == 0 end

	print(TableKit.Some(array, even)) -- Prints true
	```
	
	@within TableKit
	@param arr {}
	@param callback (value) -> boolean
	@return boolean
]=]
function TableKit.Some(arr: { [any]: any }, callback: (value: any) -> boolean): boolean
	for _, value in arr do
		if callback(value) == true then
			return true
		end
	end
	return false
end

--[=[
	Detects if a table has an embedded table as one of its members.
	
	```lua
	local Shallow = {"a", "b"}
	local Deep = {"a", {"b"}}
	
	print(TableKit.IsFlat(Shallow)) -- prints true
	print(TableKit.IsFlat(Deep)) -- prints true
	```
	
	@within TableKit
	@param tbl table
	@return boolean
]=]
function TableKit.IsFlat(tbl: { [any]: any }): boolean
	for _, v in tbl do
		if typeof(v) == "table" then
			return false
		end
	end
	return true
end

--[=[
	Loops through every single element, and puts it through a callback. If any of the conditions return false, the function returns false.
	
	```lua
	local array = {1, 2, 3, 4, 5}
	local even = function(value) return value % 2 == 0 end
	local odd = function(value) return value % 2 ~= 0 end
	
	print(TableKit.Every(array, even)) -- Prints false
	print(TableKit.Every(array, odd)) -- Prints false
	```
	
	@within TableKit
	@param array {}
	@param callback (value) -> boolean
	@return boolean
]=]
function TableKit.Every<T>(array: { [number]: value }, callback: (value) -> boolean): (boolean, number)
	for index, value in array do
		if not callback(value) then
			return false, index
		end
	end
	return true
end

--[=[
	Detects if a dictionary has a certain key.
	
	```lua
	local Dictionary = {
		Hay = "A",
		MoreHay = "B",
		Needle = "C",
		SomeHay = "D",
	}
	
	print(TableKit.HasKey(Dictionary, "Needle")) -- prints true
	```
	
	@within TableKit
	@param dictionary table
	@param key any
	@return boolean
]=]
function TableKit.HasKey<T>(dictionary: { [T]: any }, key: T)
	return dictionary[key] ~= nil
end

--[=[
	Detects if a dictionary has a certain value.
	
	```lua
	local Array = { "Has", "this", "thing" }
	
	print(TableKit.HasValue(Array, "Has")) -- prints true
	```
	
	@within TableKit
	@param tbl table
	@param value any
	@return boolean
]=]
function TableKit.HasValue(tbl: { [any]: any }, value: any)
	for _, v in tbl do
		if v == value then
			return true
		end
	end
	return false
end

--[=[
	Detects if a table is empty.
	
	```lua
	local Empty = {}
	local NotEmpty = { "Stuff" }
	
	print(TableKit.IsEmpty(Empty), TableKit.IsEmpty(NotEmpty)) -- prints true, false
	```

	@within TableKit
	@param mysteryTable table
	@return boolean
]=]
function TableKit.IsEmpty(mysteryTable: { [any]: any })
	return next(mysteryTable) == nil
end

return TableKit
