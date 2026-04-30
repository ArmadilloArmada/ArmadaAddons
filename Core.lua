--[[
@armada-addon-system
@version 1.0.0
@author Arman

SYSTEM: ArmadaAddons Hub Registration
PURPOSE: Every new addon built by Arman MUST register itself with ArmadaAddons
         so it appears as a card in the hub UI automatically.

RULE: When creating or editing any Arman WoW addon, always append the
      registration block below at the bottom of Core.lua after all events.
      Never skip this step. Never hardcode addon lists inside ArmadaAddons.

REGISTRATION BLOCK (copy this, do not modify the structure):

    C_Timer.After(0, function()
        if ArmadaAddons and ArmadaAddons.Register then
            ArmadaAddons.Register({
                name    = "Your Addon Name",
                version = "1.0.0",
                desc    = "One line description of what it does.",
                color   = { r, g, b },
                open    = function()
                    ToggleUI()
                end,
            })
        end
    end)

COLORS:
    Gold   { 1, 0.82, 0.1 }
    Blue   { 0.48, 0.78, 1 }
    Red    { 1, 0.45, 0.45 }
    Green  { 0.4, 1, 0.4 }
    Purple { 0.78, 0.48, 1 }

SAFETY: If ArmadaAddons is not installed the block is silently ignored.
--]]

local ADDON_NAME = "ArmadaAddons"

local db
local ui = {}

-- Shared global registry — other addons call ArmadaAddons.Register() to add themselves
ArmadaAddons = ArmadaAddons or {}
ArmadaAddons.registry = ArmadaAddons.registry or {}

function ArmadaAddons.Register(entry)
    if not entry or not entry.name then return end
    for _, existing in ipairs(ArmadaAddons.registry) do
        if existing.name == entry.name then return end
    end
    ArmadaAddons.registry[#ArmadaAddons.registry + 1] = entry
    -- If the hub UI is already built, rebuild it to include the new card
    if ui.frame then
        ui.frame:Hide()
        ui.frame = nil
        CreateUI()
    end
end

local function EnsureDB()
    ArmadaAddonsDB = ArmadaAddonsDB or {}
    db = ArmadaAddonsDB
    db.position = db.position or { point = "CENTER", x = 0, y = 0 }
    db.minimap = db.minimap or { angle = 240, hide = false }
end

local function UpdateMinimapButton()
    if not ui.minimapButton then return end
    local angle = math.rad(db.minimap.angle or 240)
    local r = Minimap:GetWidth() / 2
    ui.minimapButton:ClearAllPoints()
    ui.minimapButton:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle) * r, math.sin(angle) * r)
    if db.minimap.hide then
        ui.minimapButton:Hide()
    else
        ui.minimapButton:Show()
    end
end

local function ToggleUI()
    if not ui.frame then return end
    if ui.frame:IsShown() then
        ui.frame:Hide()
    else
        ui.frame:Show()
    end
end

local function CreateMinimapButton()
    if ui.minimapButton or not Minimap then return end

    local button = CreateFrame("Button", "ArmadaAddonsMinimapButton", UIParent)
    button:SetSize(36, 36)
    button:SetFrameStrata("MEDIUM")
    button:SetMovable(true)
    button:SetClampedToScreen(true)
    button:RegisterForDrag("LeftButton")
    button:SetNormalTexture("")
    button:SetHighlightTexture("")

    button.border = button:CreateTexture(nil, "BORDER")
    button.border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    button.border:SetSize(40, 40)
    button.border:SetPoint("CENTER", button, "CENTER", 0, 0)

    button.icon = button:CreateTexture(nil, "ARTWORK")
    button.icon:SetTexture(136012)
    button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    button.icon:SetPoint("CENTER", button, "CENTER", 0, 0)
    button.icon:SetSize(22, 22)

    button.highlight = button:CreateTexture(nil, "HIGHLIGHT")
    button.highlight:SetTexture(136012)
    button.highlight:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    button.highlight:SetAllPoints(button)
    button.highlight:SetAlpha(0.12)

    button:SetScript("OnClick", ToggleUI)
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText("Armada Addons")
        GameTooltip:AddLine("Click to open the addon hub.", 1, 1, 1)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function() GameTooltip:Hide() end)
    button:SetScript("OnDragStart", function(self) self:StartMoving() end)
    button:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local cx, cy = Minimap:GetCenter()
        local x, y = self:GetCenter()
        db.minimap.angle = math.deg(math.atan2(y - cy, x - cx))
    end)

    ui.minimapButton = button
    C_Timer.After(0, UpdateMinimapButton)
end

function CreateUI()
    local registry = ArmadaAddons.registry
    local CARD_HEIGHT = 80
    local PADDING = 14
    local count = math.max(#registry, 1)
    local frameHeight = 60 + PADDING + count * CARD_HEIGHT + (count - 1) * 10 + PADDING

    local frame = CreateFrame("Frame", "ArmadaAddonsFrame", UIParent, "BackdropTemplate")
    frame:SetSize(420, frameHeight)
    frame:SetPoint(db.position.point, UIParent, db.position.point, db.position.x, db.position.y)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetClampedToScreen(true)
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 10, right = 10, top = 10, bottom = 10 },
    })
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, _, _, x, y = self:GetPoint(1)
        db.position.point = point
        db.position.x = x
        db.position.y = y
    end)

    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.title:SetPoint("TOPLEFT", 18, -16)
    frame.title:SetText("|cffffcc00Armada|r Addons")

    frame.subtitle = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    frame.subtitle:SetPoint("TOPLEFT", 18, -36)
    frame.subtitle:SetText("Armada Studios  —  " .. #registry .. " addon" .. (#registry == 1 and "" or "s") .. " registered")

    frame.close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    frame.close:SetPoint("TOPRIGHT", -8, -8)

    if #registry == 0 then
        local empty = frame:CreateFontString(nil, "OVERLAY", "GameFontDisable")
        empty:SetPoint("CENTER", frame, "CENTER", 0, 0)
        empty:SetText("No addons registered yet.")
    end

    for index, entry in ipairs(registry) do
        local color = entry.color or { 1, 1, 1 }

        local card = CreateFrame("Frame", nil, frame, "BackdropTemplate")
        card:SetSize(388, CARD_HEIGHT)
        card:SetPoint("TOPLEFT", 16, -56 - ((index - 1) * (CARD_HEIGHT + 10)))
        card:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 16, edgeSize = 12,
            insets = { left = 3, right = 3, top = 3, bottom = 3 },
        })
        card:SetBackdropColor(0.05, 0.05, 0.06, 0.9)

        local bar = card:CreateTexture(nil, "ARTWORK")
        bar:SetSize(4, CARD_HEIGHT - 8)
        bar:SetPoint("LEFT", 6, 0)
        bar:SetColorTexture(color[1], color[2], color[3], 1)

        local nameText = card:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        nameText:SetPoint("TOPLEFT", 18, -12)
        nameText:SetText(string.format("|cff%02x%02x%02x%s|r",
            math.floor(color[1] * 255),
            math.floor(color[2] * 255),
            math.floor(color[3] * 255),
            entry.name))

        local version = card:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        version:SetPoint("TOPLEFT", 18, -28)
        version:SetText("v" .. (entry.version or "1.0.0"))

        local desc = card:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        desc:SetPoint("TOPLEFT", 18, -44)
        desc:SetPoint("RIGHT", -110, -44)
        desc:SetJustifyH("LEFT")
        desc:SetText(entry.desc or "")

        local btn = CreateFrame("Button", nil, card, "UIPanelButtonTemplate")
        btn:SetSize(90, 26)
        btn:SetPoint("RIGHT", -10, 0)
        btn:SetText("Open")
        btn:SetScript("OnClick", function()
            frame:Hide()
            if entry.open then entry.open() end
        end)
    end

    ui.frame = frame
    frame:Hide()
end

SLASH_ARMADAADDONS1 = "/armada"
SLASH_ARMADAADDONS2 = "/aa"
SlashCmdList.ARMADAADDONS = function()
    ToggleUI()
end

EventUtil.ContinueOnAddOnLoaded(ADDON_NAME, function()
    EnsureDB()
    -- Defer UI creation so all addons have time to register first
    C_Timer.After(0, function()
        CreateUI()
        if not db.minimap.hide then
            CreateMinimapButton()
        end
    end)
end)

EventRegistry:RegisterCallback("PLAYER_ENTERING_WORLD", function()
    if not db then EnsureDB() end
    if not ui.minimapButton and not db.minimap.hide then
        CreateMinimapButton()
    end
end, {})
