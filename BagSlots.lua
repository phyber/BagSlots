local BagSlots = LibStub("AceAddon-3.0"):NewAddon(
    "BagSlots",
    "AceBucket-3.0",
    "AceConsole-3.0"
)
local L = LibStub("AceLocale-3.0"):GetLocale("BagSlots")
local Crayon = LibStub("LibCrayon-3.0")
local db -- Filled in later
local _G = _G
local ipairs = ipairs
local GetContainerNumSlots = GetContainerNumSlots
local GetContainerNumFreeSlots = GetContainerNumFreeSlots
local fontSize = 12
local NUM_BAG_SLOTS = NUM_BAG_SLOTS
local addonOptionsFrameName

-- Default options
local defaults = {
    profile = {
        showDepletion = false,
        showTotal = true,
        textPosition = "BOTTOM",
    },
}

-- Names of the bag slots.
local bags = {
    "MainMenuBarBackpackButton",
    "CharacterBag0Slot",
    "CharacterBag1Slot",
    "CharacterBag2Slot",
    "CharacterBag3Slot",
}

local function getOptions()
    local options = {
        type = "group",
        name = L["BagSlots"],
        get = function(info) return db[info[#info]] end,
        args = {
            bsdesc = {
                type = "description",
                order = 0,
                name = L["Display bag usage on each of your bag slots."],
            },
            showDepletion = {
                name = L["Show Depletion"],
                desc = L["Show depletion of bag slots."],
                type = "toggle",
                order = 100,
                set = function()
                    db.showDepletion = not db.showDepletion
                    BagSlots:UpdateSlotCount()
                end,
            },
            showTotal = {
                name = L["Show Total"],
                desc = L["Show total slots per bag."],
                type = "toggle",
                order = 200,
                set = function()
                    db.showTotal = not db.showTotal
                    BagSlots:UpdateSlotCount()
                end,
            },
            textPosition = {
                name = L["Text Position"],
                desc = L["Change the position of the usage text on the bags."],
                type = "select",
                order = 400,
                values = { BOTTOM = L["Bottom"], TOP = L["Top"] },
                set = function(info, v)
                    db.textPosition = v
                    BagSlots:UpdateOverlay()
                end,
            },
        },
    }
    return options
end

local function openOptions()
    if Settings and Settings.OpenToCategory then
        Settings.OpenToCategory(addonOptionsFrameName)
    else
        InterfaceOptionsFrame_OpenToCategory(L["BagSlots"])
    end
end

function BagSlots:OnInitialize()
    local _

    -- Grab our DB
    self.db = LibStub("AceDB-3.0"):New("BagSlotsDB", defaults, "Default")
    db = self.db.profile

    -- Register our options
    LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable(
        L["BagSlots"],
        getOptions
    )

    _, addonOptionsFrameName = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(
        L["BagSlots"],
        L["BagSlots"]
    )

    -- Register chat command
    self:RegisterChatCommand("bagslots", openOptions)

    -- Prepare the overlay
    BagSlots:UpdateOverlay()
end

-- Start
function BagSlots:OnEnable()
    self:RegisterBucketEvent("BAG_UPDATE", 1, "UpdateSlotCount")
    self:UpdateSlotCount()
end

function BagSlots:OnDisable()
    for _, bag in ipairs(bags) do
        _G[bag.."BagSlotsStr"]:SetText("")
    end
end

function BagSlots:UpdateOverlay()
    local font, _, flags = NumberFontNormal:GetFont()

    -- Used for working out the offsets
    local bottom = db.textPosition == "BOTTOM" and true or false

    for _, bag in ipairs(bags) do
        local BagSlot = _G[bag]
        if not _G[bag.."BagSlotsStr"] then
            local BPStr = BagSlot:CreateFontString(
                bag.."BagSlotsStr",
                "OVERLAY"
            )
            BPStr:SetFont(font, fontSize, flags)
            BPStr:SetPoint(
                "CENTER",
                BagSlot,
                db.textPosition,
                0,
                bottom and 6 or -6
            )
        else
            _G[bag.."BagSlotsStr"]:SetPoint(
                "CENTER",
                BagSlot,
                db.textPosition,
                0,
                bottom and 6 or -6
            )
        end
    end
end

function BagSlots:UpdateSlotCount()
    for bag = 0, NUM_BAG_SLOTS do
        local numSlots = GetContainerNumSlots(bag)

        if numSlots == 0 then
            return
        else
            local slotsText
            local freeSlots, bagType = GetContainerNumFreeSlots(bag)
            local usedSlots = numSlots - freeSlots
            local bagslot = _G[bags[bag + 1] .. "BagSlotsStr"]

            -- Colour the string before we check for showDepletion
            bagslot:SetTextColor(
                Crayon:GetThresholdColor(
                    usedSlots / numSlots,
                    1,
                    0.8,
                    0.6,
                    0.4,
                    0.2
                )
            )

            if db.showDepletion then
                usedSlots = numSlots - usedSlots
            end

            -- Decide what our string will be
            if db.showTotal then
                slotsText = ("%d/%d"):format(usedSlots, numSlots)
            else
                slotsText = usedSlots
            end

            -- Show the string :)
            bagslot:SetText(slotsText)
        end
    end
end
