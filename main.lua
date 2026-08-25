-- VARIABLES ----------------------------------------------------------------------------------------
-- General Configs
local Config = {
    fullScreen = true,
    backgroundColour = {255, 255, 255},
    -- NPC
    npcSpeed = 0.09,
    npcSizeInitial = 20.0,
    npcInitialX = love.graphics.getWidth() / 2,
    npcInitialY = love.graphics.getHeight() + 500,
    -- Player
    lineWidth = 5, -- NPC and player share the same line width
    pjSizeInitial = 10.0,
    -- Shake
    shakeRangeMax = 2.0,
    -- Final Text draw position according to Fullscreen or Windowed mode
    xDistToAnimFS = 300,
    xDistToAnimWin = 50,
    yDistToAnim = 100,
    finalText = "Why did you run away?" -- Final message to display when the player reaches the NPC
}

-- Diferent game states and events trigger conditions
local Trigger = {
    -- Distance to trigger events
    startStage1 = 300.0,
    beginShake = 300.0,
    beginToDecrease = 250.0,
    startStage2 = 100.0,
    startWhistle = 60.0,
    distEnd = 2.0 -- Distance between NPC and player to trigger the outro
}

-- Outro animation configurations
local Anim = {
    size = Config.pjSizeInitial,
    repeated = 0,
    maxRepeats = 8,
    increment = 3.0,
    maxDiameter = 11.0,
    delaySecondsToStartBeats = 2.0,
    outerCircleMultiplier = 2
}

-- Audio configurations
local Audio = {
    audioInitialVolume = 1,
    volMusic = 0.15,
    s1Max = 1.0,
    volBeat = 0.1,
    incVolBeat = 0.2,
    paths = {
        music = "Audio/Music/WhyDidYouRunAwayMusicDeep.mp3",
        sound1 = "Audio/Sounds/high-theta.mp3",
        sound2 = "Audio/Sounds/noise.mp3",
        whistle = "Audio/Sounds/whistle.wav",
        beat = "Audio/Sounds/beat.mp3"
    }
}

-- State Definitions & Runtime Variables
local GameState = {
    GAMEPLAY = "gameplay",
    OUTRO = "outro"
}

local AnimState = {
    INTRO = "intro",
    GROWTH = "growth",
    DECREASE = "decrease",
    WAITING = "waiting"
}

local Game = {
    state = GameState.GAMEPLAY,
    beatAnimationState = AnimState.INTRO,
    distancePJ_NPC = 0,
    timeToBeginBeats = 0,
    timeBetweenBeats = 0
}

local Player = {
    x = 0,
    y = 0,
    size = Config.pjSizeInitial,
    lineWidth = Config.lineWidth
}

local NPC = {
    x = 0,
    y = 0,
    size = Config.npcSizeInitial,
    speed = Config.npcSpeed,
    lineWidth = Config.lineWidth
}

-- FUNCTIONS ----------------------------------------------------------------------------------------

-- Interpolates the volume factor based on the current distance between two points
local function getVolumeFactor(currentDist, startDist, endDist)

        local t = (startDist - currentDist) / (startDist - endDist)

        if t < 0 then t = 0 end
        if t > 1 then t = 1 end

        return t
end

-- Calculates the volume of the different sounds according to the position between the NPC and the player
local function updateAudioDistances()

    -- Soft Distortion Sound (Sound 1)
    if Game.distancePJ_NPC < Trigger.startStage1 then

        -- Calculate the volume factor based on the current distance and the start/end distances for the sound
        local volFactor = getVolumeFactor(Game.distancePJ_NPC, Trigger.startStage1, Trigger.startStage2)
        -- The volFactor ^ 2 is used to create a smoother transition in volume as the player approaches the NPC
        Audio.sound1:setVolume(volFactor ^ 2 * Audio.s1Max)
        -- The volume of the music is adjusted based on the distance between the player and the NPC
        Audio.music:setVolume((Game.distancePJ_NPC / Trigger.startStage1) * Audio.volMusic)
    else
        Audio.sound1:setVolume(0)
        Audio.music:setVolume(Audio.volMusic)
    end

    -- Hard Distortion Sound (Sound 2)
    if Game.distancePJ_NPC < Trigger.startStage2 then

        local volFactor = getVolumeFactor(Game.distancePJ_NPC, Trigger.startStage2, Trigger.startWhistle)
        Audio.sound2:setVolume(volFactor ^ 2)
    else
        Audio.sound2:setVolume(0)
    end

    -- Whistle Sound
    if Game.distancePJ_NPC < Trigger.startWhistle then

        local volFactor = getVolumeFactor(Game.distancePJ_NPC, Trigger.startWhistle, Trigger.distEnd)
        Audio.whistle:setVolume(volFactor ^ 2)
    else
        Audio.whistle:setVolume(0)
    end
end

-- Pauses the game (stops the NPC) when the mouse is out of the boundaries of the screen in windowed versions
local function gamePauser()
    
    local mx, my = love.mouse.getX(), love.mouse.getY()
    local gw, gh = love.graphics.getWidth(), love.graphics.getHeight()

    if (mx == 0 or mx == gw - 1 or my == 0 or my == gh - 1) and not Config.fullScreen then
        NPC.speed = 0
    else
        NPC.speed = Config.npcSpeed
    end
end

-- esc = quit game
function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end

-- LOOP FUNCTIONS ----------------------------------------------------------------------------------------

local function updateGameplay(dt)

    -- NPC Movement (Moving the npc before forces the player to go inside it to complete the game. If not, the npc can just complete the game by itself)
    NPC.x = NPC.x + (love.mouse.getX() - NPC.x) * (NPC.speed * dt)
    NPC.y = NPC.y + (love.mouse.getY() - NPC.y) * (NPC.speed * dt)

    -- Player Movement
    Player.x = love.mouse.getX()
    Player.y = love.mouse.getY()

    -- Calculate distance between player and NPC
    Game.distancePJ_NPC = math.sqrt((Player.x - NPC.x)^2 + (Player.y - NPC.y)^2)

    -- Shake
    if Game.distancePJ_NPC < Trigger.beginShake then

        local shakeRange = math.pow(1 - (Game.distancePJ_NPC / Trigger.beginShake), 2) * Config.shakeRangeMax

        NPC.x = love.math.random(NPC.x - shakeRange, NPC.x + shakeRange)
        NPC.y = love.math.random(NPC.y - shakeRange, NPC.y + shakeRange)

        Player.x = love.math.random(Player.x - shakeRange, Player.x + shakeRange)
        Player.y = love.math.random(Player.y - shakeRange, Player.y + shakeRange)
    end

    -- Player size and line width decrease
    if Game.distancePJ_NPC < Trigger.beginToDecrease then
        Player.size = Config.pjSizeInitial / (Trigger.beginToDecrease / Game.distancePJ_NPC)
        Player.lineWidth = Config.lineWidth / (Trigger.beginToDecrease / Game.distancePJ_NPC)
    else
        Player.size = Config.pjSizeInitial
        Player.lineWidth = Config.lineWidth
    end

    updateAudioDistances()

    -- Transition to outro state when the player is close enough to the NPC
    if Game.distancePJ_NPC < Trigger.distEnd then
        Game.timeToBeginBeats = love.timer.getTime()
        Game.timeBetweenBeats = love.timer.getTime() + Anim.delaySecondsToStartBeats

        Game.state = GameState.OUTRO

        love.audio.stop(Audio.music)
        love.audio.stop(Audio.sound1)
        love.audio.stop(Audio.sound2)
        love.audio.stop(Audio.whistle)
    end
end

local function updateOutro(dt)
    if love.timer.getTime() > Game.timeToBeginBeats + Anim.delaySecondsToStartBeats then

        -- Beats Animation begins after the delay
        if Game.beatAnimationState == AnimState.INTRO then

            Audio.beat:play()
            Game.beatAnimationState = AnimState.GROWTH

            -- NPC/Player are growing
        elseif Game.beatAnimationState == AnimState.GROWTH then

            if Anim.size < Anim.maxDiameter then
                Anim.size = Anim.size + (Anim.increment * dt)
            else
                Game.beatAnimationState = AnimState.DECREASE
            end

            -- NPC/Player are decreasing
        elseif Game.beatAnimationState == AnimState.DECREASE then

            if Anim.size > Config.pjSizeInitial then
                Anim.size = Anim.size - (Anim.increment * dt)
            else
                Game.beatAnimationState = AnimState.WAITING
                Game.timeBetweenBeats = love.timer.getTime()
            end

            -- NPC/Player are waiting for the next beat
        elseif Game.beatAnimationState == AnimState.WAITING then

            if love.timer.getTime() >= Game.timeBetweenBeats + Anim.delaySecondsToStartBeats then
                Anim.repeated = Anim.repeated + 1

                -- If game is not ended yet
                if Anim.repeated < Anim.maxRepeats then
                    Audio.beat:play()
                    Audio.volBeat = Audio.volBeat + Audio.incVolBeat
                    Audio.beat:setVolume(Audio.volBeat)
                    Game.beatAnimationState = AnimState.GROWTH
                else
                    --ENDGAME
                    love.event.quit()
                end
            end

        end
    end
end

local function drawGameplay()
    love.graphics.setLineWidth(NPC.lineWidth)
    love.graphics.circle("line", NPC.x, NPC.y, NPC.size)

    love.graphics.setLineWidth(Player.lineWidth)
    love.graphics.circle("line", Player.x, Player.y, Player.size)
end

local function drawOutro()

    -- Draw the final text message
    local textX = (Player.x <= love.graphics.getWidth() / 2) and Config.xDistToAnim or
                      (love.graphics.getWidth() / 2 + Config.xDistToAnim) -- If the player is on the left side of the screen, print the text on the right side, and vice versa
    local textY = (Player.y <= love.graphics.getHeight() / 2) and (Player.y + Config.yDistToAnim) or
                      (Player.y - Config.yDistToAnim) -- If the player is on the top side of the screen, print the text below, and vice versa
    love.graphics.print(Config.finalText, textX, textY)

    if love.timer.getTime() > Game.timeToBeginBeats + Anim.delaySecondsToStartBeats then

        -- Draw the NPC and Player circles with the current size based on the beat animation state
        if Game.beatAnimationState == AnimState.GROWTH or Game.beatAnimationState == AnimState.DECREASE then

            -- Draw the circles with a line width proportional to their size
            local proportionalLineWidth = Config.lineWidth * (Anim.size / Config.pjSizeInitial)
            love.graphics.setLineWidth(proportionalLineWidth)

            love.graphics.circle("line", Player.x, Player.y, Anim.size)
            love.graphics.circle("line", Player.x, Player.y, Anim.size * 2)

            -- Draw the circles in the "waiting" state, waiting between beats
        elseif Game.beatAnimationState == AnimState.WAITING then

            -- Draw the circles with the initial size values
            love.graphics.setLineWidth(Config.lineWidth)
            love.graphics.circle("line", Player.x, Player.y, Config.pjSizeInitial)
            love.graphics.circle("line", Player.x, Player.y, Config.pjSizeInitial * Anim.outerCircleMultiplier)

        end
    end
end

-- LOAD ----------------------------------------------------------------------------------------
function love.load()
    love.window.setFullscreen(Config.fullScreen)
    Config.xDistToAnim = Config.fullScreen and Config.xDistToAnimFS or Config.xDistToAnimWin

    -- Audio Loads
    Audio.music = love.audio.newSource(Audio.paths.music, "static")
    Audio.music:setVolume(Audio.volMusic)

    Audio.sound1 = love.audio.newSource(Audio.paths.sound1, "static")
    Audio.sound1:setVolume(0.0)

    Audio.sound2 = love.audio.newSource(Audio.paths.sound2, "static")
    Audio.sound2:setVolume(0.0)

    Audio.whistle = love.audio.newSource(Audio.paths.whistle, "static")
    Audio.whistle:setVolume(0.0)

    Audio.beat = love.audio.newSource(Audio.paths.beat, "static")
    Audio.beat:setVolume(Audio.volBeat)

    for _, src in pairs({Audio.music, Audio.sound1, Audio.sound2, Audio.whistle}) do
        src:setLooping(true)
    end

    love.audio.setVolume(Audio.audioInitialVolume)
    love.graphics.setColor(Config.backgroundColour[1], Config.backgroundColour[2], Config.backgroundColour[3])
    love.mouse.setVisible(false)

    NPC.x = Config.npcInitialX
    NPC.y = Config.npcInitialY

    Audio.music:play()
    Audio.sound1:play()
    Audio.sound2:play()
    Audio.whistle:play()
end

---- LOOP ----------------------------------------------------------------------------------------
function love.update(dt)
    if Game.state == GameState.GAMEPLAY then
        updateGameplay(dt)
    elseif Game.state == GameState.OUTRO then
        updateOutro(dt)
    end

    gamePauser()

end

function love.draw()
    if Game.state == GameState.GAMEPLAY then
        drawGameplay()
    elseif Game.state == GameState.OUTRO then
        drawOutro()
    end
end