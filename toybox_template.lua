local DIRECTORY = "wizard"

req = function(n)
    return require_and_sign(string.format("%s.%s",DIRECTORY,n))
end

scale = 1
_W, _H = 1280/scale,800/scale
tw, th = 50, 50
aspect.setGame(_W, _H)

local VController = toybox.Controller("VController")
local old_v_init = VController.__init__
function VController:__init__(k, ...)

    local k = k or {}
    k.noRjoystick = true
    k.noLjoystick = not toybox.getData("rem").joystick and true or false
    if not toybox.getData("rem").leftJoy then
        self.buttonw = W()*0.0781*(not k.noLjoystick and 1 or 2)
        self.buttonh = W()*0.0781*(not k.noLjoystick and 1 or 2)
    
    
        k. ly = love.graphics.getHeight()-self.buttonw*3/2-20 
        k.   lx = love.graphics.getWidth()-self.buttonw*3/2-20
    end
    
    old_v_init(self, k, ...)
    self.paddy.dpad.buttons = {}
    local joy = self.paddy. Ljoystick or self.paddy.Rjoystick
    self.joy = self.Ljoystick
    if joy then
        joy:setDigital(false)
        self.joystick = true
        local b = self.paddy.buttons.buttons
        for x, i in ipairs(lume.copy(b)) do
            if i ~= joy then
                lume.remove(b,i)
            end
        end
        self.joy = joy
   end
end


function VController:mousepressed(x,y)

    if DESKTOP then
        local x,y = self.room.camera:toWorldCoords( res.getMousePosition(x,y))
        

   
   end
end

function VController:mousereleased(x,y)
    local x,y = self.room.camera:toWorldCoords( res.getMousePosition(x,y))
    
   -- self.Rjoystick.anglee = nil



end

function VController:keypressed(s)
  
end


function VController:keyreleased(s) 
    --if s == "quit" then love.event.quit() end
    
    local v = tonumber(s)
    if v then
        local am = self.room.availableMoves
        if am and am[v] then
            am[v].events.r(am[v])
        end
    end

end
local cam = {x=W()/2,y=H()/2}

local function fixV(vx, vy, deadzone)
    
    local abx = math.abs(vx)
    local aby = math.abs(vy)
    
    if aby < 1 and aby >= deadzone then
        vy = getDir(vy)
    elseif aby < 1 then
        vy = 0
    end
    
    if abx < 1 and abx >= deadzone then
        vx = getDir(vx)
    elseif abx < 1 then
        vx = 0
    end
    
    return vx, vy
end

function VController:step(dt, vvx, vvy, derived)
    --love.keyboard.setTextInput(true)
    local vx = self.joy:getXDir()
    local vy = self.joy:getYDir()
    
    local abx = math.abs(vx)
    local aby = math.abs(vy)
    
    local deadzone = .6
    
    if aby < 1 and aby >= deadzone then
        vy = getDir(vy)
    elseif aby < 1 then
        vy = 0
    end
    
    if abx < 1 and abx >= deadzone then
        vx = getDir(vx)
    elseif abx < 1 then
        vx = 0
    end
end

tw, th = 36, 36
local Entity = toybox.Object("Entity")

function Entity:create(k)
    
    self.w = k.w or tw
    self.h = k.h or th
    self.stats = {
        
    }
end

function Entity:something()
end


local Stage = toybox.Room("Stage")

function Stage:setup()
end

local game = toybox.Game("game")

function game:setup()
    self:setSource(string.format("%s/assets/%s",DIRECTORY,"%s"))
    self.useImages = true
    self.squash = false
    
    
    self:set_room(Stage)
end

return game