figures = {}

function sync(player, value, id)
  figures = {}
  for k, v in pairs(getAllObjects()) do
    local script = v.getLuaScript()
    if script:find("StartXML") and not script:find("HPBarWriter") then
      table.insert(figures, {v.getName() .. " " .. v.UI.getAttribute("hpText", "Text"), v.getGUID()})
    end
  end

  local xmlTable = self.UI.getXmlTable()
  xmlTable[5].children[1].children = {}
  for k, v in pairs(figures) do
    local toAdd = {
      tag="HorizontalLayout",
      attributes={
        color= (k%2==0) and "#00000080" or "#00000000"
      },
      children={
        {
          tag="Text",
          attributes={
            id=v[2],
            text = v[1]
          }
        },
        {
          tag="Button",
          attributes={
            id="sub",
            onClick='onClick(' .. v[2] .. ")"
          },
          value="-"
        },
        {
          tag="Button",
          attributes={
            id="add",
            onClick='onClick(' .. v[2] .. ")"
          },
          value="+"
        },
      }
    }
    table.insert(xmlTable[5].children[1].children, toAdd)
  end
  xmlTable[5].children[1].attributes.height = 100 * #figures
  self.UI.setXmlTable(xmlTable)
end

function onClick(player, value, id)
  local obj = getObjectFromGUID(value)
  obj.call("onClickEx", {player = player, value = -1, id = id})
  Wait.frames(function()
    self.UI.setAttribute(value, "text", obj.getName() .. " " .. obj.UI.getAttribute("hpText", "text"))
  end, 1)
end