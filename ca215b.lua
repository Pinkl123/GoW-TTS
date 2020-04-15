function onCollisionEnter(x)
  Token = x.collision_object.getGUID()
  Name = x.collision_object.getName()
  Description = x.collision_object.getDescription()
  Skill = getObjectFromGUID(Token)
  load()
end

function load()
  self.UI.setAttribute("Name", "text", Name)
  self.UI.setAttribute("Description", "text", Description)
  print(Tester2)
end

function Type(player, option, id)
  a1 = "Тип "..option
  print(a1)
end
function Var(player, option, id)
  a2 = "Вариативность "..option
  print(a2)
end
function App(player, option, id)
  a3 = "Примерение "..option
  print(a3)
end
function Dem(player, option, id)
  a4 = "Требования "..option
  print(a4)
end
function Mod(player, option, id)
  a5 = "Модификатор "..option
  print(a5)
end
function Soc(player, option, id)
  c5 = "Школа "..option
  print(c5)
end

function onClick(player, value, id, x, option)
  if id == "Create" then
    SPD = self.UI.getAttribute("SPD", "Text")
    b1 = "Сила заклинания "..SPD
    PPD = self.UI.getAttribute("PPD", "Text")
    b2 = "Переодический урон "..PPD
    PPD = self.UI.getAttribute("PPD", "Text")
    b2 = "Переодический урон "..PPD
    Del = self.UI.getAttribute("Del", "Text")
    b3 = "Отложеность "..Del
    Ran = self.UI.getAttribute("Ran", "Text")
    b4 = "Дальность "..Ran
    Rad = self.UI.getAttribute("Rad", "Text")
    b5 = "Радиус "..Rad
    Cos = self.UI.getAttribute("Cos", "Text")
    c1 = "Стоимость "..Cos
    ToA = self.UI.getAttribute("ToA", "Text")
    c2 = "Время действия "..ToA
    NoA = self.UI.getAttribute("NoA", "Text")
    c3 = "Количество применения "..NoA
    Cda = self.UI.getAttribute("Cda", "Text")
    c4 = "Перезарядка "..Cda

    Exit = string.char(13)..string.char(10)..a1..string.char(13)..string.char(10)..a2..string.char(13)..string.char(10)..a3..string.char(13)..string.char(10)..a4..string.char(13)..string.char(10)..a5
    Exit = Exit..string.char(13)..string.char(10)..b1..string.char(13)..string.char(10)..b2..string.char(13)..string.char(10)..b3..string.char(13)..string.char(10)..b4..string.char(13)..string.char(10)..b5
    Exit = Exit..string.char(13)..string.char(10)..c1..string.char(13)..string.char(10)..c2..string.char(13)..string.char(10)..c3..string.char(13)..string.char(10)..c4..string.char(13)..string.char(10)..c5
    Skill.setGMNotes(Exit)
    Names = self.UI.getAttribute("Name", "text")
    Names = "[A3A3A3]"..Names.."[]"
    Skill.setName(Names)
end
end