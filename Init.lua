local select = select
local T, C, L = Tukui:unpack();
local Panels = T.Panels;

local Class = select(2, UnitClass("player"))
local ClassColor = T.Colors.class[Class]

local Texture = T.GetTexture(C["Textures"].QuestProgressTexture)
local R, G, B = unpack(T.Colors.class[T.MyClass])

local showInfoFrame = 1
tokenInfoFrame = nil

local locpanel = CreateFrame("Frame", "locpanel", UIParent)
locpanel:SetTemplate()
locpanel:SetSize(520, 22)
locpanel:SetPoint("TOP", UIParent, "TOP", 0, -14)
locpanel:SetFrameLevel(0)
locpanel:SetFrameStrata("BACKGROUND")
locpanel:EnableMouse(false)
locpanel:SetAlpha(1)

local locbar = CreateFrame("StatusBar", "locbar", UIParent)
locbar:SetTemplate()
locbar:SetFrameStrata("BACKGROUND")
locbar:SetFrameLevel(1)
locbar:SetPoint("TOP", UIParent, "TOP", 0, -17)
locbar:SetMinMaxValues(0, 100);
locbar:SetValue(35);
locbar:SetSize(510, 16)
locbar:SetStatusBarTexture(Texture)
locbar:SetStatusBarColor(1, 1, 0, 0.8)

local LocationText = locbar:CreateFontString(nil, "OVERLAY")
LocationText:SetFont(C["Medias"].Font, 14, "OUTLINE")
LocationText:SetTextColor(1, 1, 0)
LocationText:SetText("0 %")
LocationText:SetPoint("CENTER", locbar, "CENTER", 0, 0)
LocationText:SetJustifyH("CENTER")

local frame, events = CreateFrame("Frame"), {};

C_WowTokenPublic.UpdateMarketPrice();
local PGGold = math.floor(math.abs((GetMoney() / 100 / 100)));
local tokenPrice = C_WowTokenPublic.GetCurrentMarketPrice();
if tokenPrice == nil then
    tokenPrice = 0;
else
    tokenPrice = tokenPrice / 100 / 100;
end

frame:RegisterEvent("PLAYER_ENTERING_WORLD");
frame:RegisterEvent("PLAYER_MONEY");
frame:RegisterEvent("PLAYER_TRADE_MONEY");

local function createTokenInfo()
    C_WowTokenPublic.UpdateMarketPrice();
    local tokenPriceTmp = C_WowTokenPublic.GetCurrentMarketPrice() / 100 / 100;

    tokenInfoFrame = CreateFrame("Frame", "tokenInfoFrame", UIParent)
    tokenInfoFrame:SetTemplate()
    tokenInfoFrame:SetSize(640, 420)
    tokenInfoFrame:SetPoint("TOP", UIParent, "TOP", 0, -100)
    tokenInfoFrame:SetFrameLevel(0)
    tokenInfoFrame:SetFrameStrata("BACKGROUND")
    tokenInfoFrame:EnableMouse(false)
    
    local tokenInfoFrameBackground = tokenInfoFrame:CreateTexture()
    tokenInfoFrameBackground:SetTexture("Interface\\Store\\Store-Main")
    tokenInfoFrameBackground:SetTexCoord(0, 0.562, 0, 0.46)
    tokenInfoFrameBackground:SetPoint("CENTER", 0, 0)
    tokenInfoFrameBackground:SetWidth(640)
    tokenInfoFrameBackground:SetHeight(420)
    
    local button = CreateFrame("Button", nil, tokenInfoFrame)
    button:SetPoint("BOTTOM", tokenInfoFrame, "BOTTOM", 0, 20)
    button:SetWidth(150)
    button:SetHeight(40)
    button:SetText("Close")
    button:SetNormalFontObject("GameFontNormal")
    button:SetScript("OnClick", function()
        tokenInfoFrame:Hide()
    end)
    local ntex = button:CreateTexture()
    ntex:SetTexture("Interface\\Buttons\\UI-Panel-Button-Up")
    ntex:SetTexCoord(0, 0.625, 0, 0.6875)
    ntex:SetAllPoints()	
    button:SetNormalTexture(ntex)
    local htex = button:CreateTexture()
    htex:SetTexture("Interface\\Buttons\\UI-Panel-Button-Highlight")
    htex:SetTexCoord(0, 0.625, 0, 0.6875)
    htex:SetAllPoints()
    button:SetHighlightTexture(htex)
    local ptex = button:CreateTexture()
    ptex:SetTexture("Interface\\Buttons\\UI-Panel-Button-Down")
    ptex:SetTexCoord(0, 0.625, 0, 0.6875)
    ptex:SetAllPoints()
    button:SetPushedTexture(ptex)

    local locbarinfo = CreateFrame("StatusBar", "locbarinfo", tokenInfoFrame)
    locbarinfo:SetTemplate()
    locbarinfo:SetFrameStrata("BACKGROUND")
    locbarinfo:SetFrameLevel(1)
    locbarinfo:SetPoint("BOTTOM", tokenInfoFrame, "BOTTOM", 0, 120)
    locbarinfo:SetMinMaxValues(0, tokenPriceTmp);
    locbarinfo:SetValue(math.floor(math.abs(GetMoney() / 100 / 100)));
    locbarinfo:SetSize(480, 24)
    locbarinfo:SetStatusBarTexture(Texture)
    locbarinfo:SetStatusBarColor(1, 1, 0, 0.8)

    local tokenPrices = tokenInfoFrame:CreateFontString(nil, "OVERLAY")
    tokenPrices:SetFont(C["Medias"].Font, 18, "OUTLINE")
    tokenPrices:SetTextColor(1, 1, 0)
    tokenPrices:SetText(math.floor(math.abs(GetMoney() / 100 / 100)).." / "..tokenPriceTmp)
    tokenPrices:SetPoint("BOTTOM", tokenInfoFrame, "BOTTOM", 0, 160)
    tokenPrices:SetJustifyH("BOTTOM")

    local tokenInfoBodyText = tokenInfoFrame:CreateFontString(nil, "OVERLAY")
    tokenInfoBodyText:SetFont(C["Medias"].Font, 28, "OUTLINE")
    tokenInfoBodyText:SetTextColor(1, 1, 0)
    tokenInfoBodyText:SetText("WoW Token progress")
    tokenInfoBodyText:SetPoint("TOP", tokenInfoFrame, "TOP", 0, -80)
    tokenInfoBodyText:SetJustifyH("TOP")

    local tokenInfoIcon = tokenInfoFrame:CreateTexture()
    tokenInfoIcon:SetTexture("Interface\\ICONS\\WoW_Token01")
    tokenInfoIcon:SetTexCoord(0, 1, 0, 1)
    tokenInfoIcon:SetPoint("BOTTOM", tokenInfoFrame, "BOTTOM", 0, 200)
    tokenInfoIcon:SetWidth(64)
    tokenInfoIcon:SetHeight(64)
end

local function progressBarUpdates()
    PGGold = math.floor(math.abs((GetMoney() / 100 / 100)));
    C_WowTokenPublic.UpdateMarketPrice();
    tokenPrice = C_WowTokenPublic.GetCurrentMarketPrice();
    if tokenPrice == nil then
        C_WowTokenPublic.UpdateMarketPrice();
    else
        tokenPrice = tokenPrice / 100 / 100;
    end

    locbar:SetMinMaxValues(0, tokenPrice);
    locbar:SetValue(PGGold);

    local percentage = math.floor(((PGGold * 100) / tokenPrice) * 10) / 10;
    if(percentage < 0) then percentage = 100; end

    LocationText:SetText(percentage.." %")
end

local function eventHandler(self, event, ...)

    if event == "PLAYER_TRADE_MONEY" then
        progressBarUpdates()
    end
    if event == "PLAYER_MONEY" then
        progressBarUpdates()
    end
    if event == "PLAYER_ENTERING_WORLD" then
        progressBarUpdates()
        print("Tukui WoW Token progress loaded")
        print("Write in chat '/wowtokenshow' to show info window")
    end

end

frame:SetScript("OnEvent", eventHandler);

SLASH_TEST1 = "/wowtokenshow"
SLASH_TEST2 = "/wtshow"
SlashCmdList["TEST"] = function(msg)
    createTokenInfo()
end 
