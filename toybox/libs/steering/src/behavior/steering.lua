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


local require = old_require or require

if (...) then
  local _PATH = (...):match('%w+%.')
  require  ('toybox.libs.steering.src.core.math')
  local Vec = require ('toybox.libs.steering.src.core.vector')
  
  local Zero = Vec()
  
  local min, random, cos, sin, tau = math.min, math.random, math.cos, math.sin, math.tau
  local l2Abs, rSign = math.localToAbsoluteReference, math.randomSign
  
  local function getTarget(target)
    if target.x then
      return target
    elseif target.pos then
      return target.pos
    elseif target.agent then
      return target.agent.pos or error("Agent incomplete!")
    end
    error("Invalid target")
  end
  
  local function _getHunter(hunter)
    if hunter.pos then
      return hunter
    elseif hunter.x then
      return {pos = hunter, vx = hunter.vx, vy = hunter.vy}
    elseif hunter.agent then
      return hunner.agent
    end
    error("Invalid hunter")
  end
  
  local function getHunter(h)
    h = _getHunter(h)
    h.vel = h.vel or Vec(h.vx or 0, h.vy or 0)
    return h
  end
    
  
  local SteeringBehaviour = {}

  function SteeringBehaviour.seek(agent,targetPos)
    local targetPos = getTarget(targetPos)
    
    local requiredVel = (targetPos - agent.pos):normalize() * agent.maxVel
    return requiredVel - agent.vel
  end

  function SteeringBehaviour.flee(agent,targetPos, panicDistance)
    local targetPos = getTarget(targetPos)
    if panicDistance then
      if agent.pos:distSqTo(targetPos) < panicDistance * panicDistance then
        local requiredVel = (agent.pos - targetPos):normalize() * agent.maxVel
        return requiredVel - agent.vel     
      end
    end
    return Zero
  end
  
  local DecelerationType = {slow = 3, normal = 2, fast = 1}  
  function SteeringBehaviour.arrive(agent, targetPos, typeDec)
local targetPos = getTarget(targetPos)
    local vTarget = targetPos - agent.pos
    local distToTarget = vTarget:mag()
    if distToTarget > 0 then
      typeDec = typeDec or 'normal'
      local vel = distToTarget/(type(typeDec) == "string" and DecelerationType[typeDec] or typeDec)
      vel = min(vel, agent.maxVel:mag())
      local requiredVel = vTarget * (vel/distToTarget)
      return requiredVel - agent.vel
    end
    return Zero
  end
  
  function SteeringBehaviour.pursuit(agent, runaway)
    runaway = getHunter(runaway)
    local vRunaway = runaway.pos - agent.pos
    local relativeHeading = agent.velHeading:dot(runaway.velHeading or Vec(0,0))
    if vRunaway:dot(agent.velHeading) > 0 and relativeHeading < -0.95 then
      return SteeringBehaviour.seek(agent,runaway.pos)
    end
    local predictTime = vRunaway:mag()/(agent.maxVel:mag()+runaway.vel:mag())
    return SteeringBehaviour.seek(agent,runaway.pos + runaway.vel * predictTime)
  end
  
  function SteeringBehaviour.evade(agent,hunter)
    hunter = getHunter(hunter)
    local vHunter = hunter.pos - agent.pos
    local predictTime = vHunter:mag()/(agent.maxVel:mag() + hunter.vel:mag())    
    return SteeringBehaviour.flee(agent, hunter.pos + hunter.vel * predictTime,100)
  end
  
  function SteeringBehaviour.wander(agent, radius, distance, jitter)
    jitter = jitter or 10
    radius = radius or 100
    distance = distance or 100
    local jitterThisFrame = jitter * agent.dt
    local theta = random() * tau
    local targetPos = Vec(radius * cos(theta), radius * sin(theta))
    targetPos = targetPos + Vec((random()*rSign() * jitterThisFrame),
                                (random()*rSign() * jitterThisFrame))    
    targetPos:normalize()
    targetPos = targetPos * radius
    local targetAtDist = targetPos + Vec(distance,0)
       
    local newTargetPos = l2Abs(targetAtDist, agent.velHeading, agent.velPerp, agent.pos)
    --[[
    print('agentVelH', agent.velHeading)
    print('agentVelPerp', agent.velPerp)
    print('agentpos', agent.pos)
    print('newTargetPos', newTargetPos)
    --io.read()
    --]]
    return newTargetPos - agent.pos
    
  
  end
  
  return SteeringBehaviour
end  