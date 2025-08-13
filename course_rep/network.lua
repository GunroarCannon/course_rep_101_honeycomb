-- network.lua
local Network = {
    requests = {},
    nextId = 0
}

function Network.request(url, body, timeout, callback)
    if type(body) == "function" then
        local b = callback
        callback = body
        body, timeout = timeout, b
    end


    

    local requestId = Network.nextId
    Network.nextId = Network.nextId + 1
    
    local threadCode = [[
        local url, body, timeout = ...
        local https = require("https")
        
        -- Main request
        local code, response = https.request(url,body)
        
        -- Return results
        love.thread.getChannel("network_response"):push({
            requestId = ]]..requestId..[[,
            code = code,
            response = response,
            url = url
        })
    ]]
    
    local thread = love.thread.newThread(threadCode)
    thread:start(url, body, timeout or 5)
    
    Network.requests[requestId] = {
        thread = thread,
        callback = callback,
        timeout = timeout or 5,
        startTime = love.timer.getTime()
    }
end
https = require "https"
function Network.update()
   --  local code, body = https.request("http://cards-of-loop-honeycome-server.onrender.com/health")
    --print("HTTP Check:", code, body and string.sub(body, 1, 100) or "no body")
    -- Check for responses first
    local response = love.thread.getChannel("network_response"):pop()
    if response then
        local request = Network.requests[response.requestId]
        if request and request.callback then
            request.callback(response.code, response.response, response)
        end
        
        Network.requests[response.requestId] = nil
    end
    
    -- Handle timeouts
    local currentTime = love.timer.getTime()
    for id, request in pairs(Network.requests) do
        if currentTime - request.startTime > request.timeout then
            if request.callback then
                request.callback(0, "Request timeout",response)
            end
            request.thread:release()
            if game and game.status then game.status="timout" end
            Network.requests[id] = nil
        end
    end
end

return Network