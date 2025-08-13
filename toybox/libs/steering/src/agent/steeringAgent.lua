--[[
  Copyright (c) 2012 Roland Yonaba

  Permission is hereby granted, free of charge, to any person obtaining a
  copy of this software and associated documentation files (the
  "Software"), to deal in the Software without restriction, including
  without limitation the rights to use, copy, modify, merge, publish,
  distribute, sublicense, and/or sell copies of the Software, and to
  permit persons to whom the Software is furnished to do so, subject to
  the following conditions:

  The above copyright notice and this permission notice shall be included
  in all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
  OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
  CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
  TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
  SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--]]

local Vec = require 'src.core.vector'
local Agent = require 'src.agent.agent'
local SteeringBehaviour = require 'src.behavior.steering'

local SteeringAgent = Agent()
SteeringAgent.behaviours = SteeringBehaviour
SteeringAgent.steering = SteeringBehaviour.pursuit --// Default behavior ?
SteeringAgent.minVelMagSq = 1e-4
SteeringAgent.velHeading = Vec()
SteeringAgent.velPerp = Vec()

SteeringAgent.__index = SteeringAgent

function SteeringAgent:new(x,y,behavior)
  local newSteeringAgent = {pos=Vec(x,y),steering = behavior}
  return setmetatable(newSteeringAgent,SteeringAgent)
end

function SteeringAgent:updateLocalReference()
  if self.vel:magSq() > self.minVelMagSq then
    self.velHeading = self.vel:getNormalized()
    self.velPerp = self.velHeading:getPerp()
  end
end

function SteeringAgent:update(n,...)
  if n then
    self.forceAccum = self:steering(n,...)
  end
  self:integrate(self.dt)
  self:updateLocalReference()
end

function SteeringAgent:updateSteer(steer,n,...)
  local steering = SteeringBehaviour[steer] or error(steer)
  if n then
    self.forceAccum = steering(self,n,...)
  end
  self:integrate(self.dt)
  self:updateLocalReference()
end


for x, i in pairs(SteeringBehaviour) do
  if type(i)=="function" then
    SteeringAgent[x] = function(self,...)
        self.forceAccum = i(self,...)
    end
  end
end

--SteeringBehaviour.seek(agent,targetPos)
--SteeringBehaviour.flee(agent,targetPos, panicDistance)

  
--local DecelerationType = {slow = 3, normal = 2, fast = 1}  
--SteeringBehaviour.arrive(agent, targetPos, typeDec)

---SteeringBehaviour.pursuit(agent, runaway)
--SteeringBehaviour.evade(agent,hunter)
--SteeringBehaviour.wander(agent, radius, distance, jitter)

getmetatable(SteeringAgent)
  .__call = function(self,...) 
    return SteeringAgent:new(...) 
end
return SteeringAgent
