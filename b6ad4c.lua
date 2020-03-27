stats = {
  STR = 0,
  AGI = 0,
  INT = 0,
  PAT = 0,
  MAT = 0,
  MOV = 0,
  STA = 0,
  MAS = 0,
  SPE = 0,
  BOD = 0,
  CRT = 0,
  EVA = 0,
  REA = 0,
  PDA = 0,
  MDA = 0,
  PDF = 0,
  MDF = 0,
  HED = 0,
  HPC = 0,
  HPM = 0,
  MPC = 0,
  MPM = 0,
  EDC = 100,
  EDM = 100,
  FDC = 0,
  FDM = 10,
  EXC = 0,
  EXM = 100
}

ARM = ({"Глова", "Тело", "Живот", "Рука", "Н��га"})
ARMcount = 2
ARMfactor = 1

options = {
  HPpanel = true
}
HPinc = 1
MPinc = 1
EXinc = 1
FDinc = 1

function onLoad(save_state)
  if save_state ~= "" then
    saved_data = JSON.decode(save_state)
    if saved_data.stats then
      for stat, _ in pairs(stats) do
        stats[stat] = saved_data.stats[stat]
      end
    end
  end
  setGlobalScriptTable("stats", stats)

  Wait.time(
    function()
      countItems()
    end,
    3,
    -1
  )
  Wait.time(
    function()
      stattraker()
    end,
    3,
    -1
  )
  --Wait.time(function() findSkillInSphere() end, 3, -1)
  --Wait.time(function() countSkill() end, 1, -1)

  Wait.frames(load, 10)
  self.createInput(
    {
      value = self.getDescription(),
      input_function = "editName",
      label = "",
      function_owner = self,
      alignment = UpperLeft,
      position = {-1.59, 0.10, -1.28},
      width = 1900,
      height = 200,
      font_size = 150,
      scale = {x = 0.3, y = 0.3, z = 0.3},
      font_color = {0.5, 0.5, 0.5, 95},
      color = {0, 0, 0, 0}
    }
  )
  Namehero = self.getDescription()
end

function onUpdate()
  -- print("onupdate")
  local statsGlobal = getGlobalScriptTable("stats")
  local isChanged = false
  for k, v in pairs(stats) do
    if v ~= statsGlobal[k] then
      stats[k] = statsGlobal[k]
      isChanged = true
    end
  end
  if isChanged then
    stattraker()
    load()
  end
end

function load()
  self.UI.setAttribute("HPProg", "percentage", stats.HPC / stats.HPM * 100)
  self.UI.setAttribute("HPText", "text", stats.HPC .. "/" .. stats.HPM)
  self.UI.setAttribute("MPProg", "percentage", stats.MPC / stats.MPM * 100)
  self.UI.setAttribute("MPText", "text", stats.MPC .. "/" .. stats.MPM)
  self.UI.setAttribute("STAProg", "percentage", stats.EDC / stats.EDM * 100)
  self.UI.setAttribute("STAText", "text", stats.EDC .. "/" .. stats.EDM)
  self.UI.setAttribute("FODProg", "percentage", stats.FDC / stats.FDM * 100)
  self.UI.setAttribute("FODText", "text", stats.FDC .. "/" .. stats.FDM)
  self.UI.setAttribute("EXPProg", "percentage", stats.EXC / stats.EXM * 100)
  self.UI.setAttribute("EXPText", "text", stats.EXC .. "/" .. stats.EXM)
  self.UI.setAttribute("HPinc", "text", HPinc)
  self.UI.setAttribute("ARM", "text", ARM[ARMcount])
  self.UI.setAttribute("ARM", "textColor", "#FFFFFF")
end
function onEndEdit(player, value, id)
  HPinc = value
  MPinc = value
  FDinc = value
  EXinc = value
end
function editName(_obj, _string, value)
  self.setDescription(value)
end
function onClick(player, value, id)
  if id == "HPEdit" then
    --Множитель урона от части тела
    if self.UI.getAttribute("HPpanel", "active") == "False" or self.UI.getAttribute("HPpanel", "active") == nil then
      self.UI.setAttribute("ECDpanel", "active", false)
      self.UI.setAttribute("HPpanel", "active", true)
      self.UI.setAttribute("MPpanel", "active", false)
      self.UI.setAttribute("FODpanel", "active", false)
      self.editInput({index = 0, value = self.getDescription(), position = {-1.59, 0.00, -1.28}, tooltip = ttText})
    else
      self.UI.setAttribute("HPpanel", "active", false)
      self.editInput({index = 0, value = self.getDescription(), position = {-1.59, 0.10, -1.28}, tooltip = ttText})
    end
  elseif id == "ARMsub" then
    if ARMcount == 1 then
      ARMcount = 5
    else
      ARMcount = ARMcount - 1
    end
  elseif id == "ARMadd" then
    if ARMcount == 5 then
      ARMcount = 1
    else
      ARMcount = ARMcount + 1
    end
    if ARMcount == 1 then
      ARMfactor = 1.5
    elseif ARMcount == 2 then
      ARMfactor = 1
    elseif ARMcount == 3 then
      ARMfactor = 0.9
    elseif ARMcount == 4 then
      ARMfactor = 0.75
    elseif ARMcount == 5 then
      ARMfactor = 0.5
    end
  elseif id == "PD" then
    --Срезаем урон на % от брони PDF/10 = % От брони, округляем до целого
    HPproc = (HPinc * (stats.PDF / 10)) / 100
    PDFincHP = HPinc - HPproc
    if (PDFincHP - (PDFincHP % 0.1)) - (PDFincHP - (PDFincHP % 1)) < 0.5 then
      PDFincHP = PDFincHP - (PDFincHP % 1)
    else
      PDFincHP = PDFincHP - (PDFincHP % 1) + 1
    end
    --Добавляем множитель от части тела
    HProun = PDFincHP * ARMfactor
    --Округление полученного урона д�������������������������������������������� ц��лого значения
    if (HProun - (HProun % 0.1)) - (HProun - (HProun % 1)) < 0.5 then
      HProun = HProun - (HProun % 1)
    else
      HProun = HProun - (HProun % 1) + 1
    end
    --Проверяем выдержала ли бр��ня (сравнение)
    HPchec = HPinc * ARMfactor
    --Нужно писать ник игрока в поле Имя игрока
    if HPchec <= (stats.PDF / 10) then
      print("Броня ", player.steam_name, "(", Namehero, ")", "(a)", " выдержала удар")
    else
      print(player.steam_name, "(", Namehero, ")", " получил ", HProun, " Ф.урона ", " в ", ARM[ARMcount])
      stats.HPC = stats.HPC - HProun
    end
  elseif id == "MD" then
    --Срезаем урон на % от брони MDF/10 = % От брони
    HPproc = (HPinc * (stats.MDF / 10)) / 100
    MDFincHP = HPinc - HPproc
    --Д��бавляем множитель от части тела
    HProun = MDFincHP * ARMfactor
    --Округле��ие полученного урона до целого значения
    if (HProun - (HProun % 0.1)) - (HProun - (HProun % 1)) < 0.5 then
      HProun = HProun - (HProun % 1)
    else
      HProun = HProun - (HProun % 1) + 1
    end
    --Проверяем выдeржала ли броня (сравнение)
    HPchec = HPinc * ARMfactor
    --Нужно писать н��к игрока в поле Имя игрока
    if HPchec <= (stats.MDF / 10) then
      print("Броня ", player.steam_name, "(a)", " выдержала удар")
    else
      print(player.steam_name, "(", Namehero, ")", " получил ", HProun, " М.урона ", " в ", ARM[ARMcount])
      stats.HPC = stats.HPC - HProun
    end
  elseif id == "CD" then
    --Срезаем урон н�������� % о�� брони PDF/10 = % От б��о��и
    PDFincHP = HPinc
    --Добавляем множитель от части тела
    HProun = PDFincHP
    --Округление полученного урона до целого значени��
    if (HProun - (HProun % 0.1)) - (HProun - (HProun % 1)) < 0.5 then
      HProun = HProun - (HProun % 1)
    else
      HProun = HProun - (HProun % 1) + 1
    end
    --Нужно писать ник игрока в поле Имя игрока
    print(player.steam_name, "(", Namehero, ")", " получил ", HProun, " Ч.урона ")
    stats.HPC = stats.HPC - HProun
    --Проверка смерти игрока
    if stats.HPC < 1 then
      print(player.steam_name, "(", Namehero, ")", (Namehero), "Помер")
    end
  end
  if id == "MPEdit" then
    if self.UI.getAttribute("MPpanel", "active") == "False" or self.UI.getAttribute("MPpanel", "active") == nil then
      self.UI.setAttribute("MPpanel", "active", true)
      self.UI.setAttribute("ECDpanel", "active", false)
      self.UI.setAttribute("HPpanel", "active", false)
      self.UI.setAttribute("FODpanel", "active", false)
    else
      self.UI.setAttribute("MPpanel", "active", false)
    end
  elseif id == "MDi" then
    print(player.steam_name, "(", Namehero, ")", " п�����тр��тил ", MPinc, " маны ")
    stats.MPC = stats.MPC - MPinc
  end
  if id == "STAEdit" then
    if self.UI.getAttribute("ECDpanel", "active") == "False" or self.UI.getAttribute("ECDpanel", "active") == nil then
      self.UI.setAttribute("ECDpanel", "active", true)
      self.UI.setAttribute("HPpanel", "active", false)
      self.UI.setAttribute("MPpanel", "active", false)
      self.UI.setAttribute("FODpanel", "active", false)
    else
      self.UI.setAttribute("ECDpanel", "active", false)
    end
  elseif id == "PATB" then
    stats.EDC = stats.EDC - stats.PAT
  elseif id == "MATB" then
    stats.EDC = stats.EDC - stats.MAT
  elseif id == "MOVB" then
    stats.EDC = stats.EDC - stats.MOV
  elseif id == "STAC" then
    stats.EDC = 100
  end
  if id == "FODEdit" then
    if self.UI.getAttribute("FODpanel", "active") == "False" or self.UI.getAttribute("FODpanel", "active") == nil then
      self.UI.setAttribute("ECDpanel", "active", false)
      self.UI.setAttribute("HPpanel", "active", false)
      self.UI.setAttribute("MPpanel", "active", false)
      self.UI.setAttribute("FODpanel", "active", true)
    else
      self.UI.setAttribute("FODpanel", "active", false)
    end
  elseif id == "FDi" then
    print(player.steam_name, "(", Namehero, ")", " проголодалня на ", FDinc)
    stats.FDC = stats.FDC - FDinc
  end
  if id == "EXPEdit" then
    if self.UI.getAttribute("EXPpanel", "active") == "False" or self.UI.getAttribute("EXPpanel", "active") == nil then
      self.UI.setAttribute("EXPpanel", "active", true)
    else
      self.UI.setAttribute("EXPpanel", "active", false)
    end
  elseif id == "EXi" then
    if stats.EXC == stats.EXM then
      stats.EXC = 0
      print(player.steam_name, "(", Namehero, ")", " получил новый уровень")
    else
      stats.EXC = stats.EXC + EXinc
      print(player.steam_name, "(", Namehero, ")", " получил ", EXinc, " опыта")
    end
  end
  setGlobalScriptTable("stats", stats)
  load()
  stattraker()
end
function onSave()
  local save_state = JSON.encode({stats = stats})
  self.script_state = save_state
end

function countItems()
  local totalAGI = 0
  local itemsInBowl = findItemsInSphere()
  for _, entry in ipairs(itemsInBowl) do
    if entry.hit_object ~= self then
      local descAGI1 = entry.hit_object.getDescription()
      AGI = 0
      local tofind = "ловкость"
      local found = string.match(descAGI1, tofind .. " [%d-]*")
      if (found ~= nil) then
        AGI = string.sub(found, string.len(tofind) + 2)
      end
      if descAGI ~= nil then
        totalAGI = totalAGI + descAGI
      else
        totalAGI = totalAGI + AGI
      end
      --Присваеваем значение ��окальн��й переменной общей переменной для дальнейшего использования в других скриптах
      stats.AGI = totalAGI
    end
  end
  local totalSTR = 0
  for _, entry in ipairs(itemsInBowl) do
    if entry.hit_object ~= self then
      local descSTR1 = entry.hit_object.getDescription()
      STR = 0
      local tofind = "сила"
      local found = string.match(descSTR1, tofind .. " [%d-]*")
      if (found ~= nil) then
        STR = string.sub(found, string.len(tofind) + 2)
      end
      if descSTR ~= nil then
        totalSTR = totalSTR + descSTR
      else
        totalSTR = totalSTR + STR
      end
      --Присваеваем значени���� локальной переменной общей переменной ��ля дальнейшего использования в других скриптах
      stats.STR = totalSTR
    end
  end
  local totalINT = 0
  for _, entry in ipairs(itemsInBowl) do
    if entry.hit_object ~= self then
      local descINT1 = entry.hit_object.getDescription()
      INT = 0
      local tofind = "интелект"
      local found = string.match(descINT1, tofind .. " [%d-]*")
      if (found ~= nil) then
        INT = string.sub(found, string.len(tofind) + 2)
      end
      if descINT ~= nil then
        totalINT = totalINT + descINT
      else
        totalINT = totalINT + INT
      end
      --Присваеваем значение лок��льной переменной общей переменной для дальнейшего использования в других скриптах
      stats.INT = totalINT
    end
  end
  local totalPAT = 0
  for _, entry in ipairs(itemsInBowl) do
    if entry.hit_object ~= self then
      local descPAT1 = entry.hit_object.getDescription()
      PAT = 0
      local tofind = "ф.атака"
      local found = string.match(descPAT1, tofind .. " [%d-]*")
      if (found ~= nil) then
        PAT = string.sub(found, string.len(tofind) + 2)
      end
      if descPAT ~= nil then
        totalPAT = totalPAT + descPAT
      else
        totalPAT = totalPAT + PAT
      end
      --Присваеваем значение локальной переменной общей переменной для дальнейшего ис��ользования в других скриптах
      stats.PAT = totalPAT
    end
  end
  local totalMAT = 0
  for _, entry in ipairs(itemsInBowl) do
    if entry.hit_object ~= self then
      local descMAT1 = entry.hit_object.getDescription()
      MAT = 0
      local tofind = "м.атака"
      local found = string.match(descMAT1, tofind .. " [%d-]*")
      if (found ~= nil) then
        MAT = string.sub(found, string.len(tofind) + 2)
      end
      if descMAT ~= nil then
        totalMAT = totalMAT + descMAT
      else
        totalMAT = totalMAT + MAT
      end
      --Присваеваем значение локальной переменной общей переменной для дальнейшего использования в других скриптах
      stats.MAT = totalMAT
    end
  end
  local totalMOV = 0
  for _, entry in ipairs(itemsInBowl) do
    if entry.hit_object ~= self then
      local descMOV1 = entry.hit_object.getDescription()
      MOV = 0
      local tofind = "подвижность"
      local found = string.match(descMOV1, tofind .. " [%d-]*")
      if (found ~= nil) then
        MOV = string.sub(found, string.len(tofind) + 2)
      end
      if descMOV ~= nil then
        totalMOV = totalMOV + descMOV
      else
        totalMOV = totalMOV + MOV
      end
      --П���������исваеваем значение локальной переменной общей переменной для дальнейшего использования в других скриптах
      stats.MOV = totalMOV
    end
  end
  local totalSTA = 0
  for _, entry in ipairs(itemsInBowl) do
    if entry.hit_object ~= self then
      local descSTA1 = entry.hit_object.getDescription()
      STA = 0
      local tofind = "выносливость"
      local found = string.match(descSTA1, tofind .. " [%d-]*")
      if (found ~= nil) then
        STA = string.sub(found, string.len(tofind) + 2)
      end
      if descSTA ~= nil then
        totalSTA = totalSTA + descSTA
      else
        totalSTA = totalSTA + STA
      end
      --Присваеваем значение ло��аль��ой переменной обще�� переменной для дальнейшего использования в других ск��иптах
      stats.STA = totalSTA
    end
  end
  local totalMAS = 0
  for _, entry in ipairs(itemsInBowl) do
    if entry.hit_object ~= self then
      local descMAS1 = entry.hit_object.getDescription()
      MAS = 0
      local tofind = "искусность"
      local found = string.match(descMAS1, tofind .. " [%d-]*")
      if (found ~= nil) then
        MAS = string.sub(found, string.len(tofind) + 2)
      end
      if descMAS ~= nil then
        totalMAS = totalMAS + descMAS
      else
        totalMAS = totalMAS + MAS
      end
      --Присваеваем значение локальной переменно�� общей переменной для дальнейшего использования в других скриптах
      stats.MAS = totalMAS
    end
  end
  local totalSPE = 0
  for _, entry in ipairs(itemsInBowl) do
    if entry.hit_object ~= self then
      local descSPE1 = entry.hit_object.getDescription()
      SPE = 0
      local tofind = "красноречие"
      local found = string.match(descSPE1, tofind .. " [%d-]*")
      if (found ~= nil) then
        SPE = string.sub(found, string.len(tofind) + 2)
      end
      if descSPE ~= nil then
        totalSPE = totalSPE + descSPE
      else
        totalSPE = totalSPE + SPE
      end
      --Присва��ваем значение локальной переменной общей переменной д��я дальнейшего использования в других скриптах
      stats.SPE = totalSPE
    end
  end
  local totalBOD = 0
  for _, entry in ipairs(itemsInBowl) do
    if entry.hit_object ~= self then
      local descBOD1 = entry.hit_object.getDescription()
      BOD = 0
      local tofind = "телосложение"
      local found = string.match(descBOD1, tofind .. " [%d-]*")
      if (found ~= nil) then
        BOD = string.sub(found, string.len(tofind) + 2)
      end
      if descBOD ~= nil then
        totalBOD = totalBOD + descBOD
      else
        totalBOD = totalBOD + BOD
      end
      --Присваеваем значение лок��льной переменной общей переменной для дальнейшего использования в других скриптах
      stats.BOD = totalBOD
    end
  end
  local totalCRT = 0
  for _, entry in ipairs(itemsInBowl) do
    if entry.hit_object ~= self then
      local descCRT1 = entry.hit_object.getDescription()
      CRT = 0
      local tofind = "крит"
      local found = string.match(descCRT1, tofind .. " [%d-]*")
      if (found ~= nil) then
        CRT = string.sub(found, string.len(tofind) + 2)
      end
      if descCRT ~= nil then
        totalCRT = totalCRT + descCRT
      else
        totalCRT = totalCRT + CRT
      end
      --Присваеваем значение локальной переменной общей переменной для дальнейшего использования в других скриптах
      stats.CRT = totalCRT
    end
  end
  local totalEVA = 0
  for _, entry in ipairs(itemsInBowl) do
    if entry.hit_object ~= self then
      local descEVA1 = entry.hit_object.getDescription()
      EVA = 0
      local tofind = "уклонение"
      local found = string.match(descEVA1, tofind .. " [%d-]*")
      if (found ~= nil) then
        EVA = string.sub(found, string.len(tofind) + 2)
      end
      if descEVA ~= nil then
        totalEVA = totalEVA + descEVA
      else
        totalEVA = totalEVA + EVA
      end
      --При���������������������������������������������������аеваем з��������������������������������������ачение локальной переменной общей переменной для дальнейшего использования в других скриптах
      stats.EVA = totalEVA
    end
  end
  local totalREA = 0
  for _, entry in ipairs(itemsInBowl) do
    if entry.hit_object ~= self then
      local descREA1 = entry.hit_object.getDescription()
      REA = 0
      local tofind = "чтение"
      local found = string.match(descREA1, tofind .. " [%d-]*")
      if (found ~= nil) then
        REA = string.sub(found, string.len(tofind) + 2)
      end
      if descREA ~= nil then
        totalREA = totalREA + descREA
      else
        totalREA = totalREA + REA
      end
      --При��ваева������м значение лока������ь����ой переменной об������ей переменной для дальнейшего ис������о������������������ьзования в других скриптах
      stats.REA = totalREA
    end
  end
  local totalPDA = 0
  for _, entry in ipairs(itemsInBowl) do
    if entry.hit_object ~= self then
      local descPDA1 = entry.hit_object.getDescription()
      PDA = 0
      local tofind = "ф.урон"
      local found = string.match(descPDA1, tofind .. " [%d-]*")
      if (found ~= nil) then
        PDA = string.sub(found, string.len(tofind) + 2)
      end
      if descPDA ~= nil then
        totalPDA = totalPDA + descPDA
      else
        totalPDA = totalPDA + PDA
      end
      --Присваеваем значени���� локаль����ой переменной общей переменной для дальнейшего использования в других скриптах
      stats.PDA = totalPDA
    end
  end
  local totalMDA = 0
  for _, entry in ipairs(itemsInBowl) do
    if entry.hit_object ~= self then
      local descMDA1 = entry.hit_object.getDescription()
      MDA = 0
      local tofind = "м.урон"
      local found = string.match(descMDA1, tofind .. " [%d-]*")
      if (found ~= nil) then
        MDA = string.sub(found, string.len(tofind) + 2)
      end
      if descMDA ~= nil then
        totalMDA = totalMDA + descMDA
      else
        totalMDA = totalMDA + MDA
      end
      --Присв����еваем зна��ение локальной перемен��ой общей переменной для дальнейшего использования в других скриптах
      stats.MDA = totalMDA
    end
  end
  local totalPDF = 0
  for _, entry in ipairs(itemsInBowl) do
    if entry.hit_object ~= self then
      local descPDF1 = entry.hit_object.getDescription()
      PDF = 0
      local tofind = "защита"
      local found = string.match(descPDF1, tofind .. " [%d-]*")
      if (found ~= nil) then
        PDF = string.sub(found, string.len(tofind) + 2)
      end
      if descPDF ~= nil then
        totalPDF = totalPDF + descPDF
      else
        totalPDF = totalPDF + PDF
      end
      --Присваеваем значение локальной перемен��ой общей переменной для дальнейшего использования в других скриптах
      stats.PDF = totalPDF
    end
  end
  local totalMDF = 0
  for _, entry in ipairs(itemsInBowl) do
    if entry.hit_object ~= self then
      local descMDF1 = entry.hit_object.getDescription()
      MDF = 0
      local tofind = "сопротивление"
      local found = string.match(descMDF1, tofind .. " [%d-]*")
      if (found ~= nil) then
        MDF = string.sub(found, string.len(tofind) + 2)
      end
      if descMDF ~= nil then
        totalMDF = totalMDF + descMDF
      else
        totalMDF = totalMDF + MDF
      end
      --Присваева����м значение локальной переменной общей переменной д��я дальн��йшего использования в других ��криптах
      stats.MDF = totalMDF
    end
  end
  local totalHED = 0
  for _, entry in ipairs(itemsInBowl) do
    if entry.hit_object ~= self then
      local descHED1 = entry.hit_object.getDescription()
      HED = 0
      local tofind = "вес"
      local found = string.match(descHED1, tofind .. " [%d-]*")
      if (found ~= nil) then
        HED = string.sub(found, string.len(tofind) + 2)
      end
      if descHED ~= nil then
        totalHED = totalHED + descHED
      else
        totalHED = totalHED + HED
      end
      --Присваеваем значение локальной пере����енной общей переменной для дальнейшего использования в других скриптах
      stats.HED = totalHED
    end
  end
  local totalHPM = 0
  for _, entry in ipairs(itemsInBowl) do
    if entry.hit_object ~= self then
      local descHPM1 = entry.hit_object.getDescription()
      HPM = 0
      local tofind = "здоровье"
      local found = string.match(descHPM1, tofind .. " [%d-]*")
      if (found ~= nil) then
        HPM = string.sub(found, string.len(tofind) + 2)
      end
      if descHPM ~= nil then
        totalHPM = totalHPM + descHPM
      else
        totalHPM = totalHPM + HPM
      end
      --П��исваеваем значение л��кальной переменной об��ей переменной дл�� дальнейшего использования �� других скриптах
      stats.HPM = totalHPM
    end
  end
  local totalMPM = 0
  for _, entry in ipairs(itemsInBowl) do
    if entry.hit_object ~= self then
      local descMPM1 = entry.hit_object.getDescription()
      MPM = 0
      local tofind = "мана"
      local found = string.match(descMPM1, tofind .. " [%d-]*")
      if (found ~= nil) then
        MPM = string.sub(found, string.len(tofind) + 2)
      end
      if descMPM ~= nil then
        totalMPM = totalMPM + descMPM
      else
        totalMPM = totalMPM + MPM
      end
      --Присваеваем значение локальной переменной общей переменной для дальнейшего использования в других скриптах
      stats.MPM = totalMPM
    end
  end
  setGlobalScriptTable("stats", stats)
end
--[[function countSkill()
    local totalHED = 0
    local itemsInBowl = findSkillInSphere()
    for _, entry in ipairs(itemsInBowl) do
      if entry.hit_object ~= self and entry.hit_object.tag ~= "Surface" then
		  local descHED1 = entry.hit_object.getDescription()
      local tableEntry = entry.hit_object.getGUID()
      Skill = getObjectFromGUID(tableEntry)
      print(descHED1)
      HED = 0
      local tofind = 'Мощность: [b]'
      local found = string.match(descHED1,tofind..' [%d-]*')
        print(found)
        if (found ~= nil) then
          HED = string.sub(found,string.len(tofind)+2)
          print(HED)
        end
        if descHED ~= nil then
            totalHED = 0
        else
          totalHED = stats.MDA * HED
          if totalHED ==  stats.MPC then
          Testto = Skill.setColorTint({r = 0.333287, g = 0.232323, b = 0.987805, a = 1})
        else
          Testto = Skill.setColorTint({r = 1, g = 1, b = 1, a = 1})
        end
          --print("Значенние скила: ", HED)
        --  print("Умноженое значение: ", totalHED)
      end
      --Присваеваем значение локальной переменной общей переменной для дальнейшего использования в других скриптах
      stats.HED = totalHED

    end
	end
end]]
--П����дсчитываем ��се характеристики персонажа с учетом скалирован��я
function stattraker()
  --Обновляем значение ��а интерфейсе
  self.UI.setAttribute("AGI", "text", stats.AGI)
  self.UI.setAttribute("STR", "text", stats.STR)
  self.UI.setAttribute("INT", "text", stats.INT)
  self.UI.setAttribute("PAT", "text", stats.PAT)
  self.UI.setAttribute("MAT", "text", stats.MAT)
  self.UI.setAttribute("MOV", "text", stats.MOV)
  self.UI.setAttribute("STA", "text", stats.STA)
  self.UI.setAttribute("MAS", "text", stats.MAS)
  self.UI.setAttribute("SPE", "text", stats.SPE)
  self.UI.setAttribute("BOD", "text", stats.BOD)
  self.UI.setAttribute("CRT", "text", stats.CRT)
  self.UI.setAttribute("EVA", "text", stats.EVA)
  self.UI.setAttribute("REA", "text", stats.REA)
  self.UI.setAttribute("PDA", "text", stats.PDA)
  self.UI.setAttribute("MDA", "text", stats.MDA)
  self.UI.setAttribute("PAT", "text", stats.PAT)
  self.UI.setAttribute("MAT", "text", stats.MAT)
  self.UI.setAttribute("PDF", "text", stats.PDF)
  self.UI.setAttribute("MDF", "text", stats.MDF)
  --self.UI.setAttribute("HED", "text", stats.HED)
  if stats.HPC > stats.HPM then
    stats.HPC = stats.HPM
  end
  if stats.HPC < 0 then
    stats.HPC = 0
  end
  self.UI.setAttribute("HPProg", "percentage", stats.HPC / stats.HPM * 100)
  self.UI.setAttribute("HPText", "text", stats.HPC .. "/" .. stats.HPM)
  self.UI.setAttribute("MPProg", "percentage", stats.MPC / stats.MPM * 100)
  self.UI.setAttribute("MPText", "text", stats.MPC .. "/" .. stats.MPM)
  GMSets = "MDA " .. stats.MDA .. " MPC " .. stats.MPC
  self.setDescription("MDA ", stats.MDA, " MPC ", stats.MPC)
  self.setGMNotes(GMSets)
end

function findItemsInSphere()
  local scale = self.getScale()
  local pos = self.getPosition()
  pos.y = pos.y
  pos.x = pos.x - 1.8
  pos.z = pos.z - 2
  return Physics.cast(
    {
      origin = pos,
      direction = {0, 1, 0},
      type = 3,
      max_distance = 0.1,
      size = {scale.x + 1.2, scale.y, scale.z + 6.5} --debug=true
    }
  )
end
function findSkillInSphere()
  local scale = self.getScale()
  local pos = self.getPosition()
  pos.y = pos.y
  pos.x = pos.x + 9.2
  pos.z = pos.z + 7.6
  return Physics.cast(
    {
      origin = pos,
      direction = {0, 1, 0},
      type = 3,
      max_distance = 0.1,
      size = {scale.x + 6.5, scale.y, scale.z - 5} --debug=true
    }
  )
end
