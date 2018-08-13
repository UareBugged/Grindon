local AceAddon = LibStub("AceAddon-3.0")

local Grindon = AceAddon:GetAddon("Grindon")
local Core = Grindon:NewModule("Core", "AceConsole-3.0", "AceEvent-3.0")

local Config = Grindon:GetModule("Config")

local options = {
    groupLoot = {
        name = "Enable group loot",
        type = "toggle",
        set = function(_, val) Core.Database.profile.groupLoot = val end,
        get = function() return Core.Database.profile.groupLoot end
    }
}

local defaults = {
    profile = {
        groupLoot = false
    }
}

function Core:OnInitialize()
    self.Database = Grindon.Database:RegisterNamespace("Core", defaults)

    self:RegisterMessage("OnSegmentStart", "OnSegmentStart")
    self:RegisterMessage("OnSegmentStop", "OnSegmentStop")

    Config:Register("General", options, 1)
end

function Core:OnSegmentStart()
    self:RegisterEvent("CHAT_MSG_LOOT", "OnLootReceive")
end

function Core:OnSegmentStop()
    self:UnregisterEvent("CHAT_MSG_LOOT")
end

function Core:OnLootReceive(_, msg, _, _, _, player)
    if not self.Database.profile.groupLoot then
        if player ~= UnitName("player") then
            return
        end
    end

    local id = tonumber(string.match(msg, "Hitem:(%d+):"))
    local name = string.match(msg, "%[(.+)%]")
    local count = string.match(msg, "x(%d+)")
    if count == nil then count = 1 end

    Grindon.Database.global.segments[Grindon.CurrentSegment].items[id].count = Grindon.Database.global.segments[Grindon.CurrentSegment].items[id].count + count
    self:SendMessage("OnLootReceive", id, count, name)
end