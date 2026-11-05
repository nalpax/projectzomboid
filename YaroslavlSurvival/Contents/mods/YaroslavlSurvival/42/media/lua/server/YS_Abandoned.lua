-- Ярославль: Выживание — «частично заброшенный город».
-- При первой загрузке клетки часть дверей отпирается (открытые квартиры),
-- часть остаётся распахнутой, часть окон оказывается разбита.
-- Каждая клетка обрабатывается один раз (метка в её ModData).
require "YS_Config"

local function roll(chance) return ZombRand(100) < chance end

local function processSquare(sq)
    local cfg = YS and YS.Config and YS.Config.Abandoned
    if not cfg or not cfg.Enabled or not sq then return end
    local objs = sq:getObjects()
    if not objs then return end

    -- метку ставим только на клетки с дверями/окнами, чтобы не раздувать сохранение
    local relevant = false
    for i = 0, objs:size() - 1 do
        local o = objs:get(i)
        if instanceof(o, "IsoDoor") or instanceof(o, "IsoWindow") then relevant = true break end
    end
    if not relevant then return end

    local md = sq:getModData()
    if md.ysAbandoned then return end
    md.ysAbandoned = true

    for i = 0, objs:size() - 1 do
        local obj = objs:get(i)
        if instanceof(obj, "IsoDoor") then
            if roll(cfg.UnlockDoorChance) then
                pcall(function() obj:setLockedByKey(false) end)
                pcall(function() obj:setIsLocked(false) end)
                if roll(cfg.OpenDoorChance) then
                    pcall(function()
                        if not obj:IsOpen() then obj:ToggleDoorSilent() end
                    end)
                end
            end
        elseif instanceof(obj, "IsoWindow") then
            if roll(cfg.SmashWindowChance) then
                pcall(function()
                    if not obj:isSmashed() then obj:smashWindow(true) end
                end)
            end
        end
    end
end

Events.LoadGridsquare.Add(processSquare)
