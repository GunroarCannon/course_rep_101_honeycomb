local InputManager = class:extend("InputManager")

InputManager.joyShoot = {
    x = "rightx",
    y = "righty",
}

InputManager.joyMove = {
    x = "leftx",
    y = "lefty"
}

InputManager.deadzone = .3

local KEYS = {}
InputManager.KEYMAP = KEYS
InputManager.KEYMAP["Up"] = {"w"}
InputManager.KEYMAP["Right"] = {"d"}
InputManager.KEYMAP["Down"] = {"s"}
InputManager.KEYMAP["Left"] = {"a"}
--InputManager.KEYMAP["JumpRight"] = {"e"}
--InputManager.KEYMAP["JumpLeft"] = {"q"}
InputManager.KEYMAP["Select"] = {"return", "kpenter"}
InputManager.KEYMAP["Cancel"] = {"escape", "backspace"}

--love.keyboard.setTextInput(true)
--[[KEYS.ShootUp = {"w"}
KEYS.ShootTopLeft = {"q"}
KEYS.ShootTopRight = {"e"}
KEYS.ShootDown = {"s"}
KEYS.ShootBottomLeft = {"z"}
KEYS.ShootBottomRight = {"c"}
KEYS.ShootRight = {"d"}
KEYS.ShootLeft = {"a"}


KEYS.PlaceBottomBlock = {"n"}
KEYS.PlaceBottomLeftBlock = {"b"}
KEYS.PlaceBottomRightBlock = {"m"}
KEYS.PlaceTopBlock = {"u"}
KEYS.PlaceTopLeftBlock = {"y"}
KEYS.PlaceTopRightBlock = {"i"}
KEYS.PlaceLeftBlock = {"h"}
KEYS.PlaceRightBlock = {"k"}
]]
KEYS.Slot1 = {"1"}
KEYS.Slot2 = {"2"}
KEYS.Slot3 = {"3"}

KEYS.Build = {"space"}
KEYS.Jump = {"w"}

function InputManager:__init__()
    self.active = false
	self.keys = {}
end

function InputManager:isDown(key)
    if (not self.active) then
        return
    end
    
    --log(key.."?")
	for _, v in ipairs(InputManager.KEYMAP[key] or {}) do
	if self.keys[v] and dkey then self.keys[v] = self.keys[v]-1 if (self.keys[v]<0) then
	self.keys[v] = nil end return true end
		if love.keyboard.isDown(v) then   --self.keys[v] then
			return true
		end
	end
	return false
end
dkey=4
function InputManager:isPressed(key)
	for _, v in ipairs(InputManager.KEYMAP[key]) do
		if self.keys[v] and self.keys[v][1] then
			return true
		end
	end
	return false
end

function InputManager:isRepeated(key)
	for _, v in ipairs(InputManager.KEYMAP[key]) do
		if self.keys[v] and self.keys[v][2] then
			return true
		end
	end
	return false
end

function InputManager:keyPressed(key)
    self.keys[key] = 5 if 1 then return end
	if not self.keys[key] then
		self.keys[key] = {
			true,
			true
		}
	else
		self.keys[key][2] = true
		self.keys[key][1] = true
	end
end

function InputManager:keyReleased(key)
	--self.keys[key] = nil
end

function InputManager:focus(focus)
	if not focus then
		for k, _ in pairs(self.keys) do
			self.keys[k] = nil
		end
	end
end

function InputManager:clear()
	for _, v in pairs(self.keys) do
	    if type(v) == "table" then
	    	v[1] = false
	    	v[2] = false
	    end
	end
end

function InputManager:update()
	self:clear()
end

        

return InputManager