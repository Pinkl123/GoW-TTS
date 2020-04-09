--[[StartXML

<Defaults>
  <Button onClick="onClick" fontSize="80" fontStyle="Bold" textColor="#FFFFFF" color="#000000F0"/>
  <Text fontSize="80" fontStyle="Bold" color="#A3A3A3"/>
</Defaults>

<Panel position="0 -0 0" rotation="180 180 0" scale="3.5 3.5" >
<VerticalLayout height="100" width="100">
  <Panel id="EXPBar" >
  <HorizontalLayout>
    <Button id="Test" fontSize="45" text="1" color="#000000F0"></Button>
  </HorizontalLayout>
  </Panel>
  </VerticalLayout>
</Panel>

StopXML--xml]]
function onLoad()
  local script = self.getLuaScript()
  local xml = script:sub(script:find("StartXML")+8, script:find("StopXML")-1)
  self.UI.setXml(xml)
  SkillName = self.getName()
end

function onClick(player, value, id)
  --Sum1()
  --Sum2()
  --Sum3()
  --Sum4()
  CheckStats()
end

function onCollisionEnter(a)
  TableGuid = a.collision_object.getGUID()
  TableG = getObjectFromGUID(TableGuid)
end
function CheckStats()
  PlayerStats = TableG.getGMNotes()
  SelfStats = self.getDescription()

  tofindMDA = 'MDA'
  foundMDA = string.match(PlayerStats ,tofindMDA..' ([%d-]*)')
  print(foundMDA)

  tofindMPC = 'MPC'
  foundMPC = string.match(PlayerStats ,tofindMPC..' ([%d-]*)')
  print(foundMPC)

  tofindCD = 'Перезарядка:'
  foundCD = string.match(SelfStats,tofindCD..' ([%d-]*)')
  print(foundCD)

  tofindSPD = 'Мощность:'
  foundSPD = string.match(SelfStats,tofindSPD..' ([-+]?%d+%.?%d+)')
  print(foundSPD)

  tofindCD = 'Стоимость:'
  foundCost = string.match(SelfStats,tofindCD..' ([%d-]*)')
  print(foundCost)

  tofindRange = 'Дальность:'
  foundRange = string.match(SelfStats,tofindRange..' ([%d-]*)')
  print(foundRange)

  tofindType = 'Тип:'
  foundType = string.match(SelfStats,tofindType..' ([%S]*)')
  print(foundType)

  tofindRadius = 'Область:'
  foundRadius = string.match(SelfStats,tofindRadius..' ([%d-]*)')
  print(foundRadius)

  local stats = getGlobalScriptTable("stats")
  print("mpc", stats.MPC)
  if stats.MPC < tonumber(foundCost) then
    print("Вася нету маны")
  else
    stats.MPC = stats.MPC - foundCost
    print(stats.MPC)
    setGlobalScriptTable("stats", stats)
    CreateSkill()
  end
end
function CreateSkill()

  bzz_parameters = {}
  bzz_parameters.type = 'Custom_Token'
  bzz_parameters.scale = {x=0.26, y=0.1, z=0.26}
  bzz_parameters.rotation = {x=0, y=180, z=0}
  bzz_parameters.position = {x=0.26, y=0.1, z=0.26}
  bzz = spawnObject(bzz_parameters)
  bzz.use_hands = true
  --bzz.setName(SkillName.." (Атака)")
  bzz.setName("Stun")
  Stats = foundType.."\n".."Урона: "..foundMDA*foundSPD.."\n".."Радиус "..foundRadius
  Promo = foundMDA*foundSPD
  --bzz.setDescription(Stats)
  bzz.setDescription(Promo)
  custom1 = {}

  custom1.image = 'http://cloud-3.steamusercontent.com/ugc/993513340528833726/9EB6FC0A8D9233428338344D7BE37C0622595BF1/'
  custom1.thickness = 0.01
  bzz.setCustomObject(custom1)
end