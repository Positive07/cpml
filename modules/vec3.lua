--- A 3 component vector.
-- @module vec3

local sqrt= math.sqrt
local ffi = require "ffi"

local vec3 = {}
vec3.x = 0
vec3.y = 0
vec3.z = 0

--- The private constructor, do not call this in general.
-- @tparam number x x component
-- @tparam number y y component
-- @tparam number z z component
function vec3.__new(x, y, z)
	return setmetatable({}, vec3_mt)
end

-- Do the check to see if JIT is enabled. If so use the optimized FFI structs.
local status
if type(jit) == "table" and jit.status() then
	status, _ = pcall(require, "ffi")
	if status then
		ffi.cdef "typedef struct { double x, y, z;} cpml_vec3;"
		vec3.__new = ffi.typeof("cpml_vec3")
	end
end

--- The public constructor.
-- @param x Can be of three types: </br>
--	<u1>
--	<li> number x component
--	<li> table {x, y, z} or {x = x, y = y, z = z}
-- 	<li> scalar to fill the vector eg. {x, x, x}
-- @tparam number y y component
-- @tparam number z z component
function vec3.new(x, y, z)
	-- number, number, number
	if x and y and z then
		assert(type(x) == "number", "new: Wrong argument type for x (<number> expected)")
		assert(type(y) == "number", "new: Wrong argument type for y (<number> expected)")
		assert(type(z) == "number", "new: Wrong argument type for z (<number> expected)")

		return vec3.__new(x, y, z)

	-- {x=x, y=y, z=z} or {x, y, z}
	elseif type(x) == "table" then
		local x, y, z = x.x or x[1], x.y or x[2], x.z or x[3]
		assert(type(x) == "number", "new: Wrong argument type for x (<number> expected)")
		assert(type(y) == "number", "new: Wrong argument type for y (<number> expected)")
		assert(type(z) == "number", "new: Wrong argument type for z (<number> expected)")

		return vec3.__new(x, y, z)

	-- {x, x, x} eh. {0, 0, 0}, {3, 3, 3}
	elseif type(x) == "number" then
		return vec3.__new(x, x, x)
	end
end

--- Clone a vector.
-- @tparam @{vec3} vec vector to be cloned
function vec3.clone(a)
	ffi.copy(vec3.new(), a, ffi.sizeof(out))
end

--- Add two vectors.
-- @tparam @{vec3} out vector to store the result
-- @tparam @{vec3} a Left hand operant
-- @tparam @{vec3} b Right hand operant
function vec3.add(out, a, b)
	out.x = a.x + b.x
	out.y = a.y + b.y
	out.z = a.z + b.z
end

--- Subtract one vector from another.
-- @tparam @{vec3} out vector to store the result
-- @tparam @{vec3} a Left hand operant
-- @tparam @{vec3} b Right hand operant
function vec3.sub(out, a, b)
	out.x = a.x - b.x
	out.y = a.y - b.y
	out.z = a.z - b.z
end

--- Multiply two vectors.
-- @tparam @{vec3} out vector to store the result
-- @tparam @{vec3} a Left hand operant
-- @tparam @{vec3} b Right hand operant
function vec3.mul(out, a, b)
	out.x = a.x * b
	out.y = a.y * b
	out.z = a.z * b
end

--- Divide one vector by another.
-- @tparam @{vec3} out vector to store the result
-- @tparam @{vec3} a Left hand operant
-- @tparam @{vec3} b Right hand operant
function vec3.div(out, a, b)
	out.x = a.x / b
	out.y = a.y / b
	out.z = a.z / b
end

--- Get the cross product of two vectors.
-- @tparam @{vec3} out vector to store the result
-- @tparam @{vec3} a Left hand operant
-- @tparam @{vec3} b Right hand operant
function vec3.cross(out, a, b)
	out.x = a.y * b.z - a.z * b.y
	out.y = a.z * b.x - a.x * b.z
	out.z = a.x * b.y - a.y * b.x
end


--- Get the dot product of two vectors.
-- @tparam @{vec3} a Left hand operant
-- @tparam @{vec3} b Right hand operant
-- @treturn number 
function vec3.dot(a, b)
	return a.x * b.x + a.y * b.y + a.z * b.z
end


--- Get the normal of a vector.
-- @tparam @{vec3} out vector to store the result
-- @tparam @{vec3} a vector to normalize
function vec3.normalize(out, a)
	local l = vec3.len(a)
	out.x = a.x / l
	out.y = a.y / l
	out.z = a.z / l
end

--- Get the length of a vector.
-- @tparam @{vec3} a vector to get the length of
-- @treturn number
function vec3.len(a)
	return sqrt(a.x * a.x + a.y * a.y + a.z * a.z)
end

--- Get the squared length of a vector.
-- @tparam @{vec3} a vector to get the squared length of
-- @treturn number
function vec3.len2(a)
	return a.x * a.x + a.y * a.y + a.z * a.z
end

--- Get the distance between two vectors.
-- @tparam @{vec3} a first vector
-- @tparam @{vec3} b second vector
-- @treturn number
function vec3.dist(a, b)
	local dx = a.x - b.x
	local dy = a.y - b.y
	local dz = a.z - b.z
	return sqrt(dx * dx + dy * dy + dz * dz)
end

--- Get the squared distance between two vectors.
-- @tparam @{vec3} a first vector
-- @tparam @{vec3} b second vector
-- @treturn number
function vec3.dist2(a, b)
	local dx = a.x - b.x
	local dy = a.y - b.y
	local dz = a.z - b.z
	return dx * dx + dy * dy + dz * dz
end

--- Lerp between two vectors.
-- @tparam @{vec3} a first vector
-- @tparam @{vec3} b second vector
-- @treturn @{vec3}
function vec3.lerp(a, b, s)
	return a + s * (b - a)
end

--- Unpack a vector into form x,y,z
-- @tparam @{vec3} a first vector
-- @treturn number x component
-- @treturn number y component
-- @treturn number z component
function vec3.unpack(a)
	return a.x, a.y, a.z
end

--- Return a string formatted "{x, y, z}"
-- @tparam @{vec3} a the vector to be turned into a string
-- @treturn string
function vec3.tostring(a)
	return string.format("(%+0.3f,%+0.3f,%+0.3f)", a.x, a.y, a.z)
end

--- Return a boolean showing if a table is or is not a vector
-- @param v the object to be tested
-- @treturn boolean
function vec3.isvector(v)
	return 	type(v) == "table" and
			type(v.x) == "number" and
			type(v.y) == "number" and
			type(v.z) == "number"
end

local vec3_mt = {}

vec3_mt.__index = vec3
vec3_mt.__call = vec3.new
vec3_mt.__tostring = vec3.tostring

function vec3_mt.__unm(a)
	return vec3.new(-a.x, -a.y, -a.z)
end

function vec3_mt.__eq(a,b)
	assert(vec3.isvector(a), "__eq: Wrong argument type for left hand operant. (<cpml.vec3> expected)")
	assert(vec3.isvector(b), "__eq: Wrong argument type for right hand operant. (<cpml.vec3> expected)")

	return a.x == b.x and a.y == b.y and a.z == b.z
end

function vec3_mt.__add(a, b)
	assert(vec3.isvector(a), "__add: Wrong argument type for left hand operant. (<cpml.vec3> expected)")
	assert(vec3.isvector(b), "__add: Wrong argument type for right hand operant. (<cpml.vec3> expected)")

	local temp = vec3.new()
	vec3.add(temp, a, b)
	return temp
end

function vec3_mt.__mul(a, b)
	local isvecb = isvector(b)
	a, b = isvecb and b or a, isvecb and a or b

	assert(vec3.isvector(a), "__mul: Wrong argument type for left hand operant. (<cpml.vec3> expected)")
	assert(type(b) == "number", "__mul: Wrong argument type for right hand operant. (<number> expected)")

	local temp = vec3.new()
	vec3.mul(temp, a, b)
	return temp
end

function vec3_mt.__div(a, b)
	local isvecb = isvector(b)
	a, b = isvecb and b or a, isvecb and a or b

	assert(vec3.isvector(a), "__div: Wrong argument type for left hand operant. (<cpml.vec3> expected)")
	assert(type(b) == "number", "__div: Wrong argument type for right hand operant. (<number> expected)")

	local temp = vec3.new()
	vec3.div(temp, a, b)
	return temp
end

if status then
	ffi.metatype(cpml_vec3, vec3_mt)
end

return setmetatable({}, vec3_mt)
