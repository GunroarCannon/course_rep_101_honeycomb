WalletMenu = toybox.Room("WalletMenu")
Honeycomb = req "honeycomb"
Network = req "network"

function WalletMenu:setup()
    self:activate_gooi()
    
    -- Background similar to other menus
    self.cover_alpha = 1
    self:tweenCoverAlpha(.3, 0)
    
    -- Title
    local title = gooi.newLabel({
        text = "CONNECT WALLET",
        font = mario_font30,
        x = W()/2 - 200,
        y = H()/4 - 50,
        w = 400,
        h = 100
    }):center()
    
    -- Status text
    self.statusLabel = gooi.newLabel({
        text = "Press the button below to connect",
        font = mario_font15,
        x = W()/2 - 250,
        y = H()/2 - 30,
        w = 500,
        h = 60
    }):center()
    
    -- Connect button
    local connectBtn = gooi.newButton({
        text = "CONNECT",
        font = mario_font25,
        x = W()/2 - 100,
        y = H()/2 + 50,
        w = 200,
        h = 80
    })
    connectBtn.borderWidth = 10
    connectBtn.bgColor = colors.darklime
    
    -- Back button
    local backBtn = gooi.newButton({
        text = "BACK",
        font = mario_font20,
        x = W()/2 - 80,
        y = H() - 100,
        w = 160,
        h = 60
    })
    backBtn.borderWidth = 7
    backBtn.bgColor = colors.darkdarklime
    
    -- Button actions
    connectBtn:onRelease(function()
        self:connectWallet()
        playGooiSound("click")
    end)
    
    backBtn:onRelease(function()
        playGooiSound("click")
        self:tweenCoverAlpha(.4, 1, "out-quad", function()
            game:set_room(Menu)
        end)
    end)
    
    -- Animation
    title.y = -200
    self.statusLabel.alpha = 0
    connectBtn.y = H() + 100
    backBtn.y = H() + 100
    
    self:tween(.7, title, {y = H()/4 - 50}, "out-bounce")
    self:tween(.7, self.statusLabel, {alpha = 1}, "in-quad")
    self:tween(.7, connectBtn, {y = H()/2 + 50}, "out-bounce")
    self:tween(.7, backBtn, {y = H() - 100}, "out-bounce")
    
    -- Initialize session
    self.sessionToken = "game_" .. os.time()
    Honeycomb.init({
        project_id = "BkF2wCJirExrRYva4YcHMHqdnrZJENWbZkN1o84ZQHa8",
        api_url = API_URL,
        session_token = self.sessionToken
    })
end

function WalletMenu:connectWallet()
    self.statusLabel:setText("Opening wallet connector...")
    love.system.openURL("https://courserep-101-wallet-frontend.onrender.com/?session=" .. self.sessionToken)
    
    self.checkTimer = 0
    self.connectionAttempts = 0
    self.maxAttempts = 20  -- ~30 seconds total
    
    self:every(0.1, function(dt)
        dt = dt or 0.1
        self.checkTimer = self.checkTimer + dt
        if self.checkTimer >= 1.5 then
            self:checkConnection()
            self.checkTimer = 0
        end
    end)
end

function WalletMenu:checkConnection()
    self.connectionAttempts = self.connectionAttempts + 1
    
    if self.connectionAttempts > self.maxAttempts then
        self.statusLabel:setText("Connection timed out")
        self.timer:cancel(self.checkTimer)
        return
    end
    
    self.statusLabel:setText("Checking connection ("..self.connectionAttempts.."/"..self.maxAttempts..")")
    
    Network.request(
        string.format("%s/check-session?token=%s", API_URL, self.sessionToken),
        nil, 4,
        function(code, body)
            if code == 200 then
                local data = json.decode(body)
                if data.walletAddress and not game.walletAddress then
                    -- Wallet connected!
                    self.timer:cancel(self.checkTimer)
                    game.walletAddress = data.walletAddress
                    Honeycomb._config.wallet_address = data.walletAddress
                    
                    self.statusLabel:setText("Connected: "..string.sub(data.walletAddress, 1, 8).."...")
                    self:initializeHoneycomb()
                end
            end
        end
    )
end

function WalletMenu:initializeHoneycomb()
    self.statusLabel:setText("Authenticating...")
    
    Honeycomb.authenticate(function(authSuccess)
        if authSuccess then
            self.statusLabel:setText("Creating profile...")
            
            Honeycomb.create_profile("main", {}, function(profileOk)
                if profileOk then
                    self.statusLabel:setText("Wallet connected successfully!")
                    
                    -- Save wallet address to game data
                    gdata.walletAddress = game.walletAddress
                    game:saveData()
                    
                    -- Return to menu after delay
                    self:after(2, function()
                        self:tweenCoverAlpha(.4, 1, "out-quad", function()
                            game:set_room(Menu)
                        end)
                    end)
                else
                    self.statusLabel:setText("Failed to create profile")
                end
            end)
        else
            self.statusLabel:setText("Authentication failed")
        end
    end)
end

function WalletMenu:draw_before_gooi(dt)
    -- Same background as other menus
    local HH = H()*2
    self.rr = (self.rr or 0) + dt
    local r,g,b,a = set_color(.9, .9, .9)
    draw_rect("fill", -W(), -H()*.5, W()*4, H()*3+10)
    
    set_color(.1, .1, .8)
    local n = 30
    for x = 1, HH/n do
        lg.line(-W(), -H()*.5+(H()/n)*x, W()*4, -H()*.5+(H()/n)*x)
    end
    
    set_color(.9, .2, .1)
    lg.line(50, -H()*.5, 50, H()*4)
    
    set_color(r,g,b,a)
end

function WalletMenu:draw()
    -- Draw any additional elements if needed
end

function tryToInitializeWallet()
    if gdata.walletAddress then
        game.walletAddress = gdata.walletAddress
    
        Honeycomb.init({
            project_id = "BkF2wCJirExrRYva4YcHMHqdnrZJENWbZkN1o84ZQHa8",
            api_url = API_URL, 
            session_token = gdata.sessionToken,
            wallet_address = gdata.walletAddress or nil
        })
    end
end


function Menu2:showWalletConnect()
    if self.egP then return end
    
    playGooiSound("paper_tear")
    self:squash_ui(self.walletBtn)
    
    local ew, eh = W()*.9, H()*.5
    local egP = gooi.newPanel({
        x = W()/2-ew/2,
        y = H()/2-eh/2,
        w = ew, h = eh,
        padding = 15,
        layout = "grid 5x3"
    }):setRowspan(1,1,5):setColspan(1,1,3)
    self.egP = egP
    
    egP.dalpha = 0
    self:tween(1, egP, {dalpha=.7}, "in-quad")
    egP.preDraw = function()
        local r,g,b,a = set_color(0,0,0,egP.dalpha)
        draw_rect("fill",-W(),-H(),W()*4,H()*4)
        set_color(r,g,b,a)
    end
    
    -- Use same panel image as energy
    local img = egP:addImage("energyPanel.png")
    egP.onlyImage = true
    egP.showBorder = false
    
    egP.ogy = egP.y
    egP.y = -eh-100
    egP.opaque = true
    
    -- Title
    local title = gooi.newLabel({
        text = "CONNECT WALLET",
        font = mario_font25,
        instant = true
    })
    title.yOffset = 10
    egP:add(title)
    
    -- Status text
    self.walletStatus = gooi.newLabel({
        text = gdata.walletAddress and string.format("%s... \n WALLET CONNECTED.", gdata.walletAddress:sub(1, 5)) or "Press CONNECT to link your wallet",
        font = mario_font18,
        instant = true
    })
    self.walletStatus.yOffset = 20
    egP:setColspan(3,1,3)
    egP:add(self.walletStatus,3,1)
    
    -- Connect button
    local connectBtn = gooi.newButton({
        text = gdata.walletAddress and "DISCONNECT" or "CONNECT",
        font = mario_font17
    })
    connectBtn.bgColor = colors.darklime
    connectBtn.borderWidth = 10
    egP:add(connectBtn,5,2)
    
    local function remove()
        gooi.removeComponent(egP)
        self.egP = nil
        gooi.removeComponent(b2)
    end
    
    local function cancel(n)
        playGooiSound()
        local func = "out-quad"
        self:tween_out_ui(egP, .5, func)
        self:tween(.5, b2, {fgColor={0,0,0,0}, y=egP.outy}, func, remove)
    end
    
    self.egP.cancel = cancel
    
    -- Close button
    b2 = gooi.newLabel({
        text="X", 
        x=egP.x-10, 
        y=egP.ogy-5, 
        w=100, 
        h=100, 
        font=mario_font20
    }):onRelease(cancel)
    b2.fgColor = {0,0,0,0}
    self:tween(.6, b2.fgColor, {0,0,0,1}, "in-quad")
    
    egP.b2 = b2
    
    egP.outy = egP.y
    self:tween_in_ui(egP, .5, "in-bounce")
    
    local function refreshPanel()
        egP:refresh()
    end
    self:after(.5+.1, refreshPanel)
    
    -- Wallet connection logic
    local function connectWallet()
        if gdata.walletAddress then
            gdata.walletAddress = nil
            game.walletAddress = nil
            gdata.sessionToken = nil

            cancel()

            return
        end

        self.walletStatus:setText("Opening wallet connector...")
        self.sessionToken = "game_" .. os.time()
        
        gdata.sessionToken = self.sessionToken

        Honeycomb.init({
            project_id = "BkF2wCJirExrRYva4YcHMHqdnrZJENWbZkN1o84ZQHa8",
            api_url = API_URL, 
            session_token = self.sessionToken,

            -- wallet_address = gdata.walletAddress or nil
        })
        
        love.system.openURL("https://courserep-101-wallet-frontend.onrender.com/?session=" .. self.sessionToken)
        connectBtn.enabled = false
        
        local attempts = 0
        local maxAttempts = 20
        
        local function checkConnection()
            if game.walletAddress then
                return
            end
            
            attempts = attempts + 1
            self.walletStatus:setText("Checking connection ("..attempts.."/"..maxAttempts..")")
            
            if attempts > maxAttempts then
                self.walletStatus:setText("Connection timed out")
                connectBtn.enabled = true
                return
            end
            
            Network.request(
                string.format("%s/check-session?token=%s", API_URL, self.sessionToken),
                nil, 1.2,
                function(code, body)
                    if code == 200 then
                        local data = json.decode(body)
                        if data.walletAddress and not game.walletAddress then

                            -- Successfully connected
                            gdata.walletAddress = data.walletAddress

                            game.walletAddress = data.walletAddress
                            Honeycomb._config.wallet_address = data.walletAddress
                            
                            self.walletStatus:setText("Connected: "..string.sub(data.walletAddress,1,8).."...")
                            connectBtn.enabled = false
                            
                            -- Initialize Honeycomb
                            Honeycomb.authenticate(function(authSuccess)
                                if authSuccess then
                                    Honeycomb.create_profile("main", {}, function(profileOk)
                                        if profileOk then
                                            self.walletStatus:setText("Wallet connected successfully!")
                                            gdata.walletAddress = game.walletAddress
                                            game:saveData()
                                        end
                                    end)
                                end
                            end)
                        end
                    end
                end
            )
            
            if attempts < maxAttempts then
                self:after(1.5, checkConnection)
            end
        end
        
        checkConnection()
    end
    
    connectBtn:onRelease(connectWallet)
end