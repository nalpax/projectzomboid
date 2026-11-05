-- Ярославль: Выживание — где искать новые предметы.
-- Если какого-то списка в текущей версии игры нет, он просто пропускается.
require "Items/ProceduralDistributions"
require "YS_Config"

local mult = (YS and YS.Config and YS.Config.LootMultiplier) or 1.0

local function add(listName, itemType, chance)
    local list = ProceduralDistributions and ProceduralDistributions.list and ProceduralDistributions.list[listName]
    if not list or not list.items then return end
    table.insert(list.items, itemType)
    table.insert(list.items, chance * mult)
end

local function addMany(lists, itemType, chance)
    for _, l in ipairs(lists) do add(l, itemType, chance) end
end

local GUNS_POLICE = { "PoliceStorageGuns" }
local GUNS_ARMY   = { "ArmyStorageGuns" }
local GUNS_SHOP   = { "GunStoreGuns", "GunStoreRifles", "GunStorePistols", "GunStoreShotguns" }
local AMMO_ALL    = { "GunStoreAmmunition", "GunStoreMagsAmmo", "PoliceStorageAmmunition", "ArmyStorageAmmunition", "HuntingLockers" }
local HUNT        = { "HuntingLockers", "GarageFirearms", "WardrobeMan", "ClosetShelfGeneric" }

-- Оружие
addMany(GUNS_ARMY,   "Yaroslavl.AK74", 6)
addMany(GUNS_ARMY,   "Yaroslavl.AKS74U", 3)
addMany(GUNS_ARMY,   "Yaroslavl.SKS", 3)
addMany(GUNS_ARMY,   "Yaroslavl.SapperShovel", 6)
addMany(GUNS_POLICE, "Yaroslavl.PM", 8)
addMany(GUNS_POLICE, "Yaroslavl.AKS74U", 2)
addMany(GUNS_SHOP,   "Yaroslavl.TOZ34", 4)
addMany(GUNS_SHOP,   "Yaroslavl.SKS", 2)
addMany(GUNS_SHOP,   "Yaroslavl.Mosin", 2)
addMany(HUNT,        "Yaroslavl.TOZ34", 0.6)
addMany(HUNT,        "Yaroslavl.Mosin", 0.3)

-- Патроны и магазины
addMany(AMMO_ALL, "Yaroslavl.Ammo545Box", 4)
addMany(AMMO_ALL, "Yaroslavl.Ammo762x39Box", 3)
addMany(AMMO_ALL, "Yaroslavl.Ammo762x54RBox", 2)
addMany(AMMO_ALL, "Yaroslavl.Ammo9x18Box", 4)
addMany(AMMO_ALL, "Yaroslavl.AK74Mag", 2)
addMany(AMMO_ALL, "Yaroslavl.PMMag", 2)
addMany(GUNS_ARMY, "Yaroslavl.AK74Mag", 5)
addMany(GUNS_POLICE, "Yaroslavl.PMMag", 5)

-- Еда
local KITCHEN = { "KitchenCannedFood", "KitchenDryFood", "StoreShelfCombo", "GroceryStorageCrate1", "GroceryStorageCrate2", "CrateCannedFood", "ArmyStorageOutfit" }
addMany(KITCHEN, "Yaroslavl.Tushenka", 6)
addMany(KITCHEN, "Yaroslavl.Sgushenka", 4)
addMany(KITCHEN, "Yaroslavl.Kilka", 4)
addMany(KITCHEN, "Yaroslavl.Grechka", 5)
addMany(KITCHEN, "Yaroslavl.Sushki", 4)
addMany({ "KitchenBreakfast", "KitchenDryFood", "StoreShelfCombo", "BakeryBread" }, "Yaroslavl.BorodinskyBread", 4)
addMany({ "KitchenBottles", "FridgeSoda", "StoreShelfDrinks", "CrateSodaBottles" }, "Yaroslavl.Kvas", 5)
addMany({ "KitchenBottles", "StoreShelfDrinks", "BarCounterLiquor", "LivingRoomShelf" }, "Yaroslavl.Vodka", 3)
addMany({ "StoreShelfSnacks", "KitchenDryFood", "CandyStoreSnacks" }, "Yaroslavl.Alenka", 4)
addMany({ "ArmyStorageOutfit", "ArmyStorageGuns", "ArmyHangarTools" }, "Yaroslavl.IRP", 8)

-- Вещи, ловушки, электроника
addMany({ "ArmyStorageOutfit", "ArmySurplusBackpacks", "ArmySurplusMisc" }, "Yaroslavl.ArmyBag", 6)
addMany({ "ArmyStorageMedical", "MedicalStorageDrugs", "BathroomCabinet", "ArmyStorageOutfit" }, "Yaroslavl.AI2", 3)
addMany({ "GarageTools", "ToolStoreTools", "CrateTools", "HuntingLockers", "ShedTools" }, "Yaroslavl.BearTrap", 1.5)
addMany({ "CrateElectronics", "ElectronicStoreMisc", "OfficeDesk", "SecurityLockers" }, "Yaroslavl.SecurityCamera", 2)
addMany({ "CrateElectronics", "ElectronicStoreMisc", "SecurityLockers" }, "Yaroslavl.CameraMonitor", 1)

-- Интерьер квартир
local LIVING = { "LivingRoomShelf", "LivingRoomShelfNoTapes", "LivingRoomSideTable", "BedroomDresser", "BedroomSideTable", "WardrobeWoman", "ClosetShelfGeneric", "KitchenRandom" }
addMany(LIVING, "Yaroslavl.CrystalVase", 2)
addMany(LIVING, "Yaroslavl.Samovar", 0.8)
addMany(LIVING, "Yaroslavl.WallCarpet", 1.5)
addMany(LIVING, "Yaroslavl.OkeanRadio", 1)
addMany(LIVING, "Yaroslavl.YaroslavlMagnet", 2)
addMany(LIVING, "Yaroslavl.GazetaSevKray", 3)
addMany(LIVING, "Yaroslavl.KrokodilMag", 2)
addMany({ "MagazineRackMixed", "PostOfficeNewspapers", "OfficeDesk", "LivingRoomShelf" }, "Yaroslavl.GazetaSevKray", 6)
addMany({ "PoliceDesk", "SchoolLockers", "OfficeDesk", "ClassroomDesk" }, "Yaroslavl.SurvivalBook", 2)
