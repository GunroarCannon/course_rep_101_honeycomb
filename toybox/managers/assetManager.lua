local ResourceManager = class:extend("AssetManager")

function ResourceManager:initialize()
	self.data = {}
end

function ResourceManager:getShader(name)
	local path = "resources/shaders/" .. name
	if not self.data[path] then
		self.data[path] = love.graphics.newShader(path)
	end
	return self.data[path]
end

function ResourceManager:getFont(name, size)
	local path = "resources/fonts/" .. name
	if not self.data[path] then
		self.data[path] = {}
	end
	if not self.data[path][size] then
		self.data[path][size] = love.graphics.newFont(path, size)
	end
	return self.data[path][size]
end

function ResourceManager:getImage(path)
	if not self.data[path] then
		self.data[path] = love.graphics.newImage(path)
	end
	return self.data[path]
end

function ResourceManager:getSystemImage(name)
	return self:getImage("resources/system/" .. name)
end

function ResourceManager:getBackgroundImage(name)
	return self:getImage("resources/background/" .. name)
end

function ResourceManager:getActorImage(name)
	return self:getImage("resources/actors/" .. name)
end

function ResourceManager:getEnemyImage(name)
	return self:getImage("resources/enemies/" .. name)
end

function ResourceManager:getAnimationImage(name)
	return self:getImage("resources/animations/" .. name)
end

return ResourceManager