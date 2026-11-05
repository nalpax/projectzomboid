-- Ярославль: Выживание — ловушки и камеры наблюдения.
-- Работает в одиночной игре. В мультиплеере не проверялось.
require "YS_Config"
require "ISUI/ISInventoryPaneContextMenu"

YS = YS or {}
local cfg = YS.Config

local TRAP_TYPES = {
    ["Yaroslavl.BearTrap"]       = "bear",
    ["Yaroslavl.TripwireCans"]   = "tripwire",
    ["Yaroslavl.SpikeBoard"]     = "spike",
    ["Yaroslavl.SecurityCamera"] = "camera",
}

local TRAP_NAMES = {
    bear = "Капкан", tripwire = "Растяжка", spike = "Доска с гвоздями", camera = "Камера",
}

-- ---------------------------------------------------------------- хранилище
local function store()
    local data = ModData.getOrCreate("YaroslavlTraps")
    data.traps = data.traps or {}
    data.nextCam = data.nextCam or 1
    return data
end

local function key(x, y, z) return x .. "," .. y .. "," .. z end

local function note(player, text, r, g, b)
    if not player then return end
    local ok = pcall(function() player:setHaloNote(text, r or 255, g or 220, b or 120, 300) end)
    if not ok then pcall(function() player:Say(text) end) end
end

-- есть ли на клетке предмет-ловушка (если игрок его подобрал — ловушка снята)
local function squareHasItem(sq, fullType)
    local objs = sq:getWorldObjects()
    if not objs then return false end
    for i = 0, objs:size() - 1 do
        local wo = objs:get(i)
        local it = wo and wo:getItem()
        if it and it:getFullType() == fullType then return true end
    end
    return false
end

-- ---------------------------------------------------------------- установка
local function placeTrap(item, player)
    local sq = player:getCurrentSquare()
    if not sq then return end
    local kind = TRAP_TYPES[item:getFullType()]
    if not kind then return end

    local data = store()
    local k = key(sq:getX(), sq:getY(), sq:getZ())
    if data.traps[k] then
        note(player, "Здесь уже что-то установлено", 255, 120, 120)
        return
    end

    local inv = item:getContainer() or player:getInventory()
    if player:getPrimaryHandItem() == item then player:setPrimaryHandItem(nil) end
    if player:getSecondaryHandItem() == item then player:setSecondaryHandItem(nil) end
    inv:Remove(item)
    sq:AddWorldInventoryItem(item, 0.5, 0.5, 0)

    local rec = { kind = kind, type = item:getFullType(), armed = true, uses = cfg.Traps.SpikeUses, last = 0 }
    if kind == "camera" then
        rec.name = "Камера №" .. data.nextCam
        data.nextCam = data.nextCam + 1
    end
    data.traps[k] = rec
    note(player, (rec.name or TRAP_NAMES[kind]) .. " установлен(а)", 140, 255, 140)
end

local function nowSeconds()
    local gt = getGameTime()
    return gt and (gt:getWorldAgeHours() * 3600) or 0
end

-- ---------------------------------------------------------------- срабатывание
local function hitZombie(zombie, damage, knock)
    pcall(function()
        zombie:setHealth(zombie:getHealth() - damage)
        if knock then
            zombie:setStaggerBack(true)
            zombie:setKnockedDown(true)
        end
        if zombie:getHealth() <= 0 then zombie:Kill(nil) end
    end)
end

local function firstZombie(sq)
    local movers = sq:getMovingObjects()
    if not movers then return nil end
    for i = 0, movers:size() - 1 do
        local o = movers:get(i)
        if instanceof(o, "IsoZombie") and not o:isDead() then return o end
    end
    return nil
end

local tick = 0
local function onTick()
    tick = tick + 1
    if tick < cfg.Traps.CheckEveryTicks then return end
    tick = 0

    local player = getPlayer()
    if not player then return end
    local cell = getCell()
    if not cell then return end
    local data = store()

    for k, rec in pairs(data.traps) do
        local x, y, z = k:match("(-?%d+),(-?%d+),(-?%d+)")
        local sq = cell:getGridSquare(tonumber(x), tonumber(y), tonumber(z))
        if sq then
            if not squareHasItem(sq, rec.type) then
                data.traps[k] = nil -- игрок подобрал ловушку
            elseif rec.kind ~= "camera" and rec.armed then
                local zed = firstZombie(sq)
                if zed then
                    if rec.kind == "bear" then
                        hitZombie(zed, cfg.Traps.BearTrapDamage, true)
                        rec.armed = false
                        note(player, "Капкан захлопнулся! (подберите и поставьте снова)", 255, 200, 80)
                    elseif rec.kind == "spike" then
                        hitZombie(zed, cfg.Traps.SpikeDamage, ZombRand(3) == 0)
                        rec.uses = (rec.uses or cfg.Traps.SpikeUses) - 1
                        if rec.uses <= 0 then
                            rec.armed = false
                            note(player, "Доска с гвоздями сломалась", 255, 160, 80)
                        end
                    elseif rec.kind == "tripwire" then
                        local t = nowSeconds()
                        if t - (rec.last or 0) >= cfg.Traps.TripwireCooldown then
                            rec.last = t
                            addSound(nil, sq:getX(), sq:getY(), sq:getZ(), cfg.Traps.TripwireNoise, cfg.Traps.TripwireNoise)
                            local dx = math.floor(sq:getX() - player:getX())
                            local dy = math.floor(sq:getY() - player:getY())
                            note(player, string.format("Растяжка звякнула! (%d, %d от вас)", dx, dy), 255, 90, 90)
                        end
                    end
                end
            end
        end
    end
end
Events.OnTick.Add(onTick)

-- ---------------------------------------------------------------- камеры
local function zombiesNear(cx, cy, cz, r)
    local list = getCell():getZombieList()
    local n = 0
    if not list then return 0 end
    for i = 0, list:size() - 1 do
        local zed = list:get(i)
        if zed and not zed:isDead() and math.abs(zed:getZ() - cz) < 1 then
            local dx, dy = zed:getX() - cx, zed:getY() - cy
            if dx * dx + dy * dy <= r * r then n = n + 1 end
        end
    end
    return n
end

local function survivorsNear(cx, cy, r)
    local n = 0
    local players = getOnlinePlayers and getOnlinePlayers()
    if not players then return 0 end
    for i = 0, players:size() - 1 do
        local p = players:get(i)
        local dx, dy = p:getX() - cx, p:getY() - cy
        if dx * dx + dy * dy <= r * r then n = n + 1 end
    end
    return n
end

local function watchCameras(item, player)
    local data = store()
    local lines = {}
    local cell = getCell()
    local r = cfg.Cameras.ViewRadius
    for k, rec in pairs(data.traps) do
        if rec.kind == "camera" then
            local x, y, z = k:match("(-?%d+),(-?%d+),(-?%d+)")
            x, y, z = tonumber(x), tonumber(y), tonumber(z)
            local sq = cell:getGridSquare(x, y, z)
            if not sq then
                table.insert(lines, rec.name .. ": НЕТ СИГНАЛА (слишком далеко)")
            else
                local zc = zombiesNear(x, y, z, r)
                local status = zc == 0 and "чисто" or (zc < 5 and ("зомби: " .. zc) or ("ОПАСНО, зомби: " .. zc))
                local extra = ""
                if isClient and isClient() then
                    local s = survivorsNear(x, y, r)
                    if s > 0 then extra = ", люди: " .. s end
                end
                table.insert(lines, string.format("%s [%d,%d] — %s%s", rec.name, x, y, status, extra))
            end
        end
    end
    if #lines == 0 then
        note(player, "Камер не установлено. ПКМ по камере → «Установить здесь»", 255, 200, 120)
        return
    end
    table.sort(lines)
    local text = "<H2> Видеонаблюдение <LINE> <TEXT> " .. table.concat(lines, " <LINE> ")
    local ok = pcall(function()
        local w, h = 460, 120 + #lines * 22
        local modal = ISModalRichText:new(getCore():getScreenWidth() / 2 - w / 2, getCore():getScreenHeight() / 2 - h / 2, w, h, text, false)
        modal:initialise()
        modal:addToUIManager()
    end)
    if not ok then
        for _, l in ipairs(lines) do player:Say(l) end
    end
end

-- ---------------------------------------------------------------- контекстное меню
local function onFillMenu(playerNum, context, items)
    local player = getSpecificPlayer(playerNum)
    if not player then return end
    for _, v in ipairs(items) do
        local item = v
        if type(v) == "table" and v.items then item = v.items[1] end
        if item and item.getFullType then
            local ft = item:getFullType()
            if TRAP_TYPES[ft] then
                context:addOption("Установить здесь", item, placeTrap, player)
                return
            elseif ft == "Yaroslavl.CameraMonitor" then
                context:addOption("Смотреть камеры", item, watchCameras, player)
                return
            end
        end
    end
end
Events.OnFillInventoryObjectContextMenu.Add(onFillMenu)
