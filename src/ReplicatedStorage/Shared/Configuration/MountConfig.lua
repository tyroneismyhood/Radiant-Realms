local function CreateMount(DisplayName, BaseSpeed, Rarity, MovementMode, Acceleration, Deceleration, JumpPower, AnimationResolver, Description, Float, Icon, Animation)
    return {
        DisplayName = DisplayName,
        BaseSpeed = BaseSpeed,
        Rarity = Rarity,
        MovementMode = MovementMode,
        Acceleration = Acceleration,
        Deceleration = Deceleration,
        JumpPower = JumpPower,
        AnimationResolverType = AnimationResolver,
        Description = Description,
        Float = Float,
        Icon = Icon,
        Animation = Animation
    }
end

return {
    -- Off limits
    ["Cerulean Surf"] = CreateMount("Cerulean Surf", 52, "Common", "MountPlatform", 52 * 5, 52 * 7, 40, "Loop", "Ride the waves of the virtual sea with this rare mount!", true, "rbxassetid://16863352176", "rbxassetid://17261339268"),
    --

    -- Merchant Boards (3)
    ["Rose Hopper"] = CreateMount("Rose Hopper", 57, "Rare", "MountPlatform", 57 * 5, 57 * 7, 40, "Loop", "Leap through landscapes with this rare and agile mount!", true, "rbxassetid://16863365615", "rbxassetid://17261339268"),
    ["Emerald Runner"] = CreateMount("Emerald Runner", 62, "Elite", "MountPlatform", 62 * 5, 62 * 7, 40, "Loop", "Dash through the games world with elite swiftness", true, "rbxassetid://16863353817", "rbxassetid://17261339268"),
    ["Sun Chaser"] = CreateMount("Sun Chaser", 65, "Legendary", "MountPlatform", 65 * 5, 65 * 7, 40, "Loop", "Chase the horizon with this legendary mount!", true, "rbxassetid://16863366580", "rbxassetid://17261339268"),

    -- NPC quests
    ["Azure Glide"] = CreateMount("Azure Glide", 58, "Rare", "MountPlatform", 58 * 5, 58 * 7, 40, "Loop", "Glide with ease on this sleek rare mount!", true, "rbxassetid://16863351201", "rbxassetid://17261339268"),
    ["Sunset Cruiser"] = CreateMount("Sunset Cruiser", 55, "Rare", "MountPlatform", 55 * 5, 55 * 7, 40, "Loop", "Enjoy a serene cruise with the colors of the dusk!", true, "rbxassetid://16863367390", "rbxassetid://17261339268"),
    ["Magenta Maze"] = CreateMount("Magenta Maze", 60, "Elite", "MountPlatform", 60 * 5, 60 * 7, 40, "Loop", "Get lost in the beauty of this elite and meserizing mount!", true, "rbxassetid://16863359798", "rbxassetid://17261339268"),
    --

    -- Minigame
    ["Neon Nectar"] = CreateMount("Neon Nectar", 68, "Mythical", "MountPlatform", 68 * 5, 68 * 7, 40, "Loop", "This mythical mount buzzes with an otherworldly glow!", true, "rbxassetid://16863362065", "rbxassetid://17261339268"),
    ["Nimbus Float"] = CreateMount("Nimbus Float", 72, "Mythical", "MountPlatform", 72 * 5, 72 * 7, 40, "Loop", "A true rarity, embodying the tranquility of the skies!", true, "rbxassetid://16863363855", "rbxassetid://17261339268")
    --
}