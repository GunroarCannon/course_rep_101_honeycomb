--- Simplex Noise Generator.
-- Based on a simple 2d implementation of simplex noise by Ondrej Zara
-- Which is based on a speed-improved simplex noise algorithm for 2D, 3D and 4D in Java.
-- Which is based on example code by Stefan Gustavson (stegu@itn.liu.se).
-- With Optimisations by Peter Eastman (peastman@drizzle.stanford.edu).
-- Better rank ordering method by Stefan Gustavson in 2012.
-- @module ROT.Noise.Simplex
--- Constructor.
-- 2D simplex noise generator.
-- @tparam int gradients The random values for the noise.
local Class = {}
local lume=require "toybox.libs.lume"
local math_floor = math.floor

function Class:new(...)
    local t = setmetatable({}, self)
    t:init(...)
    return t
end
--problem
function Class:extend(name, t)
    t = t or {}
    t.__index = t
    t.super = self
    return setmetatable(t, { __call = self.new, __index = self })
end

function Class:init()
end



--local Noise = Class:extend("Noise")

--function Noise:get() end

local Simplex=Class:extend("Simplex")

function Simplex:init(gradients)
    self._F2=.5*(math.sqrt(3)-1)
    self._G2=(3-math.sqrt(3))/6

    self._gradients={
                     { 0,-1},
                     { 1,-1},
                     { 1, 0},
                     { 1, 1},
                     { 0, 1},
                     {-1, 1},
                     {-1, 0},
                     {-1,-1}
                    }
    --self.seed = os.time()
    --math.randomseed(self.seed)
    
    local permutations={}
    self.count       =gradients and gradients or 256
    local count      =self.count
    for i=1,self.count do
        permutations[i] = i
    end

    permutations=lume.shuffle(permutations)

    self._perms  ={}
    self._indexes={}

    for i=1,2*count do
        table.insert(self._perms, permutations[i%count+1])
        table.insert(self._indexes, self._perms[i] % #self._gradients +1)
    end
end

--- Get noise for a cell
-- Iterate over this function to retrieve noise values
-- @tparam int xin x-position of noise value
-- @tparam int yin y-position of noise value

function Simplex:get(xin, yin, seed)
    
    local perms  =self._perms
    local indexes=self._indexes
    local count  =#perms/2
    local G2     =self._G2

    local n0, n1, n2, gi=0, 0, 0

    local s =(xin+yin)*self._F2
    local i =math_floor(xin+s)
    local j =math_floor(yin+s)
    local t =(i+j)*G2
    local X0=i-t
    local Y0=j-t
    local x0=xin-X0
    local y0=yin-Y0

    local i1, j1
    if x0>y0 then
        i1=1
        j1=0
    else
        i1=0
        j1=1
    end

    local x1=x0-i1+G2
    local y1=y0-j1+G2
    local x2=x0-1+2*G2
    local y2=y0-1+2*G2

    local ii=i%count+1
    local jj=j%count+1

    local t0=.5- x0*x0 - y0*y0
    if t0>=0 then
        t0=t0*t0
        gi=indexes[ii+perms[jj]]
        local grad=self._gradients[gi]
        if not grad then
            error()
            self:init()
            
            return self:get(xin, yin, seed)
        end
        n0=t0*t0*(grad[1]*x0+grad[2]*y0)
    end

    local t1=.5- x1*x1 - y1*y1
    if t1>=0 then
        t1=t1*t1
        gi=indexes[ii+i1+perms[jj+j1]]
        local grad=self._gradients[gi]
        if not grad then
            self:init()
            
            return self:get(xin, yin, seed)
        end
        n1=t1*t1*(grad[1]*x1+grad[2]*y1)
    end

    local t2=.5- x2*x2 - y2*y2
    if t2>=0 then
        t2=t2*t2
        gi=indexes[ii+1+perms[jj+1]]
        local grad=self._gradients[gi]
        if not grad then
            self:init()
            
            return self:get(xin, yin, seed)
        end
        n2=t2*t2*(grad[1]*x2+grad[2]*y2)
    end
    return 70*(n0+n1+n2)
end

return Simplex
