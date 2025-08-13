local order = {
    {"w","x"},
    {"M","N","O"},
    {"D","T","j","z"},
    {"A","E","I","M","Q","U","Y","c","g","k"}
}

files = {}

count = 0
for k,a in pairs(order[1]) do
        for k,b in pairs(order[2]) do
            for k,c in pairs(order[3]) do
                for k,d in pairs(order[4]) do
                    files[a..b..c..d] = count
                    count = count+1
                end
            end
        end
end


local path = ""
local fs   = love.filesystem

local function rename(manga)

    
    for k,a in pairs(order[1]) do
        for k,b in pairs(order[2]) do
            for k,c in pairs(order[3]) do
                for k,d in pairs(order[4]) do
                    local name = a..b..c..d
                    local realName = "j"
                    assert(fs.isDirectory(manga),manga)
                    
                    for k,x in ipairs(fs.getDirectoryItems(manga)) do
                        
                        if x:sub(-9,-6)==name then
                            realName = x
                            
                            break
                        end
                      --  error(x:sub(-9,-6)..","..name)
                        
                        
                    end
                    
                    if name ~= "wMDA" then --doesn't exist
                        _file = manga.."/"..realName
                        if not fs.isFile(_file) then
                           -- error(_file.." non as "..name)
                        else
                            local f = love.filesystem.newFile(_file,"r")
                            f:open("r")
                            local ffr = f:read()
                            local n = fs.newFile (manga.."/"..tostring(files[name])..".jpg","w")
                            n:open("w")
                            n:write(ffr)
                            n:close()
                            f:close()
                            fs.remove(_file)
                        end
                    end
                end
            end
        end
    end

    print("\n\nDONE")
end
                    
local function rename_chapter(manga,chapter)
    mang = path..manga.."/"..tostring(chapter)
    rename(mang)
end

local function rename_chapters(manga, ch1, ch2)
    for x = ch1, ch2 do
        rename_chapter(manga,x)
    end
end

for x, i in ipairs({22.5,25.1,25.5,25.6}) do
    rename_chapter("Demon Slayer", i)
end
---rename_chapters("Demon Slayer",17,25)
error("Done")