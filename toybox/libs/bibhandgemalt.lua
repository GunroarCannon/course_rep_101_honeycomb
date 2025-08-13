local random = love.math.newRandomGenerator( )
local seeder = love.math.newRandomGenerator( )
local BH={}
function BH.fill(posx, posy,limx,limy,ps,r,m,s,a)
 r=r or BH.style[1]
 m=m or BH.style[2]
 s=s or BH.style[3]
 local en = s<1 and 1 or s
 local ps= ps or {}
 local vx, vy 
 repeat
  if  math.abs(posx-limx)>math.abs(posy-limy) then
  vx= s
  vy=math.abs(posy-limy)/math.abs(posx-limx) *s			
  else
   vx= math.abs(posx-limx)/math.abs(posy-limy) *s				
   vy=s	
  end  
  ps[#ps+1]=posx
  ps[#ps+1]=posy
  posx=(posx<limx and posx+ (random:random(-r,r))*m +vx or (posx>=limx and posx-(random:random(-r,r))*m -vx)) 
  posy=(posy<limy and posy+ (random:random(-r,r))*m +vy or (posy>=limy and posy- (random:random(-r,r))*m-vy) )		
 until math.abs(posx-limx)< en and math.abs(posy-limy)< en
return ps
end
function BH.fill(posx, posy,limx,limy,ps,r,m,s)
 r=r or BH.style[1]
 m=m or BH.style[2]
 s=s or BH.style[3]
 local en = s<1 and 1 or s
 local ps= ps or {}
 local vx, vy 
 repeat
  if math.abs(posx-limx)==math.abs(posy-limy) then
   vx,vy=s,s
  elseif  math.abs(posx-limx)>math.abs(posy-limy) then
   vx= s
   vy=math.abs(posy-limy)/math.abs(posx-limx) *s			
  else
   vx= math.abs(posx-limx)/math.abs(posy-limy) *s	
   vy=s	
  end   
  ps[#ps+1]=posx
  ps[#ps+1]=posy
  posx=(posx<limx and posx+ (random:random(-r,r))*m +vx or (posx>=limx and posx-(random:random(-r,r))*m -vx)) 
  posy=(posy<limy and posy+ (random:random(-r,r))*m +vy or (posy>=limy and posy- (random:random(-r,r))*m-vy) )		
 until math.abs(posx-limx)< en and math.abs(posy-limy)< en
return ps
end
local function BHline(...)
 local p=type(...)=="table" and ... or {...}
 if BH.seed then  
  random:setSeed(BH.seed) 
 else 
  random:setSeed(seeder:random(100000000))
 end 
 if BH.accuracy then
  for c=1,#p-2,2 do
   love.graphics.points(BH.fill(p[c],p[c+1],p[c+2]+ (p[c+2]-p[c])*BH.accuracy,p[c+3]+(p[c+3]-p[c+1])*BH.accuracy ))
  end
 else
  for c=1,#p-2,2 do
   love.graphics.points(BH.fill(p[c],p[c+1],p[c+2],p[c+3]))
  end
 end
end

local function cleanline(...) --this would look dramatically less stupid if graphics.push would allow to select values.
 if BH.color and BH.thickness then 
  local orgcolor= {love.graphics.getColor()}
  local orgsize =love.graphics.getPointSize()
  love.graphics.setColor(BH.color)
  love.graphics.setPointSize( BH.thickness)
  BHline(...)
  love.graphics.setColor(orgcolor)
  love.graphics.setPointSize(orgsize)
 elseif BH.color then
  local orgcolor= {love.graphics.getColor()}
  love.graphics.setColor(BH.color)
  BHline(...)
  love.graphics.setColor(orgcolor)
 elseif BH.thickness then
  local orgsize =love.graphics.getPointSize()
  love.graphics.setPointSize( BH.thickness)
  BHline(...)
  love.graphics.setPointSize(orgsize)
 else
  BHline(...)
 end
end
local oldline=love.graphics.line
local oldcircle=love.graphics.circle
local oldrectangle=love.graphics.rectangle
local oldsetLineWidth=love.graphics.setLineWidth
BH.line=cleanline
BH.circle=function( mode, x, y, radius, segments,sloppy  )
 local lines={}
 segments=segments or (radius/2)
 for i=-2.5,6.284-2.5, (6.283)/ segments   do  
  lines[#lines+1]=math.cos(i)*radius+x
  lines[#lines+1]=math.sin(i)*radius+y
 end
 if mode=="line" or mode=="fill" then cleanline(lines) end
 if mode=="fill" or mode== "inside" then
  if BH.seed then  
   random:setSeed(BH.seed) 
  end 
  local filling={}
  local c=0
  sloppy=sloppy or BH.accuracy and BH.accuracy*radius or 1
  for i=3,#lines/2-2, 2 do
   filling[#filling+1]=lines[#lines-i] + random:random(-sloppy,sloppy)
   filling[#filling+1]=lines[#lines-i+1] + random:random(-sloppy,sloppy)
   filling[#filling+1]=lines[i] + random:random(-sloppy,sloppy)
   filling[#filling+1]=lines[i+1] + random:random(-sloppy,sloppy)
  end
  cleanline(filling)
 end
end
BH.rectangle=function( mode, x, y, width, height, rx, ry, segments )
 if mode=="line" or mode=="fill" then
  cleanline({x,y,x+width,y,x+width,y+height})
  cleanline({x,y,x,y+height,x+width,y+height})
 end	
 if mode=="fill" or mode=="inside" then 
  if BH.seed then  
   random:setSeed(BH.seed) 
  end 
  segments= (width + height)/(segments or 10)
  local edge1={}
  BH.fill(x,y,x+width,y,edge1,1,0,segments)
  BH.fill(x+width,y,x+width,y+height,edge1,1,0,segments)
  local edge2={}
  BH.fill(x,y,x,y+height,edge2,1,0,segments)
  BH.fill(x,y+height,x+width,y+height,edge2,1,0,segments)
  local edge3={}
  local accu=rx or BH.accuracy and BH.accuracy*width or 10
  local accu2= ry  or rx or BH.accuracy and BH.accuracy*height or 10
  for x=3,#edge2,2 do  
   edge3[#edge3+1]=edge2[x] + random:random(-accu,accu)
   edge3[#edge3+1]=edge2[x+1] + random:random(-accu2,accu2)
   edge3[#edge3+1]=edge1[x] + random:random(-accu,accu)
   edge3[#edge3+1]=edge1[x+1] + random:random(-accu2,accu2)   
  end 
  cleanline(edge3)
 end
end
BH.on=function()
 BH.seed=math.random()
 love.graphics.line=cleanline
 love.graphics.rectangle=BH.rectangle
 love.graphics.circle=BH.circle
 love.graphics.setLineWidth=function(i)  BH.thickness=i end
end
BH.off=function()
 love.graphics.line=oldline
 love.graphics.rectangle=oldrectangle
 love.graphics.circle=oldcircle
 love.graphics.setLineWidth=oldsetLineWidth
end

BH.style={}
BH.pens={}
BH.pens.pen={17,.01,.95,t=1.5}
BH.pens.poosmear={200,.0061,.6,c={0.42,0.26,0,.2},t=10}
BH.pens.bloodsplatter={300,.015,.2,c={.91,0,0,0.02},t=15}
BH.pens.waterbrush={40,.005,.1,c={1,0,0,0.01},t=12,a=0.09}
BH.pens.ink={200,.0004,.51,c={0,0,0,0.31},t=4,a=0.07}
BH.pens.lightening={1390,.0005,.4,c={0.55,0.73,0.89},t=1,r=true}
BH.pens.crayon={990,.001,3,c={0.99,0.91,0.12,0.4},t=9}
BH.pens.ballpen={2,.09,.9,c={0.02,0.31,0.97},t=2,a=0.05}
BH.pens.pencil={17,.01,.95,c={0.38,0.39,0.41,.9},t=1.15,a=0.01}
function BH.pen(pentype, keepcolor)
 local pen = BH.pens[pentype] or (type(pentype)=="table") and pentype
 if pen then
  BH.style=pen
  BH.color=not keepcolor and pen.c
  BH.thickness=pen.t  
  if pen.r then BH.seed=nil else  BH.seed=10 end 
  BH.accuracy=pen.a
 else print('Error: pen is not there') end
end
BH.pen("pen")
return BH
