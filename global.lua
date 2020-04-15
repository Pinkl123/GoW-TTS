-- Bundled by luabundle {"version":"1.5.0"}
local __bundle_require, __bundle_loaded, __bundle_register, __bundle_modules = (function(superRequire)
  local loadingPlaceholder = {[{}] = true}

  local register
  local modules = {}

  local require
  local loaded = {}

  register = function(name, body)
    if not modules[name] then
      modules[name] = body
    end
  end

  require = function(name)
    local loadedModule = loaded[name]

    if loadedModule then
      if loadedModule == loadingPlaceholder then
        return nil
      end
    else
      if not modules[name] then
        if not superRequire then
          local identifier = type(name) == "string" and '"' .. name .. '"' or tostring(name)
          error("Tried to require " .. identifier .. ", but no such module has been registered")
        else
          return superRequire(name)
        end
      end

      loaded[name] = loadingPlaceholder
      loadedModule = modules[name](require, loaded, register, modules)
      loaded[name] = loadedModule
    end

    return loadedModule
  end

  return require, loaded, register, modules
end)(nil)
__bundle_register(
  "__root",
  function(require, _LOADED, __bundle_register, __bundle_modules)
    --[[
      shell mod to test and share turnButton code
    ]]
    require("Lua/tools")

    --[[ The onUpdate event is called once per frame. --]]
    -- function onUpdate()
    --   --[[ print('onUpdate loop!') --]]
    --   -- print(getGlobalScriptVar("stats").MPC)
    -- end
    function onSave()
      local stat = {
        playing = playing,
        tBSave = tB.save()
      }
      return JSON.encode(stat)
    end

    function onLoad(statstr)
      math.randomseed(os.time()) -- non-repeatable randoms
      game_status = JSON.decode(statstr)
      if game_status then
        playing = game_status.playing
        tB.restore(game_status.tBSave)
      else
        playing = false
      end
      if playing then
        tB.show({color = tB.curPlayer, text = "End " .. tB.curPlayer .. "'s turn"})
      else
        print("Not playing yet")
        local stuff = getAllObjects()
        for i, o in ipairs(stuff) do
          if o.tag == "Generic" then
            -- if there is a noises, turnButton will use it.  most of my mods
            -- gather this data about everything in the "room".
            if o.getName() == "Noises" then
              tB.noises = o.getGUID()
            -- tB.button = tB.button or o.getGUID()
            end
          end
          if o.tag == "Tile" then
            if o.name == "turnButton" then
              tB.button = o.getGUID()
            end
          end
        end
        tB.init("Black")
      end

      spellInit("0c29e8", "Wound", "http://cloud-3.steamusercontent.com/ugc/993513340528836579/C8CC80C66767752271BC7A4DA20F510CAC866CBC/")
      spellInit("27d3dd", "Stun", "http://cloud-3.steamusercontent.com/ugc/993513340528833726/9EB6FC0A8D9233428338344D7BE37C0622595BF1/")
    end -- of onLoad

    function onChat(what, who)
      if what == "\\q" then
        endGame()
        return false
      elseif what == "\\p" then -- force end of turn
        tB.pass()
        return false
      elseif what == "\\t" then -- hide/show global turnButton display
        tB.toggleGlobalPanel()
        return false
      elseif what == "\\r" then
        tB.offset = {x = 220, y = 0}
        tB.restore(tB.save())
        tB.show(tB.curPlayer, "End " .. tB.curPlayer .. "'s turn")
      end
    end -- of onChat

    function endGame()
      print("game aborted")
      playing = false
      tB.init()
      onLoad(onSave())
    end

    function sayTo(who, what) -- lazy; not used in turnButton per se.
      broadcastToAll(what, who)
    end

    require("Lua/turnButton") -- require adds a ".ttslua"
    require("Lua/createButton")

    --------------------------------------------------------------------------------
    -- these are called from the turn system if then exist
    --------------------------------------------------------------------------------
    function initGame()
      -- your mod specific code here.
      playing = true
    end -- of initGame

    --------------------------------------------------------------------------------
    function onTurnStart()
      -- your mod specific turn start actions here
      sayTo(tB.curPlayer, tB.curPlayer .. ", it is your turn.")
      tB.playNoise(3) -- a rooster sound in my bundle.
    end

    function onTurnEnd()
      -- your mod specific turn end actions here
      sayTo(tB.curPlayer, tB.curPlayer .. ", your turn is ended.")
    end
  end
)
__bundle_register(
  "Lua/turnButton",
  function(require, _LOADED, __bundle_register, __bundle_modules)
    -------------------------------------------------------------
    -- TurnButton declarations
    -------------------------------------------------------------

    -- UI work around declarations -- no post processing of UI data so have to use top level names
    function tB_start(player, value, id)
      tB.start(player, value, id)
    end

    function tB_endTurn(player, value, id)
      tB.endTurn(player, value, id)
    end

    function tB_beginMoveButton(player, value, id)
      tB.beginMoveButton(player, value, id)
    end

    function tB_endMoveUI(player, value, id)
      tB.endMoveButton(player, value, id)
    end

    function tB_toggleGlobalPanel(player, value, id)
      tB.toggleGlobalPanel(player, value, id)
    end

    ------------------------------------------------------------------------
    -- required by turnButton, but might be duplicate

    function deepCopy(original)
      if type(original) ~= "table" then
        return original
      else
        local copy = {}
        for i, v in pairs(original) do
          copy[i] = deepCopy(v)
        end
        return copy
      end
    end -- of deepCopy

    function doNothing() -- UI click function REQUIRED by turnButton
    end -- of doNothing
    -------------------------------------------------------
    -- everything else lives inside tB
    -------------------------------------------------------
    tB = {
      UITable = {}, -- Global UI
      UIIndex = 1,
      UITrigger = false, -- make true to update Global UI with UITable
      triggerIndex = nil,
      curPlayer = "Black",
      curIndex = 0,
      order = {},
      button = "b7757c", -- The noises object is as good as any to attact the turnButton
      globalPanel = true,
      offset = {x = -220, y = 0}, -- initial location of global panel relative to upper right screen corner
      noises = "b7757c", -- assetBundle with some sounds -- overridden if another generic assetrbundle is named Noises -- we use index 1 and 3.
      -- top level UI for turnButton
      -- manage details of the on-screen turnButton here.
      tbLayout = {
        tag = "Panel",
        attributes = {
          id = "turnButton",
          width = "150",
          height = "25",
          color = "#444555",
          rectAlignment = "UpperRight",
          offsetXY = "-250 0",
          allowDragging = "true",
          returnToOriginalPositionWhenReleased = "false",
          onEndDrag = "tB_endMoveButton"
        },
        children = {
          {
            tag = "Button",
            attributes = {
              id = "closeButton",
              width = "20",
              height = "20",
              rectAlignment = "UpperRight",
              color = "#990000",
              textColor = "#FFFFFF",
              text = "X",
              onClick = "tB_toggleGlobalPanel"
            }
          },
          {
            tag = "Text",
            attributes = {
              text = "Turn Button",
              alignment = "UpperLeft",
              fontSize = "18",
              offsetXY = "5 0",
              fontStyle = "Bold",
              color = "#FFFFFF"
            }
          },
          {
            tag = "GridLayout",
            attributes = {
              id = "orderList",
              columns = "1",
              width = "100%",
              cellsize = "150 25",
              rectAlignment = "TopCenter",
              offsetXY = "0 -20"
            },
            children = {}
          }
        }
      },
      -- top level UI for button; need to change to classical UI -- new UI interferes with TTS operations (UI eats clicks)
      -- Edit this table to match your specific button; this is set up to work with the noise cube I am using.
      buttonTable = {
        width = 4500,
        height = 800,
        position = {0, 0.5, 0},
        color = {0.6, 0.4, 0.3},
        hover_color = {0.5, 0.5, 0.5},
        press_color = {1, 1, 1},
        label = "Start the Game",
        font_size = 600,
        font_color = {0, 0, 0},
        click_function = "tB_start",
        function_owner = Global
      },
      -- manage the look and feel of your player buttons here
      globalXmlTable = {
        tag = "Button",
        attributes = {
          id = "playerButton",
          width = "150",
          height = "25",
          text = "Start the Game",
          fontSize = "20",
          textColor = "Black",
          colors = "#cccccc|#dddddd|#444444|#00000000",
          onClick = "tB_start"
        }
      },
      -------------------------------------------------------
      -- set up the buttons with "start the game".
      init = function()
        tB.UITable = UI.getXmlTable()
        tB.UIIndex = #tB.UITable + 1
        for i, item in ipairs(tB.UITable) do
          if item.attributes.id == "turnButton" then
            tB.UIIndex = i
            break -- shouldn't ever be more than one.
          end
        end
        -- kick off maintenance function to update once a second
        tB.triggerIndex = Wait.time(tB.updateUI, 1, -1)
        tB.show({color = "Black", text = "Start the game"})
      end, -- of initTurns
      updateUI = function()
        if tB then
          if tB.UITrigger then
            UI.setXmlTable(tB.UITable)
            tB.UITrigger = false
          end
        end
      end,
      -------------------------------------------------------
      -- configure turnButton, then call initGame
      -- currently initialize3s order to getSeatedPlayers()
      start = function(p1, p2, p3) -- either obj, color, clicktype or player, value, id and value is nil in this app
        local player = p1 -- screen UI click
        log(p1)
        log(p2)
        log(p3)
        if p3 ~= "playerButton" then -- button classic UI click
          player = Player[p2]
        end
        broadcastToAll("Game started by " .. player.color, player.color)
        tB.order =
          table.sort(
          getSeatedPlayers(),
          function(a, b)
            return Player[a].getHandTransform().rotation.y < Player[b].getHandTransform().rotation.y
          end
        )
        tB.tbLayout.attributes.height = tostring(25 * #tB.order + 25)
        tB.curIndex = math.random(#tB.order)
        tB.curPlayer = tB.order[tB.curIndex]
        tB.globalXmlTable.attributes.onClick = "tB_endTurn"
        broadcastToAll("Game started by " .. player.color, player.color)
        broadcastToAll(tB.curPlayer .. ", you are first.", tB.curPlayer)
        tB.show({color = tB.curPlayer, text = "End " .. tB.curPlayer .. "'s turn"})
        tB.playNoise(1)
        if initGame then
          initGame(player)
        end
      end, -- end of startTurns
      ----------------------------------------------------------------
      -- display turnButtons
      -- parameters are:
      --  color = current player color in order, or "Black"
      --  text = string to display in current player's button
      --
      --
      show = function(params) -- display turnButtons
        -- print("tB.show called", " ", params.color, " ", params.text )
        tB.buttonTable.font_color = params.color
        tB.buttonTable.label = params.text
        tB.buttonTable.click_function = "tB_endTurn"
        if params.color == "Black" then
          tB.buttonTable.click_function = "tB_start"
          tB.globalXmlTable.attributes.onClick = "tB_start"
          tB.globalXmlTable.attributes.textColor = "Black"
          tB.globalXmlTable.attributes.text = params.text
          tB.tbLayout.children[3].children = tB.globalXmlTable
        else
          tB.tbLayout.children[3].children = {}
          for _, player in ipairs(tB.order) do
            tB.globalXmlTable.attributes.textColor = player
            if player == params.color then
              tB.globalXmlTable.attributes.onClick = "tB_endTurn"
              tB.globalXmlTable.attributes.text = params.text
            else
              tB.globalXmlTable.attributes.onClick = "doNothing"
              tB.globalXmlTable.attributes.text = player
            end
            table.insert(tB.tbLayout.children[3].children, deepCopy(tB.globalXmlTable))
          end
        end

        if tB.globalPanel then
          -- log(string.format("offset: %8.2f %8.2f", tB.offset.x, tB.offset.y))
          -- log(tB.UIIndex)
          tB.UITable[tB.UIIndex] = deepCopy(tB.tbLayout)
        end
        tB.UITrigger = true
        local button = getObjectFromGUID(tB.button)
        button.clearButtons()
        button.createButton(tB.buttonTable)
      end, -- of show
      -- Return entry in order just after current player
      next = function()
        local ix = tB.curIndex + 1
        if ix > #tB.order then
          ix = 1
        end
        return tB.order[ix]
      end,
      -- Return entry in order just before current player
      prev = function()
        local ix = tB.curIndex - 1
        if ix < 1 then
          ix = #tB.order
        end
        return tB.order[ix]
      end, -- of prev
      -- force end of current player's turn bypassing rule that only current player may end hes or her turn.
      pass = function()
        tB.endTurn(nil)
      end, -- of passTurn
      -- Make it newPlayer's turn -- newPlayer is a color
      set = function(newPlayer)
        local p = tB.curPlayer
        tB.curPlayer = newPlayer
        for i, color in ipairs(tB.order) do
          if color == tB.curPlayer then
            broadcastToAll(tB.curPlayer .. ", it is your turn.", tB.curPlayer)
            tB.curIndex = i
            tB.show({color = tB.curPlayer, text = "End " .. tB.curPlayer .. "'s turn"})
            return
          end
        end
        print(tB.curPlayer, " is not in the player list (order)")
        tB.curPlayer = p
      end, -- of setTurn
      -- player clicked end turn
      endTurn = function(p1, p2, p3)
        --  log(p1) log(p2) log(p3)
        local color = p2
        if p3 == "playerButton" then -- from global UI
          color = color.color
        end
        if color and color ~= tB.curPlayer then
          broadcastToAll(
            (color or "nil") .. ", You cannot end another player's turn (" .. (tB.curPlayer or "nil") .. ")",
            {0.8, 0, 0}
          )
          return
        end
        if onTurnEnd then
          onTurnEnd()
        end -- call user turn end function
        tB.curIndex = tB.curIndex + 1
        if tB.curIndex > #tB.order then
          tB.curIndex = 1
        end
        tB.curPlayer = tB.order[tB.curIndex]
        tB.show({color = tB.curPlayer, text = "End " .. tB.curPlayer .. "'s turn"})
        if onTurnStart then
          onTurnStart()
        end -- call user turn start function
      end, -- of endTurn
      -- Show or hide the global UI
      toggleGlobalPanel = function()
        tB.globalPanel = not tB.globalPanel
        if tB.globalPanel then
          Global.UI.show("turnButton")
        else
          Global.UI.hide("turnButton")
        end
        return tB.globalPanel
      end, -- of toggleGlobalPanel
      -----------------------------------------------------------------------
      -- implements onSave and onLoad support
      save = function()
        local tBData = {
          order = tB.order,
          curIndex = tB.curIndex,
          curPlayer = tB.curPlayer,
          button = tB.noises, -- custom button later if we want
          globalPanel = tB.globalPanel,
          UITable = tB.UITable,
          UIIndex = tB.UIIndex,
          offset = tB.offset,
          noises = tB.noises
        }
        return tBData
      end, -- of save
      restore = function(tBData)
        if tBData then
          for k, v in pairs(tBData) do
            tB[k] = v
          end
        end
        if tB.triggerIndex then
          Wait.stop(tB.triggerIndex)
        end
        tB.triggerIndex = Wait.time(tB.updateUI, 1, -1)
      end,
      -------------------------------------------------------
      -- Utility functions
      -------------------------------------------------------
      playNoise = function(index) -- play a sound if we can.
        if tB.noises then
          local obj = getObjectFromGUID(tB.noises)
          obj.AssetBundle.playTriggerEffect(index)
        end
      end, -- of playNoise
      -------------------------------------------------------
      -- These functions are experimental and tempramental.
      -- To position your turnButton dynamically, you need to...
      -- 1.  use topDown camera
      -- 2.  set view directly over center of table
      -- 3. zoom untill table just fills screen vertically
      -- 4. adjust x and y calculations.  Only constants should be changed.
      -- 5 TEST and repeat :-)
      -------------------------------------------------------

      -------------------------------------------------------
      -- complete drag response
      endMoveUI = function(player, value, id)
        local newPos = player.getPointerPosition() -- assumes topDown view on 26x15 viewport
        log(string.format("endDrag: %8.2f %8.2f", newPos.x, newPos.z))
        local x = math.max(math.min((newPos.x - 26) * 35, 0), -1760)
        local y = math.max(math.min((newPos.z - 16) * 35, 0), -1024)
        log(string.format("%6.2f %6.2f -> %6.2f %6.2f", tB.offset.x, tB.offset.y, x, y))
        tB.offset = {x = x, y = y}
        tB.tbLayout.attributes.offsetXY = string.format("%d %d", tB.offset.x, tB.offset.y)
      end -- of endMoveTurnButton
    }

    --------------------------------------------------------------------------------
    -- END of turnButton code
    --------------------------------------------------------------------------------
  end
)
__bundle_register(
  "Lua/tools",
  function(require, _LOADED, __bundle_register, __bundle_modules)
    local seen = {}
    function dump(t, i)
      seen[t] = true
      local s = {}
      local n = 0
      for k in pairs(t) do
        n = n + 1
        s[n] = k
      end
      table.sort(s)
      for k, v in ipairs(s) do
        print(i, v)
        v = t[v]
        if type(v) == "table" and not seen[v] then
          dump(v, i .. " ") -- и вновь вернем бесполезный комментарий
        end
      end
    end
    function listvalues(xs)
      local t = { }
      for _, v in ipairs(xs) do
          t[#t+1] = tostring(v)
      end
      return table.concat(t, "\n")
    end
  end
)
__bundle_register(
  "Lua/createButtonClassicUI",
  function(require, _LOADED, __bundle_register, __bundle_modules)
    --#region Реализация через классический UI
    local xs = {}
    -- `button_click: objectOwner:userdata -> currPlayerColor:string -> ?:bool`
    function button_click(objectOwner, currPlayerColor, _)
      xs[objectOwner.guid]()
    end
    -- `_ : buttonGuid:string -> onClick:unit -> unit`
    function createButtonClassicUIInit(buttonGuid, onClick)
      local oldTable = {
        width = 4500,
        height = 800,
        position = {0, 0.5, 0},
        color = {0.6, 0.4, 0.3},
        hover_color = {0.5, 0.5, 0.5},
        press_color = {1, 1, 1},
        label = "Start the Game",
        font_size = 600,
        font_color = {0, 0, 0},
        click_function = "button_click",
        function_owner = Global
      }
      xs[buttonGuid] = onClick
      local button = getObjectFromGUID(buttonGuid)
      button.createButton(oldTable)
    end
    --#endregion
  end
)
__bundle_register(
  "Lua/createButton",
  function(require, _LOADED, __bundle_register, __bundle_modules)
    local ids = {}

    -- `player` — https://api.tabletopsimulator.com/player/
    -- `value` — onClick, onMouseEnter, onMouseExit, onMouseDown and onMouseUp all pass the click button. The values are -1 LMB, -2RMB, -3 MMB, 0 touch single, 1 double touche, 2 triple touch.
    -- `id` — атрибут `id`
    -- `_ : player:LuaPlayer -> value:string -> id:string`
    function button_click2(player, value, id)
      ids[id]()
    end

    -- <Defaults>
    --   <Button onClick="onClick" fontSize="80" fontStyle="Bold" textColor="#FFFFFF" color="#000000F0"/>
    --   <Text fontSize="80" fontStyle="Bold" color="#A3A3A3"/>
    -- </Defaults>
    -- <Panel position="0 -0 0" rotation="180 180 0" scale="3.5 3.5" >
    --   <VerticalLayout height="100" width="100">
    --   <Panel id="EXPBar" >
    --     <HorizontalLayout>
    --       <Button id="Test" fontSize="45" text="1" color="#000000F0"></Button>
    --     </HorizontalLayout>
    --   </Panel>
    --   </VerticalLayout>
    -- </Panel>

    -- `_ : buttonGuid:string -> onClick:unit -> unit`
    function createButtoninit(buttonGuid, onClick)
      -- TODO: почему-то создает гигантские кнопки, хотя всё в точности переписано
      local xmlTable = {
          {
            tag = "Defaults",
            attributes = {},
            children = {
              {
                tag = "Button",
                attributes = {
                  fontSize="80",
                  fontStyle="Bold",
                  textColor="#FFFFFF",
                  color="#FFFFFF"
                }
              },
              {
                tag = "Text",
                attributes = {
                  fontSize="80",
                  fontStyle="Bold",
                  color="#A3A3A3"
                }
              }
            }
          },
          {
            tag = "Panel",
            attributes = {
              position = "0 0 -6",
              rotation = "180 180 0",
              scale = "0.03 0.03"
            },
            children = {
              {
                tag = "VerticalLayout",
                attributes = {
                  height = "100",
                  width = "100"
                }
              },
              {
                tag = "Panel",
                attributes = {
                  id="EXPBar"
                },
                children = {
                  {
                    tag = "HorizontalLayout",
                    attributes = {},
                    children = {
                      {
                        tag = "Button",
                        attributes = {
                          id = buttonGuid,
                          fontSize = "45",
                          text = "1",
                          color = "#000000F0",
                          onClick = "Global/button_click2"
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }

      local xmlTable2 = {
        {
          tag = "Button",
          attributes = {
            id = buttonGuid,
            class = "cl",
            width = "500",
            height = "200",
            text = "Start the Game",
            fontSize = "20",
            textColor = "Black",
            -- position = "0 0.5 0",
            colors = "#cccccc|#dddddd|#444444|#00000000",
            onClick = "Global/button_click2" -- пробовал и "Global/x.button_click", и так "Global/x/button_click", и так "Global/x:button_click", но всё тщетно
          }
        }
      }

      ids[buttonGuid] = onClick
      local button = getObjectFromGUID(buttonGuid)
      -- Wait.time(function () button.UI.setXmlTable(xmlTable) end, 1, 1) -- думал, что беда может быть в тайминге, но нет
      button.UI.setXmlTable(xmlTable2)
    end

    local varnameCollisionWithObjGuid = "collisionWith" -- костыль
    local function CreateSkill(skill)
      local bzz_parameters = {}
      bzz_parameters.type = 'Custom_Token'
      bzz_parameters.scale = {x=0.26, y=0.1, z=0.26}
      bzz_parameters.rotation = {x=0, y=180, z=0}
      bzz_parameters.position = {x=0.26, y=0.1, z=0.26}
      local bzz = spawnObject(bzz_parameters)
      bzz.use_hands = true
      --bzz.setName(SkillName.." (Атака)")
      -- bzz.setName("Stun")
      bzz.setName(skill.name)
      local stats = skill.type.."\n".."Урон: ".. skill.mda * skill.spd .."\n".."Радиус: "..skill.radius
      bzz.setDescription(stats)
      local custom1 = {}
      -- custom1.image = 'http://cloud-3.steamusercontent.com/ugc/993513340528833726/9EB6FC0A8D9233428338344D7BE37C0622595BF1/'
      custom1.image = skill.imageUrl
      custom1.thickness = 0.01
      bzz.setCustomObject(custom1)
    end

    local function CheckStats(self, skillName, skillImageUrl)
      local tableId = self.getVar(varnameCollisionWithObjGuid)
      if tableId == "" or tableId == nil then
        print("Этот тайл нужно положить на лист персонажа. Если даже он лежит, то все равно пошевелите его и попробуйте снова.")
        return
      end
      local TableG = getObjectFromGUID(tableId)
      local PlayerStats = TableG.getGMNotes()
      local SelfStats = self.getDescription()

      local tofindMDA = 'MDA'
      local foundMDA = string.match(PlayerStats, tofindMDA..' ([%d-]*)')
      print(foundMDA)

      local tofindMPC = 'MPC'
      local foundMPC = string.match(PlayerStats, tofindMPC..' ([%d-]*)')
      print(foundMPC)

      local tofindCD = 'Перезарядка:'
      local foundCD = string.match(SelfStats, tofindCD..' ([%d-]*)')
      print(foundCD)

      local tofindSPD = 'Мощность:'
      local foundSPD = string.match(SelfStats, tofindSPD..' ([-+]?%d+%.?%d+)')
      print(foundSPD)

      local tofindCost = 'Стоимость:'
      local foundCost = string.match(SelfStats, tofindCost..' ([%d-]*)')
      print(foundCost)

      local tofindRange = 'Дальность:'
      local foundRange = string.match(SelfStats, tofindRange..' ([%d-]*)')
      print(foundRange)

      local tofindType = 'Тип:'
      local foundType = string.match(SelfStats, tofindType..' ([%S]*)')
      print(foundType)

      local tofindRadius = 'Область:'
      local foundRadius = string.match(SelfStats, tofindRadius..' ([%d-]*)')
      print(foundRadius)
      local skill =
        {
          name = skillName,
          imageUrl = skillImageUrl,
          mda = foundMDA,
          mpc = foundMPC,
          cd = foundCD,
          spd = foundSPD,
          cost = foundCost,
          range = foundRange,
          type = foundType,
          radius = foundRadius
        }
      local stats = getGlobalScriptTable("stats")
      print("mpc", stats.MPC)
      if stats.MPC < tonumber(foundCost) then
        print("Вася нету маны")
      else
        stats.MPC = stats.MPC - foundCost
        print(stats.MPC)
        setGlobalScriptTable("stats", stats)
        CreateSkill(skill)
      end
    end

    function spellInit(buttonGuid, skillName, skillImageUrl)
      local button = getObjectFromGUID(buttonGuid)
      -- SkillName = button.getName()
      createButtoninit(buttonGuid, function() CheckStats(button, skillName, skillImageUrl) end)

      -- Думали, что можно сделать так:
      -- ```lua
      -- button.onCollisionEnter = function(x)
      --   local guid = x.collision_object.getGUID()
      --   ...
      -- end
      -- ```
      -- А вот ни черта, приходится делать через костыль `.setLuaScript`:
      local code =
        {
          "function onCollisionEnter(x)",
          "  local guid = x.collision_object.getGUID()",
          -- "  print(guid)",
          string.format("  self.setVar(\"%s\", guid)", varnameCollisionWithObjGuid),
          "end"
        }
      button.setLuaScript(listvalues(code))
    end
  end
)

return __bundle_require("__root")
