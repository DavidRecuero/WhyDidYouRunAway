--TO FIX--
--1. WHITE NOISE/NOISE starts so abruptly
--2. A last beat sound sounds just before ending the game?
--3. Use delta time to keep the same speed in different computers 
----------


---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
--VARIABLES--
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------

local Config = {
    fullScreen = true,
    backgroundColour = {255, 255, 255},
    -- NPC
    npcSpeed = 0.0015,
    npcSizeInitial = 20.0,
    npcInitialX = love.graphics.getWidth() / 2,
    npcInitialY = love.graphics.getHeight() + 500,
    -- Player
    lineWidth = 5,                                   -- NPC and player share the same line width
    pjSizeInitial = 10.0,
    -- Shake
    shakeRangeMax = 2.0,
    -- Final Text draw position according to Fullscreen or Windowed mode
    xDistToAnimFS = 300,    
    xDistToAnimWin = 50,
    yDistToAnim = 100,
    finalText = "Why did you run away?" --Final message to display when the player reaches the NPC
}

local Trigger = {
    -- Distance to trigger events
    startStage1 = 300.0,
    beginShake = 300.0,
    beginToDecrease = 250.0,
    startStage2 = 100.0,
    startWhistle = 60.0,
    distEnd = 2.0               -- Distance between NPC and player to trigger the outro
}

local Game = {
    state = "gameplay", -- "gameplay" | "outro"
    beatAnimationState = "intro", -- "growth" | "decrease" | "waiting" | "intro"
    distancePJ_NPC = 0,
    timeToBeginBeats = 0,
    timeBetweenBeats = 0
}

local Player = { x = 0, y = 0, size = Config.pjSizeInitial, lineWidth = Config.lineWidth }
local NPC = { x = 0, y = 0, size = Config.npcSizeInitial, speed = Config.npcSpeed, lineWidth = Config.lineWidth }
local Anim = { size = Config.pjSizeInitial, repeated = 0, maxRepeats = 8, increment = 0.05, maxDiameter = 11.0, delaySecondsToStartBeats = 2.0, outerCircleMultiplier = 2}
local Audio = { audioInitialVolume = 1,volMusic = 0.15, s1Max = 1.0, volBeat = 0.1, incVolBeat = 0.2 }


---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
--LOAD-- ONCE AT THE BEGINNING
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------

function love.load()
    love.window.setFullscreen(Config.fullScreen)
    Config.xDistToAnim = Config.fullScreen and Config.xDistToAnimFS or Config.xDistToAnimWin

    -- Audio Loads
    Audio.music = love.audio.newSource("Audio/Music/WhyDidYouRunAwayMusicDeep.mp3", "static")
    Audio.music:setVolume(Audio.volMusic)

    Audio.sound1 = love.audio.newSource("Audio/Sounds/high-theta.mp3", "static")
    Audio.sound1:setVolume(0.0)

    Audio.sound2 = love.audio.newSource("Audio/Sounds/noise.mp3", "static")
    Audio.sound2:setVolume(0.0)

    Audio.whistle = love.audio.newSource("Audio/Sounds/whistle.wav", "static")
    Audio.whistle:setVolume(0.0)

    Audio.beat = love.audio.newSource("Audio/Sounds/beat.mp3", "static")
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
end

---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
--DRAW--ONCE PER FRAME--CLEAN/DRAW
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------

function love.update(dt)
    if Game.state == "gameplay" then
        updateGameplay()
    elseif Game.state == "outro" then
        updateOutro()
    end
    handleInput()
end

function love.draw()
    if Game.state == "gameplay" then
        drawGameplay()
    elseif Game.state == "outro" then
        drawOutro()
    end
end

function updateGameplay()
    
    --NPC Movement (Moving the npc before forces the player to go inside it to complete the game. If not, the npc can just complete the game by itself)
    NPC.x = NPC.speed * love.mouse.getX() + (1.0 - NPC.speed) * NPC.x
    NPC.y = NPC.speed * love.mouse.getY() + (1.0 - NPC.speed) * NPC.y

    --Player Movement
    Player.x = love.mouse.getX()
    Player.y = love.mouse.getY()

    -- Calculate distance between player and NPC
    Game.distancePJ_NPC = math.sqrt(math.pow(Player.x - NPC.x, 2) + math.pow(Player.y - NPC.y, 2))

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
        Game.state = "outro"
        love.audio.stop(Audio.music)
        love.audio.stop(Audio.sound1)
        love.audio.stop(Audio.sound2)
        love.audio.stop(Audio.whistle)
    end
end

function updateAudioDistances()

    --Soft Distortion Sound
    if Game.distancePJ_NPC < Trigger.startStage1 then
        Audio.sound1:setVolume(math.pow(1 - (Game.distancePJ_NPC / Trigger.startStage1) / 2, 2) * Audio.s1Max)
        Audio.music:setVolume((1 - ((Trigger.startStage1 - Game.distancePJ_NPC) / Trigger.startStage1)) * Audio.volMusic)
    else
        Audio.sound1:setVolume(0)
    end

    --Hard Distortion Sound
    if Game.distancePJ_NPC < Trigger.startStage2 then
        Audio.sound2:setVolume(math.pow(1 - (Game.distancePJ_NPC / Trigger.startStage2) / 2, 2))
    else
        Audio.sound2:setVolume(0)
    end

    --Whistle Sound
    if Game.distancePJ_NPC < Trigger.startWhistle then
        Audio.whistle:setVolume(math.pow(1 - (Game.distancePJ_NPC / Trigger.startWhistle) / 2, 2))
        Audio.whistle:play()
    else
        Audio.whistle:stop()
    end
end

function updateOutro()
    if love.timer.getTime() > Game.timeToBeginBeats + Anim.delaySecondsToStartBeats then
        
        -- Beats Animation begins after the delay
        if Game.beatAnimationState == "intro" then

            Audio.beat:play()
            Game.beatAnimationState = "growth"

        --NPC/Player are growing
        elseif Game.beatAnimationState == "growth" then

            if Anim.size < Anim.maxDiameter then
                Anim.size = Anim.size + Anim.increment
            else
                Game.beatAnimationState = "decrease"
            end

        --NPC/Player are decreasing
        elseif Game.beatAnimationState == "decrease" then

            if Anim.size > Config.pjSizeInitial then
                Anim.size = Anim.size - Anim.increment
            else
                Game.beatAnimationState = "waiting"
                Game.timeBetweenBeats = love.timer.getTime()
            end

        --NPC/Player are waiting for the next beat
        elseif Game.beatAnimationState == "waiting" then

            if love.timer.getTime() >= Game.timeBetweenBeats + Anim.delaySecondsToStartBeats then
                Anim.repeated = Anim.repeated + 1
                if Anim.repeated == Anim.maxRepeats then
                    love.event.quit()
                end
                Audio.beat:play()
                Audio.volBeat = Audio.volBeat + Audio.incVolBeat
                Audio.beat:setVolume(Audio.volBeat)
                Game.beatAnimationState = "growth"
            end

        end
    end
end

function drawGameplay()
    love.graphics.setLineWidth(NPC.lineWidth)
    love.graphics.circle("line", NPC.x, NPC.y, NPC.size)

    love.graphics.setLineWidth(Player.lineWidth)
    love.graphics.circle("line", Player.x, Player.y, Player.size)
end

function drawOutro()

    -- Draw the final text message
    local textX = (Player.x <= love.graphics.getWidth() / 2) and Config.xDistToAnim or (love.graphics.getWidth() / 2 + Config.xDistToAnim)      -- If the player is on the left side of the screen, print the text on the right side, and vice versa
    local textY = (Player.y <= love.graphics.getHeight() / 2) and (Player.y + Config.yDistToAnim) or (Player.y - Config.yDistToAnim)            -- If the player is on the top side of the screen, print the text below, and vice versa
    love.graphics.print(Config.finalText, textX, textY)

    if love.timer.getTime() > Game.timeToBeginBeats + Anim.delaySecondsToStartBeats then

        -- Draw the NPC and Player circles with the current size based on the beat animation state
        if Game.beatAnimationState == "growth" or Game.beatAnimationState == "decrease" then

            -- Draw the circles with a line width proportional to their size
            local proportionalLineWidth = Config.lineWidth * (Anim.size / Config.pjSizeInitial)
            love.graphics.setLineWidth(proportionalLineWidth)

            love.graphics.circle("line", Player.x, Player.y, Anim.size)
            love.graphics.circle("line", Player.x, Player.y, Anim.size * 2)

        -- Draw the circles in the "waiting" state, waiting between beats
        elseif Game.beatAnimationState == "waiting" then

            -- Draw the circles with the initial size values
            love.graphics.setLineWidth( Config.lineWidth)
            love.graphics.circle("line", Player.x, Player.y, Config.pjSizeInitial)
            love.graphics.circle("line", Player.x, Player.y, Config.pjSizeInitial * Anim.outerCircleMultiplier)

        end
    end
end

function handleInput()
    --esc = quit game
    if love.keyboard.isDown("escape") then love.event.quit() end

    --"PAUSES THE GAME" WHEN MOUSE IS OUT OF GAME SCREEN BLOCKS THE MOVEMENT OF NPC AND PLAYER
    local mx, my = love.mouse.getX(), love.mouse.getY()
    local gw, gh = love.graphics.getWidth(), love.graphics.getHeight()
    
    if (mx == 0 or mx == gw - 1 or my == 0 or my == gh - 1) and not Config.fullScreen then
        NPC.speed = 0
    else
        NPC.speed = Config.npcSpeed
    end
end