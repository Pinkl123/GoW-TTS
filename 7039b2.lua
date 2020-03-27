-- HPBarWriter
--[[LUAStart
health = {value = 10, max = 10}
mana = {value = 10, max = 10}
extra = {value = 10, max = 10}

player = false

options = {
    HP2Desc = false,
    belowZero = false,
    aboveMax = false,
    heightModifier = 110,
    showBaseButtons = false,
    showBarButtons = false,
    hideHp = false,
    hideMana = false,
    hideExtra = true,
    incrementBy = 1,
    rotation = 90
}


function onLoad(save_state)
  if save_state ~= "" then
    saved_data = JSON.decode(save_state)
    if saved_data.health then
      for heal,_ in pairs(health) do
        health[heal] = saved_data.health[heal]
      end
    end
    if saved_data.mana then
      for res,_ in pairs(mana) do
        mana[res] = saved_data.mana[res]
      end
    end
    if saved_data.extra then
      for res,_ in pairs(extra) do
        extra[res] = saved_data.extra[res]
      end
    end
    if saved_data.options then
      for opt,_ in pairs(options) do
        options[opt] = saved_data.options[opt]
      end
    end
    if saved_data.statNames then
      for stat,_ in pairs(statNames) do
        statNames[stat] = saved_data.statNames[stat]
      end
    end
  end
  local script = self.getLuaScript()
  local xml = script:sub(script:find("StartXML")+8, script:find("StopXML")-1)
  self.UI.setXml(xml)
  Wait.frames(load, 10)
end

function load()
  self.UI.setAttribute("panel", "position", "0 0 -" .. self.getBounds().size.y / self.getScale().y * options.heightModifier)
  self.UI.setAttribute("progressBar", "percentage", health.value / health.max * 100)
  self.UI.setAttribute("hpText", "text", health.value .. "/" .. health.max)
  self.UI.setAttribute("progressBarS", "percentage", mana.value / mana.max * 100)
  self.UI.setAttribute("manaText", "text", mana.value .. "/" .. mana.max)
  self.UI.setAttribute("extraProgress", "percentage", extra.value / extra.max * 100)
  self.UI.setAttribute("extraText", "text", extra.value .. "/" .. extra.max)
  self.UI.setAttribute("manaText", "textColor", "#FFFFFF")
  self.UI.setAttribute("increment", "text", options.incrementBy)

  for i,j in pairs(statNames) do
    if j == true then
      self.UI.setAttribute(i, "active", true)
    end
  end
  Wait.frames(function() self.UI.setAttribute("statePanel", "width", getStatsCount()*300) end, 1)

  if options.showBarButtons then
    self.UI.setAttribute("addSub", "active", true)
    self.UI.setAttribute("addSubS", "active", true)
    self.UI.setAttribute("addSubE", "active", true)
  end

  self.UI.setAttribute("ressourceBar", "active", options.hideHp == true and "False" or "True")
  self.UI.setAttribute("ressourceBarS", "active", options.hideMana == true and "False" or "True")
  self.UI.setAttribute("extraBar", "active", options.hideExtra == true and "False" or "True")
  self.UI.setAttribute("addSub", "active", options.showBarButtons == true and "True" or "False")
  self.UI.setAttribute("addSubS", "active", options.showBarButtons == true and "True" or "False")
  self.UI.setAttribute("addSubE", "active", options.showBarButtons == true and "True" or "False")
  self.UI.setAttribute("panel", "rotation", options.rotation .. " 270 90")

  if options.showBaseButtons then
    createBtns()
  end
end

function onSave()
  local save_state = JSON.encode({health = health, mana = mana, extra = extra, options = options, statNames = statNames})
  self.script_state = save_state
end

function createBtns()
  local buttonParameter = {click_function = "add", function_owner = self, position = {0.3, 0.04, 0.4}, label = "+", width = 250, height = 250, font_size = 300, color = {0,0,0,0}, font_color = {0,0,0,100}}
  self.createButton(buttonParameter)
  buttonParameter.position = {-0.3, 0.04, 0.4}
  buttonParameter.click_function = "sub"
  buttonParameter.label = "-"
  self.createButton(buttonParameter)
end

function add() onClick(-1, - 1, "add") end
function sub() onClick(-1, - 1, "sub")end

function onEndEdit(player, value, id)
  options.incrementBy = value
end

function onClickEx(params)
  onClick(params.player, params.value, params.id)
end

function onClick(player, value, id)
  if id == "editButton" then
    if self.UI.getAttribute("editPanel", "active") == "False" or self.UI.getAttribute("editPanel", "active") == nil then
      self.UI.setAttribute("editPanel", "active", true)
    else
      self.UI.setAttribute("editPanel", "active", false)
    end
  elseif id == "subHeight" or id == "addHeight" then
    if id == "addHeight" then
      options.heightModifier = options.heightModifier + options.incrementBy
    else
      options.heightModifier = options.heightModifier - options.incrementBy
    end
    self.UI.setAttribute("panel", "position", "0 0 -" .. self.getBounds().size.y / self.getScale().y * options.heightModifier)
  elseif id == "subRotation" or id == "addRotation" then
    if id == "addRotation" then
      options.rotation = options.rotation + options.incrementBy
    else
      options.rotation = options.rotation - options.incrementBy
    end
    self.UI.setAttribute("panel", "rotation", options.rotation .. " 270 90")
  elseif id == "BB" then
    if options.showBaseButtons then
      self.clearButtons()
      options.showBaseButtons = false
    else
      createBtns()
      options.showBaseButtons = true
    end
  elseif id == "HM" then
    options.hideMana = not options.hideMana
    local vertical = self.UI.getAttribute("bars", "height")
    Wait.frames(function()
      self.UI.setAttribute("ressourceBarS", "active", options.hideMana == true and "False" or "True")
      self.UI.setAttribute("bars", "height", vertical + (options.hideMana == true and -100 or 100))
    end, 1)
  elseif id == "HE" then
    options.hideExtra = not options.hideExtra
    local vertical = self.UI.getAttribute("bars", "height")
    Wait.frames(function()
      self.UI.setAttribute("extraBar", "active", options.hideExtra == true and "False" or "True")
      self.UI.setAttribute("bars", "height", vertical + (options.hideExtra == true and -100 or 100))
    end, 1)
  elseif id == "HB" or id == "editButtonS" then
    if options.showBarButtons then
      self.UI.setAttribute("addSub", "active", false)
      self.UI.setAttribute("addSubS", "active", false)
      self.UI.setAttribute("addSubE", "active", false)
      options.showBarButtons = false
    else
      self.UI.setAttribute("addSub", "active", true)
      self.UI.setAttribute("addSubS", "active", true)
      self.UI.setAttribute("addSubE", "active", true)
      options.showBarButtons = true
    end
  elseif id == "BZ" then
    if options.belowZero then
      options.belowZero = false
      broadcastToAll("Below Zero Denied!", {1,1,1})
    else
      options.belowZero = true
      broadcastToAll("Below Zero allowed!", {1,1,1})
    end
  elseif id == "AM" then
    if options.aboveMax then
      options.aboveMax = false
      broadcastToAll("Above Max Denied!", {1,1,1})
    else
      options.aboveMax = true
      broadcastToAll("Above Max allowed!", {1,1,1})
    end
  elseif statNames[id] ~= nil then
    self.UI.setAttribute(id, "active", false)
    self.UI.setAttribute("statePanel", "width", tonumber(self.UI.getAttribute("statePanel", "width")-300))
    statNames[id] = false
  else
    if id == "add" then health.value = health.value + options.incrementBy
    elseif id == "addS" then mana.value = mana.value + options.incrementBy
    elseif id == "addE" then extra.value = extra.value + options.incrementBy
    elseif id == "sub" then health.value = health.value - options.incrementBy
    elseif id == "subS" then mana.value = mana.value - options.incrementBy
    elseif id == "subE" then extra.value = extra.value - options.incrementBy
    elseif id == "addMax" then health.value = health.value + options.incrementBy
      health.max = health.max + options.incrementBy
    elseif id == "addMaxS" then mana.value = mana.value + options.incrementBy
      mana.max = mana.max + options.incrementBy
    elseif id == "addMaxE" then extra.value = extra.value + options.incrementBy
      extra.max = extra.max + options.incrementBy
    elseif id == "subMax" then health.value = health.value - options.incrementBy
      health.max = health.max - options.incrementBy
    elseif id == "subMaxS" then mana.value = mana.value - options.incrementBy
      mana.max = mana.max - options.incrementBy
    elseif id == "subMaxE" then extra.value = extra.value - options.incrementBy
      extra.max = extra.max - options.incrementBy
    end
    if health.value > health.max and not options.aboveMax then health.value = health.max end
    if health.value < 0 and not options.belowZero then health.value = 0 end
    if mana.value > mana.max and not options.aboveMax then mana.value = mana.max end
    if mana.value < 0 and not options.belowZero then mana.value = 0 end
    if extra.value > extra.max and not options.aboveMax then extra.value = extra.max end
    if extra.value < 0 and not options.belowZero then extra.value = 0 end
    self.UI.setAttribute("progressBar", "percentage", health.value / health.max * 100)
    self.UI.setAttribute("progressBarS", "percentage", mana.value / mana.max * 100)
    self.UI.setAttribute("extraProgress", "percentage", extra.value / extra.max * 100)
    self.UI.setAttribute("hpText", "text", health.value .. "/" .. health.max)
    self.UI.setAttribute("manaText", "text", mana.value .. "/" .. mana.max)
    self.UI.setAttribute("extraText", "text", extra.value .. "/" .. extra.max)
    if options.HP2Desc then
      self.setDescription(health.value .. "/" .. health.max)
    end
  end
  self.UI.setAttribute("hpText", "textColor", "#FFFFFF")
  self.UI.setAttribute("manaText", "textColor", "#FFFFFF")
end

function onCollisionEnter(a)
  local newState = a.collision_object.getName()
  if statNames[newState] ~= nil then
    statNames[newState] = true
    a.collision_object.destruct()
    self.UI.setAttribute(newState, "active", true)
    Wait.frames(function() self.UI.setAttribute("statePanel", "width", getStatsCount()*300) end, 1)
  end
end

function getStatsCount()
  local count = 0
  for i,j in pairs(statNames) do
    if self.UI.getAttribute(i, "active") == "True" or self.UI.getAttribute(i, "active") == "true" then
      count = count + 1
    end
  end
  return count
end
LUAStop--lua]]
--[[XMLStart
<Defaults>
  <Button onClick="onClick" fontSize="80" fontStyle="Bold" textColor="#FFFFFF" color="#000000F0"/>
  <Text fontSize="80" fontStyle="Bold" color="#FFFFFF"/>
  <InputField fontSize="70" color="#000000F0" textColor="#FFFFFF" characterValidation="Integer"/>
</Defaults>

<Panel id="panel" position="0 0 -220" rotation="90 270 90" scale="0.2 0.2">
<VerticalLayout id="bars" height="200">
  <Panel id="ressourceBar" active="true">
    <ProgressBar id="progressBar" visibility="" height="100" width="600" showPercentageText="false" color="#000000E0" percentage="100" fillImageColor="#710000"></ProgressBar>
    <Text id="hpText" visibility="" height="100" width="600" text="10/10"></Text>
    <HorizontalLayout height="100" width="600">
       <Button id="leftSide" text="" color="#00000000"></Button>
       <Button id="editButton" color="#00000000"></Button>
       <Button id="editButtonS" text="" color="#00000000"></Button>
    </HorizontalLayout>
    <Panel id="addSub" visibility="" height="100" width="825" active="false">
      <HorizontalLayout spacing="625">
        <Button id="sub" text="-" color="#FFFFFF" textColor="#000000"></Button>
        <Button id="add" text="+" color="#FFFFFF" textColor="#000000"></Button>
      </HorizontalLayout>
    </Panel>
  </Panel>
  <Panel id="ressourceBarS" active="true">
    <ProgressBar id="progressBarS" visibility="" height="100" width="600" showPercentageText="false" color="#000000E0" percentage="100" fillImageColor="#000071"></ProgressBar>
    <Text id="manaText" visibility="" height="100" width="600" text="10/10"></Text>
    <Panel id="addSubS" visibility="" height="100" width="825" active="false">
      <HorizontalLayout spacing="625">
        <Button id="subS" text="-" color="#FFFFFF" textColor="#000000"></Button>
        <Button id="addS" text="+" color="#FFFFFF" textColor="#000000"></Button>
      </HorizontalLayout>
    </Panel>
  </Panel>
  <Panel id="extraBar" active="true">
    <ProgressBar id="extraProgress" visibility="" height="100" width="600" showPercentageText="false" color="#000000E0" percentage="100" fillImageColor="#FFCF00"></ProgressBar>
    <Text id="extraText" visibility="" height="100" width="600" text="10/10"></Text>
    <Panel id="addSubE" visibility="" height="100" width="825" active="false">
      <HorizontalLayout spacing="625">
        <Button id="subE" text="-" color="#FFFFFF" textColor="#000000"></Button>
        <Button id="addE" text="+" color="#FFFFFF" textColor="#000000"></Button>
      </HorizontalLayout>
    </Panel>
  </Panel>
  </VerticalLayout>
  <Panel id="editPanel" height="620" width="600" position="0 970 0" active="False">
    <VerticalLayout>
      <HorizontalLayout minheight="160">
        <Button id="BZ" fontSize="70" text="Below Zero" color="#000000F0"></Button>
        <Button id="AM" fontSize="70" text="Above Max" color="#000000F0"></Button>
      </HorizontalLayout>
      <HorizontalLayout minheight="160">
        <Button id="BB" fontSize="70" text="Base Buttons" color="#000000F0"></Button>
        <Button id="HB" fontSize="70" text="HP Bar Buttons" color="#000000F0"></Button>
      </HorizontalLayout>
      <HorizontalLayout minheight="100">
        <Button id="HM" fontSize="70" text="Hide Ressource Bar" color="#000000F0"></Button>
      </HorizontalLayout>
      <HorizontalLayout minheight="100">
        <Button id="HE" fontSize="70" text="Hide Extra Bar" color="#000000F0"></Button>
      </HorizontalLayout>
      <HorizontalLayout spacing="10" minheight="100">
        <Button id="subHeight" text="◄"></Button>
        <Text>Height</Text>
        <Button id="addHeight" text="►"></Button>
      </HorizontalLayout>
      <HorizontalLayout spacing="10" minheight="100">
        <Button id="subRotation" text="◄" minwidth="90"></Button>
        <Text>Rotation</Text>
        <Button id="addRotation" text="►" minwidth="90"></Button>
      </HorizontalLayout>
      <HorizontalLayout spacing="55"  minheight="100">
        <Button id="subMax" text="◄"></Button>
        <Text>Max</Text>
        <Button id="addMax" text="►"></Button>
      </HorizontalLayout>
      <HorizontalLayout spacing="55"  minheight="100">
        <Button id="subMaxS" text="◄" minwidth="90"></Button>
        <Text>Max R</Text>
        <Button id="addMaxS" text="►" minwidth="90"></Button>
      </HorizontalLayout>
      <HorizontalLayout spacing="55"  minheight="100">
        <Button id="subMaxE" text="◄" minwidth="90"></Button>
        <Text>Max E</Text>
        <Button id="addMaxE" text="►" minwidth="90"></Button>
      </HorizontalLayout>
      <HorizontalLayout spacing="10" minheight="100">
        <Text fontSize="50">Increment by:</Text>
        <InputField id="increment" onEndEdit="onEndEdit" minwidth="200" text="1"></InputField>
      </HorizontalLayout>
    </VerticalLayout>
  </Panel>
  <Panel id="statePanel" height="300" width="-5" position="0 370 0">
    <VerticalLayout>
      <HorizontalLayout spacing="5">
      STATSIMAGE
      </HorizontalLayout>
    </VerticalLayout>
  </Panel>
</Panel>
XMLStop--xml]]

options = {
  hideText = false,
  editText = false,
  hideBar = false,
  hideAll = false,
  showAll = true,
  playerChar = false,
  HP2Desc = false,
  hp = 10,
  mana = 10,
  extra = 0
}

function onLoad(save_state)
  if save_state ~= "" then
    saved_data = JSON.decode(save_state)
    if saved_data ~= nil then
      for opt,_ in pairs(options) do
        options[opt] = saved_data[opt]
      end
    end
  end
  if options.hideText then
    self.UI.setAttribute("hideText", "value", "true")
    self.UI.setAttribute("hideText", "text", "✘")
    self.UI.setAttribute("hideText", "textColor", "#FFFFFF")
    Wait.frames(function() loadToggle("hideText") end, 1)
  end
  if options.editText then
    self.UI.setAttribute("editText", "value", "true")
    self.UI.setAttribute("editText", "text", "✘")
    self.UI.setAttribute("editText", "textColor", "#FFFFFF")
    Wait.frames(function() loadToggle("editText") end, 1)
  end
  if options.hideBar then
    self.UI.setAttribute("hideBar", "value", "true")
    self.UI.setAttribute("hideBar", "text", "✘")
    self.UI.setAttribute("hideBar", "textColor", "#FFFFFF")
    Wait.frames(function() loadToggle("hideBar") end, 1)
  end

  self.UI.setAttribute("hp", "text", options.hp)
  self.UI.setAttribute("mana", "text", options.mana)
  self.UI.setAttribute("extra", "text", options.extra)

  if not options.showAll then
    self.UI.setAttribute("showAll", "value", "false")
    Wait.frames(allOff, 1)
  end
end

function loadToggle(id)
  local toChange = ""
  if id == "hideText" then
    toChange = "hpText"
  elseif id == "editText" then
    toChange = "addSub"
  elseif id == "hideBar" then
    toChange = "progressBar"
  end
  for i,j in pairs(getAllObjects()) do
    if j ~= self then
      if j.getLuaScript():find("StartXML") then
        if not j.getVar("player") then
          j.UI.setAttribute(toChange, "visibility", "Black")
          if id == "hideText" then
            j.UI.setAttribute("manaText", "visibility", "Black")
            j.UI.setAttribute("extraText", "visibility", "Black")
          elseif id == "hideBar" then
            j.UI.setAttribute("progressBarS", "visibility", "Black")
          elseif id == "editText" then
            j.UI.setAttribute("addSubS", "visibility", "Black")
            j.UI.setAttribute("addSubE", "visibility", "Black")
            j.UI.setAttribute("editPanel", "visibility", "Black")
            j.UI.setAttribute("editPanel", "active", "false")
          end
        end
      end
    end
  end
end

function allOff()
  for i,j in pairs(getAllObjects()) do
    if j ~= self then
      if j.getLuaScript():find("StartXML") then
        j.UI.setAttribute("panel", "active", "false")
      end
    end
  end
end

function onSave()
  local save_state = JSON.encode(options)
  self.script_state = save_state
end

function toggleCheckBox(player, value, id)
  if self.UI.getAttribute(id, "value") == "false" then
    self.UI.setAttribute(id, "value", "true")
    self.UI.setAttribute(id, "text", "✘")
    options[id] = true
  else
    self.UI.setAttribute(id, "value", "false")
    self.UI.setAttribute(id, "text", "")
    options[id] = false
  end
  self.UI.setAttribute(id, "textColor", "#FFFFFF")
  local toChange = ""
  if id == "hideText" then
    toChange = "hpText"
  elseif id == "editText" then
    toChange = "addSub"
  elseif id == "hideBar" then
    toChange = "progressBar"
  end
  for i,j in pairs(getAllObjects()) do
    if j ~= self then
      if j.getLuaScript():find("StartXML") then
        if not j.getVar("player") then
          j.UI.setAttribute(toChange, "visibility", options[id] == true and "Black" or "")
          if id == "hideText" then
            j.UI.setAttribute("manaText", "visibility", options[id] == true and "Black" or "")
            j.UI.setAttribute("extraText", "visibility", options[id] == true and "Black" or "")
          elseif id == "hideBar" then
            j.UI.setAttribute("progressBarS", "visibility", options[id] == true and "Black" or "")
          elseif id == "editText" then
            j.UI.setAttribute("addSubS", "visibility", options[id] == true and "Black" or "")
            j.UI.setAttribute("addSubE", "visibility", options[id] == true and "Black" or "")
            j.UI.setAttribute("editPanel", "visibility", options[id] == true and "Black" or "")
            j.UI.setAttribute("editPanel", "active", "false")
          end
        end
      end
    end
  end
end

function toggleHideBars(player, value, id)
   for i,j in pairs(getAllObjects()) do
     if j ~= self and j.getName() ~= "HP Bar Panel" then
       if j.getLuaScript():find("StartXML") then
          if not options.hideAll then
             j.UI.setAttribute("ressourceBar", "active", "false")
             j.UI.setAttribute("ressourceBarS", "active", "false")
             j.UI.setAttribute("extraBar", "active", "false")
          else
             j.UI.setAttribute("ressourceBar", "active", "true")
             local objTable = j.getTable("options")
             if not objTable.hideMana then
                j.UI.setAttribute("ressourceBarS", "active", "true")
             end
             if not objTable.hideExtra then
                j.UI.setAttribute("extraBar", "active", "true")
             end
          end
       end
     end
   end
   options.hideAll = not options.hideAll
end


function toggleOnOff(player, value, id)
  if self.UI.getAttribute(id, "value") == "false" then
    self.UI.setAttribute(id, "value", "true")
    options[id] = true
  else
    self.UI.setAttribute(id, "value", "false")
    options[id] = false
  end
  for i,j in pairs(getAllObjects()) do
    if j ~= self then
      if j.getLuaScript():find("StartXML") then
        j.UI.setAttribute("panel", "active", options[id] == true and "true" or "false")
      end
    end
  end
end

function onEndEdit(player, value, id)
  options[id] = tonumber(value)
  self.UI.setAttribute(id, "text", value)
end

function onCollisionEnter(collision_info)
  local object = collision_info.collision_object
  if object.tag == "Figure" or object.tag == "Tileset" or object.tag == "rpgFigurine" or object.tag == "Figurine" then
    local assets = self.UI.getCustomAssets()
    local script = self.getLuaScript()
    local xml = script:sub(script:find("XMLStart")+8, script:find("XMLStop")-1)
    local newScript = script:sub(script:find("LUAStart")+8, script:find("LUAStop")-1)
    local stats = "statNames = {"
    local xmlStats = ""
    for j,i in pairs(assets) do
      stats = stats .. i.name .. " = false, "
      xmlStats = xmlStats .. '<Button id="' .. i.name .. '" color="#FFFFFF00" active="false"><Image image="' .. i.name .. '" preserveAspect="true"></Image></Button>\n'
    end
    newScript = "--[[StartXML\n" .. xml:gsub("STATSIMAGE", xmlStats) .. "StopXML--xml]]" .. stats:sub(1, -3) .. "}\n" .. newScript
    xml = xml:gsub("STATSIMAGE", xmlStats)
    if not options.hideText and options.HP2Desc then
      object.setDescription(options.hp .. "/" .. options.hp)
    end
    newScript = newScript:gsub("health = {value = 10, max = 10}", "health = {value = " .. options.hp ..", max = " .. options.hp .. "}")
    newScript = newScript:gsub("mana = {value = 10, max = 10}", "mana = {value = " .. options.mana ..", max = " .. options.mana .. "}")

    if options.hp == 0 then
      newScript = newScript:gsub("hideHp = false,", "hideHp = true,")
    end
    if options.mana == 0 then
      newScript = newScript:gsub("hideMana = false,", "hideMana = true,")
    end
    if options.extra ~= 0 then
      newScript = newScript:gsub("hideExtra = true,", "hideExtra = false,")
    end
    newScript = newScript:gsub('<VerticalLayout id="bars" height="200">', '<VerticalLayout id="bars" height="' .. 200 + (options.mana == 0 and -100 or 0) + (options.extra ~= 0 and 100 or 0) .. '">')


    if options.playerChar then
      newScript = newScript:gsub("player = false", "player = true")
      if options.HP2Desc then
        newScript = newScript:gsub("HP2Desc = false,", "HP2Desc = true,")
      end
    else
      if options.hideText then
        newScript = newScript:gsub('id="hpText" visibility=""', 'id="hpText" visibility="Black"')
        newScript = newScript:gsub('id="manaText" visibility=""', 'id="manaText" visibility="Black"')
        newScript = newScript:gsub('id="extraText" visibility=""', 'id="extraText" visibility="Black"')
      end
      if options.hideBar then
        newScript = newScript:gsub('id="progressBar" visibility=""', 'id="progressBar" visibility="Black"')
        newScript = newScript:gsub('id="progressBarS" visibility=""', 'id="progressBarS" visibility="Black"')
      end
      if options.editText then
        newScript = newScript:gsub('id="addSub" visibility=""', 'id="addSub" visibility="Black"')
        newScript = newScript:gsub('id="addSubS" visibility=""', 'id="addSubS" visibility="Black"')
        newScript = newScript:gsub('id="addSubE" visibility=""', 'id="addSubE" visibility="Black"')
        newScript = newScript:gsub('id="editPanel" visibility=""', 'id="editPanel" visibility="Black"')
      end
    end
    newScript = newScript:gsub('<Panel id="panel" position="0 0 -220"', '<Panel id="panel" position="0 0 ' .. object.getBounds().size.y / object.getScale().y * 110 .. '"')
    object.setLuaScript(newScript)
    -- Wait.time(function()
    --   object.UI.setAttribute("panel", "position", "0 0 -" .. object.getBounds().size.y / object.getScale().y * 110)
    -- end, 1)
  end
end