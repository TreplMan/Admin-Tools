local imgui = require 'imgui'
local imguiad = require 'lib.imgui_addons'
local encoding = require 'encoding'
local dlstatus = require("moonloader").download_status
local fa = require 'fAwesome5'
local vkeys = require 'vkeys'
local rkeys = require 'lib.rkeys'
local samp = require 'lib.samp.events'
local inicfg = require 'inicfg'
encoding.default = 'CP1251'
u8 = encoding.UTF8




--bool
local AdminTools = imgui.ImBool(false)
--int
local sessionOnline = imgui.ImInt(0)
local sessionAfk = imgui.ImInt(0)
local sessionFull = imgui.ImInt(0)

--others
local stColor = 0xFFFF0000


function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

filename_settings = getWorkingDirectory() .. "\\config\\hotKeys.txt"

local Luacfg = {
    _version = "9"
}
setmetatable(Luacfg, {
    __call = function(self)
        return self.__init()
    end
})
function Luacfg.__init()
    local self = {}
    local lfs = require "lfs"
    local inspect = require "inspect"


    function self.mkpath(filename)
        local sep, pStr = package.config:sub(1, 1), ""
        local path = filename:match("(.+"..sep..").+$") or filename
        for dir in path:gmatch("[^" .. sep .. "]+") do
            pStr = pStr .. dir .. sep
            lfs.mkdir(pStr)
        end
    end


    function self.load(filename, tbl)
        local file = io.open(filename, "r")
        if file then
            local text = file:read("*all")
            file:close()

            local lua_code = loadstring("return "..text)
            if lua_code then
                loaded_tbl = lua_code()

                if type(loaded_tbl) == "table" then
                    for key, value in pairs(loaded_tbl) do
                        tbl[key] = value
                    end
                    return true
                else
                    return false
                end
            else
                return false
            end
        else
            return false
        end
    end

      function self.save(filename, tbl)
          self.mkpath(filename)

          local file = io.open(filename, "w+")
          if file then
              file:write(inspect(tbl))
              file:close()
              return true
          else
              return false
          end
      end

    return self
end

luacfg = Luacfg()
cfg = {
    LeaveReconWindow = {vkeys.VK_M},
    openHomeWindow = {vkeys.VK_NUMPAD1},
    activeChatBubble = {vkeys.VK_NUMPAD2},
    openAutoReport = {vkeys.VK_NUMPAD3},
    enabledTracers = {vkeys.VK_NUMPAD4},
	Alock = {vkeys.VK_INSERT},
	DelVeh = {vkeys.VK_DELETE}
}

luacfg.load(filename_settings, cfg)
luacfg.save(filename_settings, cfg)

local ofHotkeys = {
    LeaveReconWindow = {v = deepcopy(cfg.LeaveReconWindow)},
    openHomeWindow = {v = deepcopy(cfg.openHomeWindow)},
    activeChatBubble = {v = deepcopy(cfg.activeChatBubble)},
    openAutoReport = {v = deepcopy(cfg.openAutoReport)},
    enabledTracers = {v = deepcopy(cfg.enabledTracers)},
	Alock = {v = deepcopy(cfg.Alock)},
	DelVeh = {v = deepcopy(cfg.DelVeh)}
}

local HLcfg = inicfg.load({
    config = {
        dayReports = 0,
        dayForms = 0,
    },

    admSetting = {
        admNick = "",
        admlvl = 0,
        adminPassword = "",
        showAdminPassword = false,
        autoCome = false,
        Password = "",
        showPassword = false,
        autoCome2 = false,
    },
    Count = {
        ban = 0,
        iban = 0,
        warn = 0,
        offwarn = 0,
        mute = 0,
        rmute = 0,
        prison = 0,
        kick = 0,
        forms = 0,
        reports = 0,
        Online = 0,
        AFK = 0,
    },
    onDay = {
		today = os.date("%a"),
		online = 0,
		afk = 0,
		full = 0,
	},


}, "ATConfig.ini")
inicfg.save(HLcfg, "ATConfig.ini")
local nowTime = os.date("%H:%M:%S", os.time())
local dayFull = imgui.ImInt(HLcfg.onDay.full)
local LsessionForma = 0
local LsessionReport = 0
local elements = {
    checkbox = {
        autoCome = imgui.ImBool(HLcfg.admSetting.autoCome),
        autoCome2 = imgui.ImBool(HLcfg.admSetting.autoCome2),
        showAdminPassword = imgui.ImBool(HLcfg.admSetting.showAdminPassword),
        showPassword = imgui.ImBool(HLcfg.admSetting.showPassword),
    },
    int = {

    },
    input = {
        adminPassword = imgui.ImBuffer(tostring(HLcfg.admSetting.adminPassword), 50),
        Password = imgui.ImBuffer(tostring(HLcfg.admSetting.Password), 50),
        admNick = imgui.ImBuffer(tostring(HLcfg.admSetting.admNick), 50),
        admlvl = imgui.ImBuffer(tostring(HLcfg.admSetting.admlvl), 50),
    },
}

local fa_font = nil
local fontsize10 = nil
local fontsize15 = nil
local fontsize20 = nil
local fontsize30 = nil
local fontsize50 = nil
local fa_glyph_ranges = imgui.ImGlyphRanges({ fa.min_range, fa.max_range })
function imgui.BeforeDrawFrame()
    if fa_font == nil then
        local font_config = imgui.ImFontConfig()
        font_config.MergeMode = true
        fa_font = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/Config/ATConfig/fonts/fa-solid-900.ttf', 15.0, font_config, fa_glyph_ranges)
        if fontsize30 == nil and fontsize20 == nil and fontsize50 == nil then
            fontsize10 = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\trebucbd.ttf', 10.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
            fontsize15 = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\trebucbd.ttf', 15.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
            fontsize20 = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\trebucbd.ttf', 20.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
            fontsize30 = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\trebucbd.ttf', 30.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic()) -- вместо 30 любой нужный размер
            fontsize50 = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\trebucbd.ttf', 50.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
        end
    end
end

--update
local version_int = 1
local update_url = "https://raw.githubusercontent.com/TreplMan/SampScripts/main/update.ini"
local update_path = getWorkingDirectory().."/update.ini"
local script_url = "" --ссылка на обновленный файл
local script_path = thisScript().path
local update = false
local start_update = false

function main()
    while not isSampAvailable() do wait(200) end
    sampAddChatMessage('{FF0000}[AdminTools] {FF8C00}Скрипт был инициализирован. (by Mason_Baker)', stColor)
	sampAddChatMessage('{FF0000}[AdminTools] {FF8C00}Активация скрипта - /rh', stColor)
    --Проверка наличия обновления
    downloadUrlToFile(update_url, update_path, function(id, status)
        if status == dlstatus.STATUS_ENDDOWNLOADDATA then
            updateIni = inicfg.load(nil, update_path)
            if updateIni ~= nil then
                if updateIni.info.version > version_int then
                    sampAddChatMessage("{FF0000}[AdminTools] {FF8C00}Есть обновление! Версия: "..updateIni.info.version, -1)
                    update = true
                elseif updateIni.info.version == version_int then
                    sampAddChatMessage("{FF0000}[AdminTools] {FF8C00}У вас стоит актуальная версия: "..updateIni.info.version, -1)
                end
            end
            os.remove(update_path)
        end  
    end)

    imgui.Process = false
    lua_thread.create(time)
    if HLcfg.onDay.today ~= os.date("%a") then
		HLcfg.onDay.today = os.date("%a")
		HLcfg.onDay.online = 0
        HLcfg.onDay.full = 0
		HLcfg.onDay.afk = 0
		HLcfg.config.dayReports = 0
		HLcfg.config.dayForms = 0
	  	dayFull.v = 0
		save()
    end

    BindAlock = rkeys.registerHotKey(ofHotkeys.Alock.v, 1, false, function()
        if not sampIsChatInputActive() and not sampIsDialogActive() then
			if elements.checkbox.alock.v then
            	sampSendChat("/alock")
			else
				sampAddChatMessage('{FF0000}[AdminTools] {FF8C00}Купи команду в /adm. Если купил, поставь чек-бокс', stColor)
			end
        end
    end)
	BindDelVeh = rkeys.registerHotKey(ofHotkeys.DelVeh.v, 1, false, function()
        if not sampIsChatInputActive() and not sampIsDialogActive() then
            sampSendChat("/delveh")
        end
    end)
    BindenabledTracers = rkeys.registerHotKey(ofHotkeys.enabledTracers.v, 1, false, function()
        if not sampIsChatInputActive() and not sampIsDialogActive() then
            elements.checkbox.bulletTracer.v = not elements.checkbox.bulletTracer.v
            HLcfg.config.bulletTracer = elements.checkbox.bulletTracer.v
            save()
        end
    end)
    BindopenAutoReport = rkeys.registerHotKey(ofHotkeys.openAutoReport.v, 1, false, function()
        if not sampIsChatInputActive() and not sampIsDialogActive() then
            tableOfNew.AutoReport.v = not tableOfNew.AutoReport.v
        end
    end)
    BindLeaveReconWindow = rkeys.registerHotKey(ofHotkeys.LeaveReconWindow.v, 1, false, function()
		if not sampIsChatInputActive() and not sampIsDialogActive() and not AdminTools.v and not tableOfNew.AutoReport.v and rInfo.state and rInfo.id ~= -1 then
			sampSendChat('/re off')
            rInfo.id = -1
            rInfo.state = false
		end
    end)
    BindopenHomeWindow = rkeys.registerHotKey(ofHotkeys.openHomeWindow.v, 1, false, function()
		if not sampIsChatInputActive() and not sampIsDialogActive() then
			AdminTools.v = not AdminTools.v
		end
    end)
    BindactiveChatBubble = rkeys.registerHotKey(ofHotkeys.activeChatBubble.v, 1, false, function()
        if not sampIsChatInputActive() and not sampIsDialogActive() then
            bubbleBox:toggle(not bubbleBox.active)
        end
    end)

    while true do
        wait(0)
        imgui.Process =  AdminTools.v
        if start_update then
            downloadUrlToFile(script_url, script_path, function(id, status)
                if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                    thisScript():reload()
                end
            end)
            break
        end
    end
end

function imgui.OnDrawFrame()
    if  AdminTools.v then
        imgui.ShowCursor = true
        imgui.SetNextWindowPos(imgui.ImVec2(imgui.GetIO().DisplaySize.x / 2, imgui.GetIO().DisplaySize.y / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(790, 550), imgui.Cond.FirstUseEver)
        imgui.Begin(fa.ICON_FA_TOOLBOX..(u8(' Admin Tools')), AdminTools, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
        imgui.SetCursorPosX(7) imgui.SetCursorPosY(25)
        imgui.BeginChild('##menu', imgui.ImVec2(180, 520), true)
        imgui.PushFont(fontsize50)
            imgui.centeredText(u8"SLS")
        imgui.PopFont()
        imgui.PushFont(fontsize30)
            imgui.centeredText(u8"ROLEPLAY")
            imgui.Separator()
            imgui.SetCursorPosY(120)
            imgui.centeredText(u8"Admin Tools")
        imgui.PopFont()
        if imgui.Button(fa.ICON_FA_ENVELOPE, imgui.ImVec2(25, 25)) then

        end imgui.SameLine()
        if imgui.Button(fa.ICON_FA_DOWNLOAD, imgui.ImVec2(25, 25)) then
            if update then
                sampAddChatMessage('{FF0000}[AdminTools] {FF8C00}Обновляюсь', stColor)
                start_update = true
            else
                sampAddChatMessage('{FF0000}[AdminTools] {FF8C00}Обновлений нет.', stColor)
            end
        end imgui.SameLine()
        if imgui.Button(fa.ICON_FA_SYNC, imgui.ImVec2(25, 25)) then

        end imgui.SameLine()
        if imgui.Button(fa.ICON_FA_POWER_OFF, imgui.ImVec2(25, 25)) then

        end imgui.Separator()
        imgui.PushFont(fontsize20)
        imgui.centeredText(u8"Главное меню")
        imgui.PopFont()
        if imgui.InvButton(fa.ICON_FA_USER..u8" Профиль", imgui.ImVec2(150, 0)) then
            sampAddChatMessage('{FF0000}[AdminTools] {FF8C00}Красава', stColor)
            menuSelect = 1
        end
        if imgui.InvButton(fa.ICON_FA_COG..u8" Настройки", imgui.ImVec2(150, 0)) then
            sampAddChatMessage('{FF0000}[AdminTools] {FF8C00}Красава', stColor)
            menuSelect = 2
        end
        if imgui.InvButton(fa.ICON_FA_CHART_LINE..u8" Статистика", imgui.ImVec2(150, 0)) then
            sampAddChatMessage('{FF0000}[AdminTools] {FF8C00}Красава', stColor)
            menuSelect = 3
        end
        if imgui.InvButton(fa.ICON_FA_CHECK_SQUARE..u8" Формы", imgui.ImVec2(150, 0)) then
            sampAddChatMessage('{FF0000}[AdminTools] {FF8C00}Красава', stColor)
            menuSelect = 4
        end
        if imgui.InvButton(fa.ICON_FA_REPLY..u8" Окно Жалоб", imgui.ImVec2(150, 0)) then
            sampAddChatMessage('{FF0000}[AdminTools] {FF8C00}Красава', stColor)
            menuSelect = 5
        end
        if imgui.InvButton(fa.ICON_FA_PLANE..u8" Меню Телепортов", imgui.ImVec2(150, 0)) then
            sampAddChatMessage('{FF0000}[AdminTools] {FF8C00}Красава', stColor)
            menuSelect = 6
        end
        if imgui.InvButton(fa.ICON_FA_TH_LIST..u8" Таблица наказаний", imgui.ImVec2(150, 0)) then
            sampAddChatMessage('{FF0000}[AdminTools] {FF8C00}Красава', stColor)
            menuSelect = 7
        end
        if imgui.InvButton(fa.ICON_FA_LIST..u8" Админ-Команды", imgui.ImVec2(150, 0)) then
            sampAddChatMessage('{FF0000}[AdminTools] {FF8C00}Красава', stColor)
            menuSelect = 8
        end
        if imgui.InvButton(fa.ICON_FA_PLUS..u8" Админ-Плюшки", imgui.ImVec2(150, 0)) then
            sampAddChatMessage('{FF0000}[AdminTools] {FF8C00}Красава', stColor)
            menuSelect = 8
        end
        imgui.EndChild()
        imgui.SameLine() imgui.SetCursorPosX(187) imgui.SetCursorPosY(25)
        imgui.BeginChild('##selectebl', imgui.ImVec2(596, 520), true)
        if menuSelect == 1 then
            imgui.PushFont(fontsize20)
            imgui.centeredText(u8"Профиль")
            imgui.PopFont()
            if HLcfg.admSetting.admNick == "" or HLcfg.admSetting.admlvl == 0 then
                imgui.SetCursorPosY(150)
                imgui.SetCursorPosX(100)
                imgui.BeginChild('##register', imgui.ImVec2(380, 120), true)
                imgui.PushItemWidth(200)
                imgui.Text(u8"Введите ваш Ник =>> ") imgui.SameLine() imgui.InputText('##nickadm', elements.input.admNick)
                imgui.PushItemWidth(50)
                imgui.Text(u8"Введите ваш Уровень Администратора =>> ") imgui.SameLine() imgui.InputText('##lvladm', elements.input.admlvl)
                if imgui.Button(u8'Сохранить', imgui.ImVec2(100, 0)) then
                    HLcfg.admSetting.admNick = elements.input.admNick.v
                    HLcfg.admSetting.admlvl = elements.input.admlvl.v
                    save()
                end
                imgui.EndChild()
            else
                imgui.PushFont(fontsize15)
                imgui.Text(u8"Здраствуйте "..HLcfg.admSetting.admNick..u8". Уровень администратора - "..HLcfg.admSetting.admlvl)
                imgui.PopFont()
            end
            

            imgui.SetCursorPosY(415)
            imgui.BeginChild('##apass', imgui.ImVec2(278, 100), true)
            if imgui.Checkbox(u8"[Вкл/выкл] Авто-вход как ADM", elements.checkbox.autoCome) then
                HLcfg.admSetting.autoCome = elements.checkbox.autoCome.v
                save()
            end imgui.SameLine() imgui.HelpMarker(u8"Не надо вводить админ-пароль самому, скрипт сделает это за вас")
            if elements.checkbox.autoCome.v then
                imgui.Text(u8"Введите админ-пароль: ")  imgui.PushItemWidth(100)
                if imgui.InputText("##adminPassword", elements.input.adminPassword, (elements.checkbox.showAdminPassword.v and imgui.InputTextFlags.Password or nil)) then
                    HLcfg.admSetting.adminPassword = elements.input.adminPassword.v
                    save()
                end imgui.PopItemWidth() imgui.SameLine() if imgui.ToggleButton('Админ Пароль', elements.checkbox.showAdminPassword) then
                    HLcfg.admSetting.showAdminPassword = elements.checkbox.showAdminPassword.v
                    save()
                end imgui.SameLine() imgui.HelpMarker(u8"Настройка, которая будет показывать, отобразиться ваш админ-пароль, или нет")
            end
            imgui.EndChild()
            imgui.SameLine()
            imgui.BeginChild('##pass', imgui.ImVec2(278, 100), true)
            if imgui.Checkbox(u8"[Вкл/выкл] Авто-вход в аккаунт", elements.checkbox.autoCome2) then
                HLcfg.admSetting.autoCome2 = elements.checkbox.autoCome2.v
                save()
            end imgui.SameLine() imgui.HelpMarker(u8"Не надо вводить пароль самому, скрипт сделает это за вас")
            if elements.checkbox.autoCome2.v then
                imgui.Text(u8"Введите пароль: ") imgui.PushItemWidth(100)
                if imgui.InputText("##Password", elements.input.Password, (elements.checkbox.showPassword.v and imgui.InputTextFlags.Password or nil)) then
                    HLcfg.admSetting.Password = elements.input.Password.v
                    save()
                end imgui.PopItemWidth() imgui.SameLine() if imgui.ToggleButton('Пароль', elements.checkbox.showPassword) then
                    HLcfg.admSetting.showPassword = elements.checkbox.showPassword.v
                    save()
                end imgui.SameLine() imgui.HelpMarker(u8"Настройка, которая будет показывать, отобразиться ваш пароль, или нет")
            end
            imgui.EndChild()
        end
        if menuSelect == 2 then
            imgui.PushFont(fontsize20)
            imgui.Text(u8"Основные настройки")
            imgui.SameLine()
            imgui.SetCursorPosX(305)
            imgui.Text(u8"Горячие клавишы")
            imgui.PopFont()
            imgui.BeginChild('##select1', imgui.ImVec2(278, 470), true)
            
            imgui.EndChild()
            imgui.SameLine()
            imgui.BeginChild('##selec2', imgui.ImVec2(278, 470), true)
            if imguiad.HotKey("##ActiveOne", ofHotkeys.LeaveReconWindow, tLastOne, 100) then
                rkeys.changeHotKey(BindLeaveReconWindow, ofHotkeys.LeaveReconWindow.v)
                cfg.LeaveReconWindow = deepcopy(ofHotkeys.LeaveReconWindow.v)
                luasave()
            end imgui.SameLine() imgui.Text(u8"Выйти из рекона")
            local tLastThree = {}
            if imguiad.HotKey("##ActiveThree", ofHotkeys.openHomeWindow, tLastThree, 100) then
                rkeys.changeHotKey(BindopenHomeWindow, ofHotkeys.openHomeWindow.v)
                cfg.openHomeWindow = deepcopy(ofHotkeys.openHomeWindow.v)
                luasave()
            end  imgui.SameLine() imgui.Text(u8'Открыть основное окно')
            local tLastFour = {}
            if imguiad.HotKey("##ActiveFour", ofHotkeys.openAutoReport, tLastFour, 100) then
                rkeys.changeHotKey(BindopenAutoReport, ofHotkeys.openAutoReport.v)
                cfg.openAutoReport = deepcopy(ofHotkeys.openAutoReport.v)
                luasave()
            end imgui.SameLine() imgui.Text(u8'Открыть авто-репорт')
            local tLastFive = {}
            if imguiad.HotKey("##ActiveFive", ofHotkeys.enabledTracers, tLastFive, 100) then
                rkeys.changeHotKey(BindenabledTracers, ofHotkeys.enabledTracers.v)
                cfg.enabledTracers = deepcopy(ofHotkeys.enabledTracers.v)
                luasave()
            end imgui.SameLine() imgui.Text(u8'Вкл/выкл трейсеры')
            if imguiad.HotKey("##ActiveSix", ofHotkeys.Alock, tLastOne, 100) then
                rkeys.changeHotKey(BindAlock, ofHotkeys.Alock.v)
                cfg.Alock = deepcopy(ofHotkeys.Alock.v)
                luasave()
            end imgui.SameLine() imgui.Text(u8"Открытие любого авто")
            if imguiad.HotKey("##ActiveSeven", ofHotkeys.DelVeh, tLastOne, 100) then
                rkeys.changeHotKey(BindDelVeh, ofHotkeys.DelVeh.v)
                cfg.DelVeh = deepcopy(ofHotkeys.DelVeh.v)
                luasave()
            end imgui.SameLine() imgui.Text(u8"Удаление Т/С")
            imgui.EndChild()
        end
        if menuSelect == 3 then
            imgui.PushFont(fontsize20)
            imgui.centeredText(u8"Статистика")
            imgui.PopFont()
            imgui.Text(u8'Наказания за все время.') imgui.SameLine() imgui.SetCursorPosX(265) imgui.Text(u8'Статистика за день за день')
            imgui.BeginChild('##nakaz', imgui.ImVec2(240, 280), true)
                imgui.Text(u8'Количество /ban: '..HLcfg.Count.ban)
                imgui.Text(u8'Количество /iban: '..HLcfg.Count.iban)
                imgui.Text(u8'Количество /warn: '..HLcfg.Count.warn)
                imgui.Text(u8'Количество /offwarn: '..HLcfg.Count.offwarn)
                imgui.Text(u8'Количество /mute: '..HLcfg.Count.mute)
                imgui.Text(u8'Количество /rmute: '..HLcfg.Count.rmute)
                imgui.Text(u8'Количество /prison: '..HLcfg.Count.prison)
                imgui.Text(u8'Количество /kick: '..HLcfg.Count.kick)
                imgui.Separator()
                imgui.Text(u8'Количество принятых формы: '..HLcfg.Count.forms)
                imgui.Text(u8'Количество принятых жалоб: '..HLcfg.Count.reports)
            imgui.EndChild()
            imgui.SameLine()
            imgui.BeginChild('##alltday', imgui.ImVec2(240, 200), true)
                imgui.centeredText(u8'Форм за день: '..HLcfg.config.dayForms)
                imgui.centeredText(u8'Форм за сеанс: '..LsessionForma)
                imgui.centeredText(u8'Репортов за день: '..HLcfg.config.dayReports)
                imgui.centeredText(u8'Репортов за сеанс: '..LsessionReport) 
                imgui.centeredText(u8'Онлайн за сеанс: '..get_clock(sessionOnline.v))
                imgui.centeredText(u8'Онлайн за день: '..get_clock(HLcfg.onDay.online)) 
                imgui.centeredText(u8'АФК за сеанс: '..get_clock(sessionAfk.v)) 
                imgui.centeredText(u8'АФК за день: '..get_clock(HLcfg.onDay.afk))
            imgui.EndChild()
            imgui.Text(u8'Онлайн за все время.')
            imgui.BeginChild('##alltime', imgui.ImVec2(240, 100), true)
                imgui.Text(u8'Онлайн за все время: '..get_clock(HLcfg.Count.Online))
                imgui.Text(u8'AFK за все время: '..get_clock(HLcfg.Count.AFK))
            imgui.EndChild()
        end
        imgui.EndChild()
        imgui.End()
    end
end

function imgui.centeredText(text)
    imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(text).x) / 2);
    imgui.Text(tostring(text));
end
function imgui.InvButton(text, size)
    imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0, 0, 0, 0))
    imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0, 0, 0, 0))
    imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0, 0, 0, 0))
         local button = imgui.Button(text, size)
    imgui.PopStyleColor(3)
    return button
end
function imgui.HelpMarker(text)
	imgui.TextDisabled('(?)')
	if imgui.IsItemHovered() then
		imgui.BeginTooltip()
		imgui.PushTextWrapPos(450)
		imgui.TextUnformatted(text)
		imgui.PopTextWrapPos()
		imgui.EndTooltip()
	end
end
function save()
    inicfg.save(HLcfg, "ATConfig.ini")
end
function luasave()
    luacfg.save(filename_settings, cfg)
end
function imgui.ToggleButton(str_id, bool)
    local rBool = false

	if LastActiveTime == nil then
		LastActiveTime = {}
	end
	if LastActive == nil then
		LastActive = {}
	end

	local function ImSaturate(f)
		return f < 0.0 and 0.0 or (f > 1.0 and 1.0 or f)
	end

	local p = imgui.GetCursorScreenPos()
	local draw_list = imgui.GetWindowDrawList()

	local height = imgui.GetTextLineHeightWithSpacing()
	local width = height * 1.55
	local radius = height * 0.50
	local ANIM_SPEED = 0.15

	if imgui.InvisibleButton(str_id, imgui.ImVec2(width, height)) then
		bool.v = not bool.v
		rBool = true
		LastActiveTime[tostring(str_id)] = os.clock()
		LastActive[tostring(str_id)] = true
	end

	local t = bool.v and 1.0 or 0.0

	if LastActive[tostring(str_id)] then
		local time = os.clock() - LastActiveTime[tostring(str_id)]
		if time <= ANIM_SPEED then
			local t_anim = ImSaturate(time / ANIM_SPEED)
			t = bool.v and t_anim or 1.0 - t_anim
		else
			LastActive[tostring(str_id)] = false
		end
	end

	local col_bg
	if bool.v then
		col_bg = imgui.GetColorU32(imgui.GetStyle().Colors[imgui.Col.FrameBgHovered])
	else
		col_bg = imgui.ImColor(100, 100, 100, 180):GetU32()
	end

	draw_list:AddRectFilled(imgui.ImVec2(p.x, p.y + (height / 6)), imgui.ImVec2(p.x + width - 1.0, p.y + (height - (height / 6))), col_bg, 5.0)
	draw_list:AddCircleFilled(imgui.ImVec2(p.x + radius + t * (width - radius * 2.0), p.y + radius), radius - 0.75, imgui.GetColorU32(bool.v and imgui.GetStyle().Colors[imgui.Col.ButtonActive] or imgui.ImColor(150, 150, 150, 255):GetVec4()))

	return rBool
end
function time()
	startTime = os.time()
    while true do
        wait(1000)
        if sampGetGamestate() == 3 then
	        nowTime = os.date("%H:%M:%S", os.time())
	        sessionOnline.v = sessionOnline.v + 1
	        sessionFull.v = os.time() - startTime
	        sessionAfk.v = sessionFull.v - sessionOnline.v
	        HLcfg.onDay.online = HLcfg.onDay.online + 1
	        HLcfg.onDay.full = dayFull.v + sessionFull.v
			HLcfg.onDay.afk = HLcfg.onDay.full - HLcfg.onDay.online
            HLcfg.Count.Online = HLcfg.onDay.full
            HLcfg.Count.AFK = HLcfg.onDay.afk
	    else
	    	startTime = startTime + 1
	    end
        save()
    end
end
function onExitScript(booleanTrue)
    if bubbleBox then bubbleBox:free() end
    if booleanTrue then
        if HLcfg.config.invAdmin then
            HLcfg.config.invAdmin = false
            save()
        end
    end
end
function get_clock(time)
    local timezone_offset = 86400 - os.date('%H', 0) * 3600
    if tonumber(time) >= 86400 then onDay = true else onDay = false end
    return os.date((onDay and math.floor(time / 86400)..' ' or '')..'%H:%M:%S', time + timezone_offset)
end


function apply_custom_style()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
    local ImVec2 = imgui.ImVec2
 
     style.WindowPadding = ImVec2(15, 15)
     style.WindowRounding = 15.0
     style.FramePadding = ImVec2(5, 5)
     style.ItemSpacing = ImVec2(12, 8)
     style.ItemInnerSpacing = ImVec2(8, 6)
     style.IndentSpacing = 25.0
     style.ScrollbarSize = 15.0
     style.ScrollbarRounding = 15.0
     style.GrabMinSize = 15.0
     style.GrabRounding = 7.0
     style.ChildWindowRounding = 8.0
     style.FrameRounding = 6.0
   
 
    colors[clr.Text] = ImVec4(0.95, 0.96, 0.98, 1.00)
    colors[clr.TextDisabled] = ImVec4(0.36, 0.42, 0.47, 1.00)
    colors[clr.WindowBg] = ImVec4(0.11, 0.15, 0.17, 1.00)
    colors[clr.ChildWindowBg] = ImVec4(0.15, 0.18, 0.22, 1.00)
    colors[clr.PopupBg] = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.Border] = ImVec4(0.43, 0.43, 0.50, 0.50)
    colors[clr.BorderShadow] = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.FrameBg] = ImVec4(0.20, 0.25, 0.29, 1.00)
    colors[clr.FrameBgHovered] = ImVec4(0.12, 0.20, 0.28, 1.00)
    colors[clr.FrameBgActive] = ImVec4(0.09, 0.12, 0.14, 1.00)
    colors[clr.TitleBg] = ImVec4(0.09, 0.12, 0.14, 0.65)
    colors[clr.TitleBgCollapsed] = ImVec4(0.00, 0.00, 0.00, 0.51)
    colors[clr.TitleBgActive] = ImVec4(0.08, 0.10, 0.12, 1.00)
    colors[clr.MenuBarBg] = ImVec4(0.15, 0.18, 0.22, 1.00)
    colors[clr.ScrollbarBg] = ImVec4(0.02, 0.02, 0.02, 0.39)
    colors[clr.ScrollbarGrab] = ImVec4(0.20, 0.25, 0.29, 1.00)
    colors[clr.ScrollbarGrabHovered] = ImVec4(0.18, 0.22, 0.25, 1.00)
    colors[clr.ScrollbarGrabActive] = ImVec4(0.09, 0.21, 0.31, 1.00)
    colors[clr.ComboBg] = ImVec4(0.20, 0.25, 0.29, 1.00)
    colors[clr.CheckMark] = ImVec4(0.28, 0.56, 1.00, 1.00)
    colors[clr.SliderGrab] = ImVec4(0.28, 0.56, 1.00, 1.00)
    colors[clr.SliderGrabActive] = ImVec4(0.37, 0.61, 1.00, 1.00)
    colors[clr.Button] = ImVec4(0.20, 0.25, 0.29, 1.00)
    colors[clr.ButtonHovered] = ImVec4(0.28, 0.56, 1.00, 1.00)
    colors[clr.ButtonActive] = ImVec4(0.06, 0.53, 0.98, 1.00)
    colors[clr.Header] = ImVec4(0.20, 0.25, 0.29, 0.55)
    colors[clr.HeaderHovered] = ImVec4(0.26, 0.59, 0.98, 0.80)
    colors[clr.HeaderActive] = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.ResizeGrip] = ImVec4(0.26, 0.59, 0.98, 0.25)
    colors[clr.ResizeGripHovered] = ImVec4(0.26, 0.59, 0.98, 0.67)
    colors[clr.ResizeGripActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
    colors[clr.CloseButton] = ImVec4(0.40, 0.39, 0.38, 0.16)
    colors[clr.CloseButtonHovered] = ImVec4(0.40, 0.39, 0.38, 0.39)
    colors[clr.CloseButtonActive] = ImVec4(0.40, 0.39, 0.38, 1.00)
    colors[clr.PlotLines] = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.PlotLinesHovered] = ImVec4(1.00, 0.43, 0.35, 1.00)
    colors[clr.PlotHistogram] = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[clr.TextSelectedBg] = ImVec4(0.25, 1.00, 0.00, 0.43)
    colors[clr.ModalWindowDarkening] = ImVec4(1.00, 0.98, 0.95, 0.73)
 end
 apply_custom_style()