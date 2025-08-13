 

local Trail = {}
function Trail.new(w, max)
    local c = {}
	c._trail = {}
	c.w = w or 5
	local maxTrailLength = max or 10
    c._trailDuration = 0.05
	c  ._trailTimer = 0
     
    local mm = maxTrailLength

 
    function c:update(dt)
        if dt > 0.02 then dt = 0.02 end
    	self._trailTimer = self._trailTimer + dt 
    	
    	while 1 and self._trailTimer > self._trailDuration do
	    	self._trailTimer = self._trailTimer - self._trailDuration
	    	-- remove two last coordinates:
	    	self._trail[#self._trail] = nil
    		self._trail[#self._trail] = nil
    	end
    end
 
    function c:draw()

    local r,g,b,a = love.graphics.getColor()
    if self.color then
    love.graphics.setColor(
        getColor(self.color)
     )
     end
    
    	if self._trail[1] and self._trail[2] then
	    	love.graphics.circle ('fill', self._trail[1], self._trail[2], ((#self._trail/2)/mm)*c.w)
	    end
    	for i = 3, #self._trail-1, 2 do
    		local w = ((#self._trail-i)/mm)*c.w
    		local ww = love.graphics.getLineWidth()
    		love.graphics.setLineWidth (w)
	    	love.graphics.line (self._trail[i-2], self._trail[i-1], self._trail[i], self._trail[i+1])
	    	love.graphics.circle ('fill', self._trail[i], self._trail[i+1], w/2)
	    	love.graphics.setLineWidth(ww)
    	end
    	
    	love.graphics.setColor(r,g,b,a)
    end

 

    function c:trail(x,y)
    	table.insert (self._trail, 1, y)
    	table.insert (self._trail, 1, x)
    	if #self._trail > 0+maxTrailLength*2-1 then
	    	for i = #self._trail, maxTrailLength*2, -1 do -- backwards
	    		self._trail[i] = nil
	    	end
    	end
    end
    
    return c
end

return Trail