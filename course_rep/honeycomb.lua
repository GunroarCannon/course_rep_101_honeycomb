local Network = req("network")
local json = req("json")

local Honeycomb = {
    _VERSION = "2.0",
    _config = {
        project_id = nil,
        wallet_address = nil,
        api_url = API_URL,--https://edge.test.honeycombprotocol.com",
        offline_mode = false,
        access_token = nil,
        session_token = nil
    },
    _cache = {}
}

-- Simple table merge (replaces vmerge)
local function mergeTables(target, source)
    for k,v in pairs(source) do
        target[k] = v
    end
    return target
end

function Honeycomb.init(config)
    -- Merge configs (simple shallow merge)
    for k,v in pairs(config) do
        Honeycomb._config[k] = v
    end
    
    -- Load local cache if offline
    if Honeycomb._config.offline_mode then
        local ok, data = pcall(json.decode, love.filesystem.read("honeycomb_cache.json") or "{}")
        Honeycomb._cache = ok and data or {}
    end
end

-- Authenticate user and get access token
function Honeycomb.authenticate(callback)
    -- no longer using auth
    Network.request(Honeycomb._config.api_url.."/getAccessToken", {
        method = "POST",
        headers = {
            
            ["Content-Type"] = "application/json",
        },
        data = json.encode({
            wallet = Honeycomb._config.wallet_address,
            project = Honeycomb._config.project_id,
            sessionToken = Honeycomb._config.session_token
        })
    }, 4,function(code, body)
        if code == 200 then
            local data = json.decode(body)
            Honeycomb._config.access_token = data.accessToken
            if callback then callback(true) end
        else
            if callback then callback(false, body) end
        end
    end)
end

-- User Management
function Honeycomb.create_user(info, callback)
    -- not needed for now
    local payload = {
        wallet = Honeycomb._config.wallet_address,
        info = info or {
            name = "Player",
            pfp = "https://default.pfp",
            bio = "Honeycomb gamer"
        },
        payer = Honeycomb._config.wallet_address
    }
    
    Network.request(Honeycomb._config.api_url.."/users", function(code, body)
        callback(code == 200, json.decode(body))
    end, {
        method = "POST",
        headers = {
            ["Authorization"] = "Bearer "..(Honeycomb._config.access_token or ""),
            ["Content-Type"] = "application/json",
        },
        data = json.encode(payload)
    })
end

-- Profile Management
function Honeycomb.create_profile(identity, info, callback)
    local payload = {
        project = Honeycomb._config.project_id,
        identity = identity or "main",
        info = info or {},
        payer = Honeycomb._config.wallet_address
    }
    
    Network.request(Honeycomb._config.api_url.."/profiles", function(code, body)
        callback(code == 200, json.decode(body))
    end, {
        method = "POST",
        headers = {
            ["Authorization"] = "Bearer "..(Honeycomb._config.access_token or ""),
            ["Content-Type"] = "application/json",
        },
        data = json.encode(payload)
    })
end

-- XP and Achievements
function Honeycomb.add_xp(amount, callback)
    callback = callback or null
    Network.request(Honeycomb._config.api_url.."/xp", function(code, body)
        callback(code == 200, json.decode(body))
    end, {
        method = "POST",
        headers = {
            ["Authorization"] = "Bearer "..(Honeycomb._config.access_token or ""),
            ["Content-Type"] = "application/json",
        },
        data = json.encode({
            amount = amount,
            wallet = Honeycomb._config.wallet_address,
            project = Honeycomb._config.project_id
        })
    })
end

function Honeycomb.add_achievement(achievement_id, callback)
    Network.request(Honeycomb._config.api_url.."/achievements", function(code, body)
        callback(code == 200, json.decode(body))
    end, {
        method = "POST",
        headers = {
            ["Authorization"] = "Bearer "..(Honeycomb._config.access_token or ""),
            ["Content-Type"] = "application/json",
        },
        data = json.encode({
            achievement = achievement_id,
            wallet = Honeycomb._config.wallet_address,
            project = Honeycomb._config.project_id
        })
    })
end

-- Custom Data Storage
function Honeycomb.set_profile_data(key, value, callback)
    
    assert(type(key) == "string", "Key must be string")
    assert(value ~= nil, "Value cannot be nil")
    assert(Honeycomb._config.wallet_address, "Wallet address not configured")
    assert(Honeycomb._config.project_id, "Project ID not configured")

    local payload = {
        wallet = Honeycomb._config.wallet_address,
        project = Honeycomb._config.project_id,
        key = key,
        value = value,
        sessionToken = Honeycomb._config.session_token
    }
    
    if Honeycomb._config.offline_mode then
        Honeycomb._cache[key] = value
        love.filesystem.write("honeycomb_cache.json", json.encode(Honeycomb._cache))
        if callback then callback(true, {success = true}) end
        return
    end
    
    Network.request(Honeycomb._config.api_url.."/data", {
        method = "POST",
        headers = {
            ["Content-Type"] = "application/json",
            ["Authorization"] = "Bearer "..(Honeycomb._config.access_token or "")
        },
        data = json.encode(payload)
    },4, function(code, body)
         game.status = json.encode(payload)..code..";"..tostring(body) 
    -- error(game.status)
        if callback then callback(code == 200, json.decode(body)) end
    end)
end

function Honeycomb.get_profile_data(key, callback)
    if Honeycomb._config.offline_mode then
        callback(true, {value = Honeycomb._cache[key]})
        return
    end
    
    Network.request(Honeycomb._config.api_url.."/data/"..key.."?wallet="..Honeycomb._config.wallet_address.."&project="..Honeycomb._config.project_id, 
    function(code, body)
        callback(code == 200, json.decode(body))
    end)
end

return Honeycomb