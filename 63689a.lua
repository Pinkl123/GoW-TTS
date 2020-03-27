--[[StartXML

<Defaults>
  <Button onClick="onClick" fontSize="80" fontStyle="Bold" textColor="#FFFFFF" color="#000000F0"/>
  <Text fontSize="80" fontStyle="Bold" color="#FFFFFF"/>
  <InputField fontSize="70" color="#000000F0" textColor="#FFFFFF" characterValidation="Integer"/>
</Defaults>

<Panel id="panel" position="0 0 -90" rotation="90 270 90" scale="0.1 0.1">
<VerticalLayout id="bars" height="300">
  <Panel id="ressourceBar" active="true">
      <ProgressBar id="progressBar" visibility="" height="100" width="600" showPercentageText="false" color="#000000E0" percentage="100" fillImageColor="#710000"></ProgressBar>
    <Text id="hpText" visibility="" height="100" width="600" text="10/10"></Text>
    <HorizontalLayout height="100" width="600">
       <Button id="Settings" color="#00000000"></Button>
    </HorizontalLayout>
  </Panel>
    </VerticalLayout>
    <VerticalLayout height="180" width="600" position="0 330 0">
  <HorizontalLayout minheight="100"  minwidth="80">
    <Button fontSize="45" text="Значение" color="#000000F0" visibility="Black"></Button>
    <InputField id="increment" onEndEdit="onEndEdit" text="1" visibility="Black"></InputField>
  </HorizontalLayout>
  <HorizontalLayout minheight="90"  minwidth="80">
    <Button id="FDMG"  fontSize="45" text="Чистый" color="#000000F0" visibility="Black"></Button>
    <Button id="MDMG"  fontSize="45" text="Магич" color="#000000F0" visibility="Black"></Button>
    <Button id="PDMG"  fontSize="45" text="Физич" color="#000000F0" visibility="Black"></Button>
  </HorizontalLayout>

  <HorizontalLayout  minheight="100"  minwidth="100">
    <Button id="Damge" preferredWidth="100"  preferredHeight="50" color="#FFFFFF00" active="true"><Image image="Damge" preserveAspect="true"></Image></Button>

    <Button id="Def"  preferredWidth="100"  preferredHeight="50" color="#FFFFFF00" active="true"><Image image="Def" preserveAspect="true"></Image></Button>

    <Button id="Mdef"  preferredWidth="100"  preferredHeight="50" color="#FFFFFF00" active="true"><Image image="Mdef" preserveAspect="true"></Image></Button>

    <Button id="Info"  preferredWidth="100"  preferredHeight="50" color="#FFFFFF00" active="true"><Image image="Info" preserveAspect="true"></Image></Button>

    <Button id="Res"  preferredWidth="100"  preferredHeight="50" color="#FFFFFF00" active="true"><Image image="Res" preserveAspect="true"></Image></Button>

  </HorizontalLayout>
    <HorizontalLayout  minheight="100"  minwidth="100">
    <Text id="PDMG"  fontSize="55" text="100" color="#F5F5F5"></Text>
    <Text id="PDMG"  fontSize="55" text="100" color="#F5F5F5"></Text>
    <Text id="PDMG"  fontSize="55" text="100" color="#F5F5F5"></Text>
    <Text id="PDMG"  fontSize="55" text="100" color="#F5F5F5"></Text>
    <Text id="PDMG"  fontSize="55" text="100" color="#F5F5F5"></Text>
    </HorizontalLayout>
  </VerticalLayout>



  <Panel id="setingPanel" height="310" width="600" position="0 500 0" active="false">
    <VerticalLayout>
    <HorizontalLayout minheight="100"  minwidth="90">
        <Button id="lvl" fontSize="60" text="Лвл: 0" minwidth="300"></Button>
        <Button id="tret" fontSize="60" text="Трит: 0" minwidth="300"></Button>
    </HorizontalLayout>
      <HorizontalLayout spacing="10" minheight="100">
          <Button id="iClass" fontSize="60" text="Класс" minwidth="300"></Button>
      </HorizontalLayout>
      <HorizontalLayout minheight="100">
        <Button id="RC" fontSize="70" text="Генерация" color="#000000F0"></Button>
              </HorizontalLayout>
              </VerticalLayout>
            </Panel>


  <Panel id="statePanel" height="300" width="0" scale="0.5 0.5" position="0 -130 0" visibility="">
    <VerticalLayout>
      <HorizontalLayout>
      <Button id="Immobilize" color="#FFFFFF00" active="false"><Image image="Immobilize" preserveAspect="true"></Image></Button>
<Button id="Wound" color="#FFFFFF00" active="false"><Image image="Wound" preserveAspect="true"></Image></Button>
<Button id="Muddle" color="#FFFFFF00" active="false"><Image image="Muddle" preserveAspect="true"></Image></Button>
<Button id="Invisible" color="#FFFFFF00" active="false"><Image image="Invisible" preserveAspect="true"></Image></Button>
<Button id="Disarm" color="#FFFFFF00" active="false"><Image image="Disarm" preserveAspect="true"></Image></Button>
<Button id="Strengthen" color="#FFFFFF00" active="false"><Image image="Strengthen" preserveAspect="true"></Image></Button>
<Button id="Stun" color="#FFFFFF00" active="false"><Image image="Stun" preserveAspect="true"></Image></Button>
<Button id="Poison" color="#FFFFFF00" active="false"><Image image="Poison" preserveAspect="true"></Image></Button>

      </HorizontalLayout>
    </VerticalLayout>
  </Panel>
</Panel>
StopXML--xml]]
statNames = {Immobilize = false, Wound = false, Muddle = false, Invisible = false, Disarm = false, Strengthen = false, Stun = false, Poison = false}

health = {value = 10, max = 10}
mana = {value = 0, max = 0}
extra = {value = 10, max = 10}
Class =({"Воин","Танк","Лучник","Маг"})
ClassCount = 1
lvlCount = 0
tretCount = 0
player = false

options = {
incrementBy = 1,
Stats = 0
}
TretPDF = 100
TretMDF = 100
TretATK = 70
tretCount = 1
lvlCount = 1
health.max = 100
health.value = 100
function onLoad(save_state)
  local script = self.getLuaScript()
  local xml = script:sub(script:find("StartXML")+8, script:find("StopXML")-1)
  self.UI.setXml(xml)
  Wait.time(function() onClick() end, 1, 1)
  Wait.time(function() load() end, 1, 1)
end
function load()
  --print("load")
  self.UI.setAttribute("progressBar", "percentage", health.value / health.max * 100)
  self.UI.setAttribute("hpText", "text", health.value .. "/" .. health.max)
  self.UI.setAttribute("progressBarS", "percentage", mana.value / mana.max * 100)
  self.UI.setAttribute("manaText", "text", mana.value .. "/" .. mana.max)
  self.UI.setAttribute("extraProgress", "percentage", extra.value / extra.max * 100)
  self.UI.setAttribute("extraText", "text", extra.value .. "/" .. extra.max)
  self.UI.setAttribute("manaText", "textColor", "#FFFFFF")
  self.UI.setAttribute("increment", "text", options.incrementBy)
  self.UI.setAttribute("iClass", "text", "Класс: "..Class[ClassCount])
  self.UI.setAttribute("iClass", "textColor", "#FFFFFF")
  self.UI.setAttribute("MD", "text", "Сопрот: "..TretMDF)
  self.UI.setAttribute("MD", "textColor", "#FFFFFF")
  self.UI.setAttribute("PD", "text", "Защита: "..TretPDF)
  self.UI.setAttribute("PD", "textColor", "#FFFFFF")
  self.UI.setAttribute("DMG", "text", "Урон:    "..TretATK)
  self.UI.setAttribute("DMG", "textColor", "#FFFFFF")
  self.UI.setAttribute("lvl", "text", "Лвл: "..lvlCount)
  self.UI.setAttribute("lvl", "textColor", "#FFFFFF")
  self.UI.setAttribute("tret", "text", "Трит: "..tretCount)
  self.UI.setAttribute("tret", "textColor", "#FFFFFF")
  self.UI.setAttribute("setingPanel", "visibility", "Black")
  if health.value < 1 then
    print("У меня кончились ХП")
    local position = self.getPosition()
    local rotation = self.getRotation()
    local scale = self.getScale()
    bzz_parameters = {}
    bzz_parameters.type = 'Custom_AssetBundle'
    bzz = spawnObject(bzz_parameters)

    custom1 = {}

    custom1.assetbundle = 'https://drive.google.com/uc?export=download&id=0BxvLXJFgtJJ8YXF2ZktjX2U5eG8'
    custom1.int = 5
    custom1.material = 0

    bzz.setCustomObject(custom1)
    bzz.setLuaScript('function onload()\nself.setScale({'..scale.x..'-4.25, '..scale.y..'-4.25, '..scale.z..'-4.25})\nself.setPosition({'..position.x..', '..position.y..', '..position.z..'})\nself.lock()\nself.AssetBundle.getTriggerEffects()\nself.AssetBundle.playTriggerEffect(0)\nlocal params = {identifier = self.getGUID().."_ind", function_name = "myTimer", delay = 3, repetitions = 1,}\nTimer:create(params)\nend\nfunction myTimer()\nself.destruct()\nend')
destruct()
spawndrop()
self.destruct()
end
end

function onEndEdit(player, value, id)
  options.incrementBy = value
end

function onClickEx(params)
  onClick(params.player, params.value, params.id)
end

function Text()
if d ~= nil and Test ~= nil then
d.destruct()
else
font_size = 1
lifespan = 1.5
spin_speed = 0.5
rise_speed = 0.5
grow_speed = 1

c=self.getPosition()+Vector({0,4.5+font_size/1,0})
d=spawnObject({type="3DText",position=c})
d.TextTool.setValue("-"..Test)
d.TextTool.setFontColor(self.getColorTint())
d.TextTool.setFontSize(font_size*24)
Wait.frames(function()d.interactable=false;
d.auto_raise=false
d.setLuaScript('function onload()\nprint("Я родился!")\nend')
rise(d,c)spin(d,{0,spin_speed*18,0})
grow(d,font_size*24)
test = d.getGUID(parent_guid)
Wait.time(function() Collide = false
Fast = false d.destruct() end,lifespan)end,1)
function rise(d,c) if not getObjectFromGUID(d.guid)then
  return false
end;
d.setPosition(c)c[2]=c[2]+rise_speed/100;Wait.frames(function()rise(d,c)end,1)end;
function spin(d,f)if not getObjectFromGUID(d.guid)then
   return false
 end
--d.setRotationSmooth(f,false,true)f[2]=f[2]+spin_speed*5;
Wait.time(function()spin(d,f)end,0.5)
end
function grow(d,font_size)
  if not getObjectFromGUID(d.guid)then return false end;
  d.TextTool.setFontSize(font_size)Wait.time(function()grow(d,font_size*(grow_speed+100)/100)end,0.1)
end
end
end

function onClick(player, value, id)
  if id == "Settings" then
    if self.UI.getAttribute("setingPanel", "active") == "False" or self.UI.getAttribute("setingPanel", "active") == nil then
      self.UI.setAttribute("setingPanel", "active", true)
    else
      self.UI.setAttribute("setingPanel", "active", false)
    end

  elseif id == "iClass" then
    if ClassCount == 4 then ClassCount = 1
      else
      ClassCount = ClassCount + 1
    end
  elseif id == "lvl" then
    if lvlCount == 5 then lvlCount = 1
      else
      lvlCount = lvlCount + 1
    end

  elseif id == "tret" then
    if tretCount == 5 then tretCount = 1
      else
      tretCount = tretCount + 1
    end

  elseif id == "FDMG" then
    health.value = health.value - options.incrementBy
    Text()
  elseif id == "RC" then
    SumStat()
    TretPDF = (PDF * a) * b
    TretMDF = (MDF * a) * b
    TretATK = (ATK * a) * b
    load()
  elseif statNames[id] ~= nil then
    self.UI.setAttribute(id, "active", false)
    self.UI.setAttribute("statePanel", "width", tonumber(self.UI.getAttribute("statePanel", "width")-300))
    statNames[id] = false
 end
 load()

end
function ClassC()
if ClassCount == 1 then
  PDF = 300
  MDF = 300
  ATK = 70
  health.max = 100
  health.value = 100
elseif ClassCount == 2 then
  PDF = 450
  MDF = 450
  ATK = 50
  health.max = 200
  health.value = 200
elseif ClassCount == 3 then
  PDF = 150
  MDF = 150
  ATK = 140
  health.max = 70
  health.value = 70
elseif ClassCount == 4 then
  PDF = 50
  MDF = 450
  ATK = 140
  health.max = 65
  health.value = 65
elseif ClassCount == 5 then
  PDF = 300
  MDF = 300
  ATK = 70
  health.max = 100
  health.value = 100
end
end
function lvlCount1()
  if lvlCount == 1 then
    a = 0.8
elseif lvlCount == 2 then
    a = 1
elseif lvlCount == 3 then
    a = 1.2
elseif lvlCount == 4 then
    a = 1.4
elseif lvlCount == 5 then
    a = 1.6
  end
  end
function TretCount1()
  if tretCount == 1 then
  b = 0.8
elseif tretCount == 2 then
  b = 1
elseif tretCount == 3 then
  b = 1.2
elseif tretCount == 4 then
  b = 1.4
elseif tretCount == 5 then
  b = 1.6
  end
  end
function SumStat()
  print("lvl ", lvlCount)
  print("trer ", tretCount)
  ClassC()
  lvlCount1()
  TretCount1()
end
function CheckDMG()
--
  print("Нанесен урона ", Test)
  print(Test)
  health.value = health.value - Test
  load()
  Text()
  Test = nil
end
function onCollisionEnter(a)
  local newState = a.collision_object.getName()
  if statNames[newState] ~= nil then
    statNames[newState] = true
    Stats = a.collision_object.getDescription()
    Test = Stats
    a.collision_object.destruct()

    self.UI.setAttribute(newState, "active", true)
    Wait.frames(function() self.UI.setAttribute("statePanel", "width", getStatsCount()*300) end, 1)
  end
end

function getStatsCount()
  if Test ~= nil then
    CheckDMG()
  end
  local count = 0
  for i,j in pairs(statNames) do
    if self.UI.getAttribute(i, "active") == "True" or self.UI.getAttribute(i, "active") == "true" then
      count = count + 1
    end
  end
  return count
end

function destruct()
  local itemsInBowl = findItemsInSphere()
  --Go through all items found by the cast
  for _, entry in ipairs(itemsInBowl) do
      --Ignore the bowl
      if entry.hit_object ~= self then

     local destruct = entry.hit_object.destruct()
    end
  end
end

function findItemsInSphere()
  local scale = self.getScale()
  local pos = self.getPosition()
  return Physics.cast({
      origin={pos.x,pos.y+4,pos.z}, direction={0,1,0}, type=3, max_distance=0.5,
      size={scale.x-1.9,scale.y+3,scale.z-1.9}, --debug=true
  })
end

function spawndrop()
  local ibag=getObjectFromGUID("87bcfa")
  local position = self.getPosition()
      ibag.shuffle()
    hui1 = ibag.takeObject({['position'] = {position.x, position.y+1, position.z}, ['smooth'] = false } )
       pos1 = hui1.getPosition()
       pos1x = math.ceil(pos1.x)
  	 pos1z = math.ceil(pos1.z)
end
