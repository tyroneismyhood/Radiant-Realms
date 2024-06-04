local FilterText = {}

local TextService = game:GetService("TextService")

local function GetTextObject(Message, FromPlayerID)
    local Success, TextObject = pcall(function()
        return TextService:FilterStringAsync(Message, FromPlayerID, Enum.TextFilterContext.PublicChat)
    end)

    if not Success then
        warn("[FilterText] Error on filtering text to text object! Error: \"" .. tostring(TextObject) .. "\"")
        return nil
    end

    return TextObject
end

local function GetFilteredMessage(TextObject, ToPlayerID)
    local Success, FilteredMessage = pcall(function()
        return TextObject:GetChatForUserAsync(ToPlayerID)
    end)

    if not Success then
        warn("[FilterText] Error on filtering text message! Error: \"" .. tostring(FilteredMessage) .. "\"")
        return nil
    end

    return FilteredMessage
end

function FilterText:FilterText(Player, Text)
    if not (Player and Text) then
        return nil
    end

    local TextObject = GetTextObject(Text, Player.UserId)

    if not TextObject then
        return nil
    end

    local FilteredMessage = GetFilteredMessage(TextObject, Player.UserId)
	
    return FilteredMessage
end

return FilterText