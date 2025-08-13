return function(grid)

--grid is a table with w, h[, startX, startY] properties

grid.tiles = grid.tiles or {}
grid.allTiles = grid.allTiles or {}
grid.grid = grid.tiles

grid.minTileX = nil
grid.minTileY = nil
grid.maxTileX = nil
grid.maxTileY = nil

function grid:storeTile(tile)
    
    tile._x = tile._x or tile.x/tile.w
    tile._y = tile._y or tile.y/tile.h
    
    local x, y = tile._x, tile._y
    
    if not self.minTileX or x<self.minTileX then
        self.minTileX = x
    end
    
    if not self.minTileY or y<self.minTileY then
        self.minTileY = y
    end
    
    if not self.maxTileY or y>self.maxTileY then
        self.maxTileY = y
    end
    
    if not self.maxTileX or x>self.maxTileX then
        self.maxTileX = x
    end
   -- assert(not tile.__added, "Tile already added at position "..tile._x..","..tile._y)
    
    self.grid[tile._x] = self.grid[tile._x] or {}
    local t = self.grid[tile._x][tile._y]
    
    --assert(not t, "Tile exists in position "..tile._x..","..tile._y)
    
    self.grid[tile._x][tile._y] = tile
    
    self.allTiles[#self.allTiles+1] = tile
    tile.__added = true
    
    return tile
end
    
function grid:getTileP(x, y)
    local w = self.allTiles[1]
    
    w = w and w.w or tw or tile_w or tilew or Tile and Tile.w or 25
    
    -- This works only if tile pos (in table) is related to it's real position
    local x = math.floor(x/w)+1
    local y = math.floor(y/w)+1
    return w and self:getTile(x, y)
end

function grid:getTile(x,y,safe)
    local tile = self.grid[x] and self.grid[x][y]
    
    if not tile and ((self.safeGetTile and safe ~= false) or safe) then
        return {isBackground = true}
    end
    
    return tile
end

function grid:getAllTiles()
    return self.allTiles
end

grid.getSpaceTiles = toybox.getSpaceTiles or function(self)
    local t = {}
    for x = 1, #self.allTiles do
        local tile = self.allTiles[x]
        if (tile.isFreeSpace and tile:isFreeSpace()) or not (tile.isSolid and tile:isSolid() or tile.solid) then
            t[#t+1] = tile
        end
    end
    return t
end

function grid:getSolidTiles()
    local t = {}
    for x = 1, #self.allTiles do
        local tile = self.allTiles[x]
        if (tile.isSolid and tile:isSolid() or tile.solid) then
            t[#t+1] = tile
        end
    end
    return t
end

function grid:getCorners()
    local ctopl, ctopr, cbottoml, cbottomr
    
    
    for x = (self.startX or 1), ((self.startX or 0) + self.w) do
        local tile
        for y = (self.startY or 1), ((self.startY or 0) + self.h) do
            tile = self:getTile(x,y)
            
            if not tile or not tile.isBackground then
                tile = nil
            end
            
            if not ctopl then
                ctopl = tile
            end
            ctopr = tile
        end
        if not cbottoml then
            cbottoml = tile
        end
        cbottomr = tile
    end
    
    return {ctopl, ctopr, cbottoml, cbottomr}
end

function grid:getRandomSpaceTile()
    return lume.randomchoice(self:getSpaceTiles())
end

function grid:getRandomWallTile()
    return lume.randomchoice(self:getSolidTiles())
end

function grid:getRandomSolidTile()
    return lume.randomchoice(self:getSolidTiles())
end

function grid:getRandomTile()
    return lume.randomchoice(self:getAllTiles())
end

function grid:isWallCorner(tile)
    return self:isCorner(tile) and (tile.isSolid and tile:isSolid() or tile.solid)    
end

function grid:isSpaceCorner(tile)
    return self:isCorner(tile) and not (tile.isSolid and tile:isSolid() or tile.solid)
end

function grid:isCorner(tile)
    return true or (tile._x == self.minTileX or tile._x == self.maxTileX) and
           (tile._y == self.minTileY or tile._y == self.maxTileY)
end


function grid:getPosition(position, notHave, room)
    local tile
    local count = 0
    local found = false
    
    room = room or self
    
    if notHave and notHave.allTiles then
        local old = notHave
        notHave = room
        room = notHave
    end
    
    local aTiles = lume.copy(room.allTiles)
    if not aTiles then
        error("No tiles in room\n...!"..inspect(room, 2))
    end
    
    while not tile and count < 100 do
        tile = self:checkIsPosition(position, lume.eliminate(aTiles), notHave)
        if position == "center" then
            break
        end
        
        count = count + 1
        
        if #aTiles == 0 then
            return
        end
    end
    
    return tile
end

local function checkFree(i)
    return i.solid
end

local function isFree(tile)
    if  tile and (not (tile.isSolid and tile:isSolid() or tile.solid)) and (not tile.isEntrance) and tile.room and tile.room.world then
        local items, len = tile.room.world:queryRect(tile.x, tile.y, tile.w, tile.h, checkFree)
        if len > 0 then
            return
        end
    end
    return tile and ((tile.isFreeSpace and tile:isFreeSpace()) or not (tile.isSolid and tile:isSolid() or tile.solid)) and (not tile.isEntrance)
end

local function isReallyFree(tile)
    local self = self or tile.parent or tile.room
    return isFree(tile) and
                    (isFree(self:getTile(tile._x, tile._y+1))) and
                    (isFree(self:getTile(tile._x, tile._y-1))) and
                    (isFree(self:getTile(tile._x+1, tile._y))) and
                    (isFree(self:getTile(tile._x-1, tile._y))) and
                    (isFree(self:getTile(tile._x+1, tile._y+1))) and
                    (isFree(self:getTile(tile._x-1, tile._y-1))) and
                    (isFree(self:getTile(tile._x+1, tile._y-1))) and
                    (isFree(self:getTile(tile._x-1, tile._y+1))) or true
end

--Positions:
----room       : anywhere in a room
----wall       : any wall in the room
----space      : any "empty" space in the room
----spaceCorner: any empty space in room that has a wall next to it and below it (corner)
----corner     : any spaceCorner
----wallCorner : any wall corner in the room
----floor      : any empty tile in room with a solid tile below it
----floorWall  : any wall tile with an empty tile above it
----underFloor : any wall tile in room with an empty tile above a wall tile above it and a wall tile below it
----roofSpace  : any empty space that has a wall ontop of it
----roof       : any wall tile with an empty tile beneath it
----sideWall   : any wall on the sides of a room
----insideWall : any wall inside a wall, note
----insideRoof : any wall tile inside the roof (top of room)
----free       : space not next to wall or entrance
----center     : center of room
function grid:checkIsPosition(position, tile, notHave)
    local position = getValue(position)
    
    if 1 then
        local tile = tile or self:getRandomTile()
        local found = false
        local continue = true
        
        if notHave then
            if type(notHave) ~= "table" then
                if tile[notHave] then
                    found = false
                    continue = false
                end
            else
                for x, i in ipairs(notHave) do
                    if tile[notHave] then
                        found = false
                        continue = false
                        break
                    end
                end
            end
        end
        
        if tile.isTunnel then
            continue = false
            found = false
        end
        
        if not continue then
            
        elseif position == "room" then
            found = true
            
        elseif position == "entrance" then
            found = tile.isEntrance
        
        elseif tile.isEntrance then
            found = false
        
        elseif position == "center" then
            local ww = tile.parent and tile.parent.w or tile.room and tile.room.w
            local h = tile.parent and tile.parent.h or tile.room and tile.room.h
            local x = tile.parent and tile.parent.x or tile.room and tile.room.x
            local y = tile.parent and tile.parent.y or tile.room and tile.room.y
            
            w = math.floor((ww)/2)
            h = math.floor((h)/2)
            --error(ww..","..h)
            local mid = self:getTile(x/tile.w+w,y/tile.h+h)
            local ttile
            found = false
            
            log("center "..w..","..h)
            for i = 0, lume.max(w, h) do
                for num = 1, i<1 and 1 or 2 do
                    local yy = num == 1 and i or -i
                    for xnum = 1, i<1 and 1 or 2 do
                        local xx = xnum == 1 and i or -i log(xx..","..yy.." :x,y")
                        ttile = self:getTile(mid._x+xx, mid._y+yy)
                        if isFree(ttile, self) then   ttile.color = getColor("green")
                        tile=ttile found = true
                            break
                        end
                    end
                    if found then
                        break
                    end
                end
                if found then
                    break
                end
            end
            if not found then
            
            for i = 0, lume.max(w, h) do
                for num = 1, i<1 and 1 or 2 do
                    local yy = num == 1 and i or -i
                    for xnum = 1, i<1 and 1 or 2 do
                        local xx = xnum == 1 and i or -i log(xx..","..yy.." :x,y2")
                        ttile = self:getTile(mid._x+xx, mid._y+yy)
                        if (tile.isSolid and tile:isSolid() or tile.solid) == false then   ttile.color = getColor("green")
                        tile=ttile found = true
                            break
                        end
                    end
                    if found then
                        break
                    end
                end
                if found then
                    break
                end
            end
            end
            if not found then tile = self:getRandomSpaceTile() found=true end
            assert(found,w..","..h)
            --[[for yy = 0, h*2 do
                local yp = yy > h and -yy or yy
                for xx = 0, w*2 do
                local xp = xx > w and -xx or xx
                    ttile = self:getTile(mid._x+xp, mid._y+yp)
                    if isFree(ttile, self) then   ttile.color = getColor("green")
                        tile = ttile
                        found = true
                        break
                    end
                end
                if found then
                    break
                end
            end]]
            
        elseif position == "free" then
            found = (tile.isBackground) and
                    (isFree(self:getTile(tile._x, tile._y+1))) and
                    (isFree(self:getTile(tile._x, tile._y-1))) and
                    (isFree(self:getTile(tile._x+1, tile._y))) and
                    (isFree(self:getTile(tile._x-1, tile._y)))
            
        elseif position == "sideWall" then
            found = (not tile.isBackground) and
                    (
                        (not self:getTile(tile._x, tile._y+1).isBackground) or
                        self:getTile(tile._x, tile._y+1).unit
                    ) and
                    (
                        (
                            self:getTile(tile._x+1, tile._y).isBackground and
                            (not self:getTile(tile._x-1, tile._y).isBackground)
                        ) or
                        (
                            self:getTile(tile._x-1, tile._y).isBackground and
                            (not self:getTile(tile._x+1, tile._y).isBackground)
                        )
                    )
                    
        elseif position == "insideWall" then
            if tile.isBackground then
                found = false
            else
                local tt = 
                    (
                        self:getTile(tile._x-1, tile._y).isBackground and
                        (not self:getTile(tile._x+1, tile._y).isBackground) and
                        self:getTile(tile._x+1, tile._y)
                    ) or
                    (
                        self:getTile(tile._x+1, tile._y).isBackground and
                        (not self:getTile(tile._x-1, tile._y).isBackground) and
                        self:getTile(tile._x-1, tile._y)
                    ) or
                    (
                        self:getTile(tile._x, tile._y-1).isBackground and
                        (not self:getTile(tile._x, tile._y+1).isBackground) and
                        self:getTile(tile._x, tile._y+1)
                    ) or
                    (
                        self:getTile(tile._x, tile._y+1).isBackground and
                        (not self:getTile(tile._x, tile._y-1).isBackground) and
                        self:getTile(tile._x, tile._y-1)
                    )
                    
                    if tt then
                        tile = tt
                    else
                        found = false
                    end
            end
            
            found = (not tile.isBackground) and
                    (
                        (not self:getTile(tile._x, tile._y+1).isBackground) or
                        self:getTile(tile._x, tile._y+1).unit
                    ) and
                    (
                        (not self:getTile(tile._x, tile._y-1).isBackground) or
                        self:getTile(tile._x, tile._y-1).unit
                    ) and
                    (
                        (not self:getTile(tile._x+1, tile._y).isBackground) or
                        self:getTile(tile._x+1, tile._y).unit
                    ) and
                    (
                        (not self:getTile(tile._x-1, tile._y).isBackground) or
                        self:getTile(tile._x-1, tile._y).unit
                    )
        elseif position == "insideRoof" then
            if tile.isBackground then
                found = false
            else
                local tt = 
                    (
                        self:getTile(tile._x, tile._y+1).isBackground and
                        (not self:getTile(tile._x, tile._y-1).isBackground) and
                        self:getTile(tile._x, tile._y-1)
                    )
                    
                    if tt then
                        tile = tt
                        
                    else
                        found = false
                    end
            end
            
            found = (not tile.isBackground) and
                    (
                        (not self:getTile(tile._x, tile._y+1).isBackground) or
                        self:getTile(tile._x, tile._y+1).unit
                    )
        
        elseif position == "wall" then
            found = not tile.isBackground
        elseif position == "space" then
            found = tile.isBackground
        elseif position == "spaceCorner" or position == "corner" then
            found = self:isSpaceCorner(tile)
        elseif position == "wallCorner" then
            found = self:isWallCorner(tile)
        elseif position == "floor" then
            found = (tile.isBackground) and tile.type=="floor" and
                    (not self:getTile(tile._x, tile._y+1).isBackground) and
                    (self:getTile(tile._x, tile._y+1).type == "wall")
        elseif position == "roofSpace" then
            found = (tile.isBackground) and
                    (not self:getTile(tile._x, tile._y-1).isBackground)
        elseif position == "roof" then
            found = (not tile.isBackground) and
                    (self:getTile(tile._x, tile._y+1).isBackground)
        elseif position == "floorWall" then
            found = (not tile.isBackground) and
                    self:getTile(tile._x, tile._y-1).isBackground
        elseif position == "underFloor" then
            found = (not tile.isBackground) and
                    self:getTile(tile._x, tile._y-1).isBackground and
                    not self:getTile(tile._x, tile._y+2).isBackground
            if found then
                tile = self:getTile(tile._x, tile._y+1)
            end
        end
                
        if continue and not found and (position == "spaceCorner" or position == "corner") then
            found = self:isSpaceCorner(tile)
        end
        
        
        return found and tile
    end
end


return grid

end