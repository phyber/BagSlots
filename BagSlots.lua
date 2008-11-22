local BagSlots = LibStub("AceAddon-3.0"):NewAddon("BagSlots", "AceBucket-3.0", "AceConsole-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("BagSlots")
local Crayon = LibStub("LibCrayon-3.0")
local db -- Filled in later
local _G = _G
local ipairs = ipairs
local GetContainerNumSlots = GetContainerNumSlots
local GetContainerNumFreeSlots = GetContainerNumFreeSlots
local fontSize = 12
-- Default options
local defaults = {
	profile = {
		showDepletion = false,
		showTotal = true,
		textPosition = "BOTTOM",
		onAmmoBags = false,
	},
}
-- Names of the bag slots.
local bags = {
	"MainMenuBarBackpackButton",
	"CharacterBag0Slot",
	"CharacterBag1Slot",
	"CharacterBag2Slot",
	"CharacterBag3Slot"
}

local function getOptions()
	local options = {
		type = "group",
		name = L["BagSlots"],
		args = {
			bsdesc = {
				type = "description",
				order = 0,
				name = L["Display bag usage on each of your bag slots."],
			},
			depletion = {
				name = L["Show Depletion"],
				desc = L["Show depletion of bag slots."],
				type = "toggle",
				order = 100,
				get = function() return db.showDepletion end,
				set = function()
					db.showDepletion = not db.showDepletion
					BagSlots:UpdateSlotCount()
				end,
			},
			total = {
				name = L["Show Total"],
				desc = L["Show total slots per bag."],
				type = "toggle",
				order = 200,
				get = function() return db.showTotal end,
				set = function()
					db.showTotal = not db.showTotal
					BagSlots:UpdateSlotCount()
				end,
			},
			ammobags = {
				name = L["Ammo Bags"],
				desc = L["Show usage on Ammo Bags."],
				type = "toggle",
				order = 300,
				get = function() return db.onAmmoBags end,
				set = function()
					db.onAmmoBags = not db.onAmmoBags
					BagSlots:UpdateSlotCount()
				end,
			},
			position = {
				name = L["Text Position"],
				desc = L["Change the position of the usage text on the bags."],
				type = "select",
				order = 400,
				values = { BOTTOM = L["Bottom"], TOP = L["Top"] },
				get = function()
					return db.textPosition
				end,
				set = function(info, v)
					db.textPosition = v
					BagSlots:UpdateOverlay()
				end,
			},
		},
	}
	return options
end

function BagSlots:OnInitialize()
	-- Grab our DB
	self.db = LibStub("AceDB-3.0"):New("BagSlotsDB", defaults, "Default")
	db = self.db.profile
	-- Register our options
	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable(L["BagSlots"], getOptions)
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions(L["BagSlots"], L["BagSlots"])
	-- Register chat command
	self:RegisterChatCommand("bagslots", function() InterfaceOptionsFrame_OpenToCategory(LibStub("AceConfigDialog-3.0").BlizOptions["BagSlots"].frame) end)
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
			local BPStr = BagSlot:CreateFontString(bag.."BagSlotsStr", "OVERLAY")
			BPStr:SetFont(font, fontSize, flags)
			BPStr:SetPoint("CENTER", BagSlot, db.textPosition, 0, bottom and 6 or -6)
		else
			_G[bag.."BagSlotsStr"]:SetPoint("CENTER", BagSlot, db.textPosition, 0, bottom and 6 or -6)
		end
	end	
end

local function IsAmmoBag(bagType)
	-- 4: Soul Bag
	-- 2: Ammo Pouch
	-- 1: Quiver
	if bagType == 4 or bagType == 2 or bagType == 1 then
		return true
	end
	return false
end

function BagSlots:UpdateSlotCount()
	for bag = 0, 4 do
		local numSlots = GetContainerNumSlots(bag)

		if numSlots == 0 then
			return
		else
			local slotsText
			local freeSlots, bagType = GetContainerNumFreeSlots(bag)
			local usedSlots = numSlots - freeSlots
			local bagslot = _G[bags[bag+1].."BagSlotsStr"]

			-- Colour the string before we check for showDepletion
			bagslot:SetTextColor(Crayon:GetThresholdColor(usedSlots/numSlots, 1, 0.8, 0.6, 0.4, 0.2))

			if db.showDepletion then
				usedSlots = numSlots - usedSlots
			end

			-- Decide what our string will be
			if db.showTotal then
				slotsText = usedSlots.."/"..numSlots
			else
				slotsText = usedSlots
			end

			-- Show the string :)
			if not db.onAmmoBags and IsAmmoBag(bagType) then
				bagslot:SetText("")
			else
				bagslot:SetText(slotsText)
			end
		end
	end
end
