--[[StartXML
<Defaults>
  <Button onClick="onClick" fontSize="80" fontStyle="Bold" textColor="#FFFFFF" color="#000000F0"/>
  <Text fontSize="80" fontStyle="Bold" color="#FFFFFF"/>
  <InputField fontSize="70" color="#000000F0" textColor="#FFFFFF" characterValidation="Integer"/>
</Defaults>
<Panel id="panel" position="0 54 -15" rotation="180 180 0" active="True" visibility="" scale="0.1 0.1">
<VerticalLayout    height="280" width="600" >
<HorizontalLayout position="0 0 -100">
  <Button id="takeItem1" fontSize="45" text="Take"  color="#000000F0"></Button>
</HorizontalLayout>
<HorizontalLayout position="0 0 -100">
  <Button id="StartRoll" fontSize="45" text="Twist"  color="#000000F0"></Button>
</HorizontalLayout>
<HorizontalLayout position="0 0 -100">
  <Button id="test" fontSize="45" text="Remove"  color="#000000F0"></Button>
</HorizontalLayout>
</VerticalLayout>
</Panel>
StopXML--xml]]
rouletteWheelGUID = '8dd151'
rouletteWheel = nil
Wait.time(function() findBag() end, 1, -1)
function onload ()
      PRoll =
      {
        url="http://cloud-3.steamusercontent.com/ugc/780747252121748044/5EC7D41AEE57CA90BDF4F6C49142EB0A00A1CE11/",
        title="Roll"
      }
      PWin =
      {
        url="http://cloud-3.steamusercontent.com/ugc/780747252121735913/FCCEB8C58BC64FAD4C0610581BB8E910ED159B9A/",
        title="RollWin"
      }
    local script = self.getLuaScript()
    local xml = script:sub(script:find("StartXML")+8, script:find("StopXML")-1)
    self.UI.setXml(xml)
    rouletteWheel = getObjectFromGUID(rouletteWheelGUID)
end
spinning = false
startTime = 0
spinTime = 11
pos2x = 6.5
function onClick(player, value, id)
    if id == "StartRoll" then
        MusicPlayer.setCurrentAudioclip(PRoll)
        MusicPlayer.play()
        Wait.time(function() Start ()  end, 0.3, 0)
    end
    if id == "takeItem1" then
        takeItem()
    end
    if id == "test" then
        win()
    end
end
function Start ()
    if spinning == false then
        self.UI.setAttribute("panel", "active", false)
        startTime = os.clock()
        startLuaCoroutine(self, 'SpinCoroutine')
    end
end

function SpinCoroutine ()
    spinning = true
    timeDiff = os.clock() - startTime
    test = math.random(30,100)
    prevClock = os.clock()

    while timeDiff < spinTime do
        timeDelta = os.clock() - prevClock --make spinning frame independent by getting delta
        prevClock = os.clock()
        spinSpeed = (spinTime - timeDiff) * timeDelta * test

        currentRot = rouletteWheel.getRotation()
        currentRot['x'] = 0
        currentRot['y'] = currentRot['y'] + spinSpeed
        currentRot['z'] = 0
        rouletteWheel.setRotation(currentRot)
        coroutine.yield(0) --wait one frame
        timeDiff = os.clock() - startTime
    end

    spinning = false
    self.UI.setAttribute("panel", "active", true)
    tester = self.getRotation()
    win()
    MusicPlayer.setCurrentAudioclip(PWin)
    MusicPlayer.play()
    return 1
end

function findBag()
  local itemsInBowl = findBagInSphere()
   for _, entry in ipairs(itemsInBowl) do
       if entry.hit_object ~= self and entry.hit_object.tag == "Bag" then
           tableEntry = entry.hit_object.getGUID()
            ibag = getObjectFromGUID(tableEntry)
            --self.UI.setAttribute("panel", "active", true)
          else
            --self.UI.setAttribute("panel", "active", false)
       end
   end
end

function table.map(func, array)
    local new_array = {}
    for i,v in ipairs(array) do
        new_array[i] = func(v)
    end
    return new_array
end

function table.min(func, array)
    local val = array[1]
    local min = func(val)
    local x = min
    for k, v in ipairs(array) do -- TODO: optimize
        x = func(v)
        if x < min then
            val, min = v, x
        end
    end
    return val
end

function table.slice(tbl, first, last, step)
    local sliced = {}
    for i = first or 1, last or #tbl, step or 1 do
        sliced[#sliced+1] = tbl[i]
    end
    return sliced
end
function table.findIndex(func, xs)
    for k, v in ipairs(xs) do
        if func(v) then
            return k
        end
    end
    return nil
end

function table.append(t1, t2)
    for i=1, #t2 do
        t1[#t1+1] = t2[i]
    end
    return t1
end

cards = {}
function win ()
    local pos = self.getPosition()
    local r = self.getBounds().size[1] / 2.

    local alphaGrad = self.getRotation()["y"]

    local alpha = math.pi * alphaGrad / 180.

    local p = { r * math.sin(alpha) + pos["x"], pos["y"], r * math.cos(alpha) + pos["z"] }


    local closest =
        table.min(function(x)
            function length (x, y)
                -- function length ({x1, y1, z1}, {x2, y2, z2})
                    return math.sqrt((y[1] - x[1])^2 + (y[2] - x[2])^2 + (y[3] - x[3])^2)
                    -- return math.sqrt((x2 - x1)^2 + (y2 - y1)^2 + (z2 - z1)^2)
                end
            return length(p, x.getPosition())
        end, cards)

    function blink (closest)
        local color = closest.getColorTint()
        closest.setColorTint({r=1, g=0, b=0})
        Wait.time(function () closest.setColorTint(color) end, 0.3)
    end

    local i = table.findIndex(function(x) return x == closest end, cards)
    local ys = table.append(table.slice(cards, i), table.slice(cards, 1, i - 1))

    function f (i)
        if i <= #ys then
            Wait.time(function ()
                --blink(ys[i])
                ys[i].destruct()
                f(i+1)
            end, 0.1)
        end
    end
    f(2)
end


function takeItem ()
    local pos = self.getPosition()
          pos_x = pos.x
    local pos_y = pos.y
    local pos_z = pos.z
    cards = {}
    function circle(c, r, t)
        return { r * math.cos(t) + c[1], r * math.sin(t) + c[2] }
    end
    local r = self.getBounds().size[1] / 2. - 2.7
    local count = 16.
    local step = (2. * math.pi) / count
    function loop(i)
        if i < 2. * math.pi then
            local p = circle({pos_x, pos_z}, r, i)
            card = ibag.takeObject({['position'] = { p[1], pos_y+0.5, p[2]}, ['smooth'] = false } )

            card.setRotation({0, ((math.pi / 2. - i) * 180.) / math.pi, 0})

            cards[#cards+1] = card
            Wait.time( function() loop(i + step) end, 0.1)
        end
    end
    loop(0.)
end

function findBagInSphere(pos)
    local scale = self.getScale()
    pos = self.getPosition() --получаем координаты точки
    pos.y=pos.y+0.5 --добавляем значение чтоб ы переместить точку по оси Y
    pos.x=pos.x--добавляем значение чтоб ы переместить точку по оси X
    pos.z=pos.z --добавля��м значение чтоб ы переместить точку по оси Z
    return Physics.cast({
        origin=pos, -- Присвае��аем координаты с добавленым значением
        direction={0,1,0}, type=3, max_distance=0.1,
        size={scale.x-3.5,scale.y,scale.z-3.5}, --debug=true
    })
end