--TO FIX--
--1. WHITE NOISE/NOISE starts so abruptly
--2. A last beat sound sounds just before ending the game?
----------


---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
--VARIABLES--
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------

--FULLSCREEN
local fullScreen = true

--NPC
local xNPC
local yNPC
local npcSpeed = 0.002

local npcLineWidth = 5
local npcSize = 20.0
local npcSizeInitial = 20.0

--PLAYER
local xPJ
local yPJ

local pjLineWidth = 5
local pjSize = 10.0
local pjSizeInitial = 10.0

local lineWidthDefault = pjLineWidth

--DISTANCE BETWEEN CHARACTERS

local distance

--EVENTS TRIGGERS (DISTANCES)
local startS1 = 300.0
local beginShake = 300.0
local beginToDecrease = 250.0
local startS2 = 100.0
local startWhistle = 60.0
local distEnd = 2.0

--SCENE & STATUS
local scene = 0   
-- Game (0), Outro (1)

local charsBeatStatus = 3       
-- Growth (0), Decrease (1), Waiting (2), Intro -Only to start the Beat sound and go to the 0 value at the moment- (3)

--SOUNDS
local volMusic = 0.15
local s1Max = 1.0
local volBeat = 0.1
local incVolBeat = 0.2

--SHAKE
local shakeRangeMax = 2.0

--ANIMATION
local animSize = 10.0
local animRepeated = 0              --Times the animation has been executed
local nAnimRepeats = 8              --Times the animation will be executed
local incrementInBeat = 0.05
local maxDiameter = 11.0
local timeToBeginBeats
local timeBetweenBeats
local yDistToAnim = 100 		    --Distance of the text from animation
local xDistToAnim 


---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
--LOAD-- ONCE AT THE BEGINNING
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------

function love.load()
    
	--love.window.setMode( 1024, 768)
	love.window.setFullscreen(fullScreen)

	if fullScreen == true then xDistToAnim = 300				--Text last position according to screen 
	else xDistToAnim = 50 
	end

	music = love.audio.newSource("Audio/Music/WhyDidYouRunAwayMusicDeep.mp3", "static")
		music:setVolume(volMusic)
		music:setLooping(true)
	sound1 = love.audio.newSource("Audio/Sounds/high-theta.mp3", "static")
		sound1:setVolume(0.0)
		sound1:setLooping(true)
	sound2 = love.audio.newSource("Audio/Sounds/noise.mp3", "static")
		sound2:setVolume(0.0)
		sound2:setLooping(true)
	whistle = love.audio.newSource("Audio/Sounds/whistle.wav", "static")
		whistle:setVolume(0.0)
        whistle:setLooping(true)
    beat = love.audio.newSource("Audio/Sounds/beat.mp3", "static")
        beat:setVolume(volBeat)

    love.audio.setVolume(1)

    love.graphics.setColor(255, 255, 255)
    love.mouse.setVisible( false )

	xNPC = love.graphics.getWidth()/2
	yNPC = love.graphics.getHeight() + 500


    music:play()
	sound1:play()
	sound2:play()


end

---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
--DRAW--ONCE PER FRAME--CLEAN/DRAW
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------

function love.draw()

	
    -------------------------------------------------------------------------------------------------------------
    -------------------------------------------------------------------------------------------------------------
    --GAMEPLAY (scene 0)
    -------------------------------------------------------------------------------------------------------------
    -------------------------------------------------------------------------------------------------------------

    if scene == 0 then
               
        --NPC MOVEMENT (Moving the npc before forces the player to go inside it to complete the game. If not, the npc can just complete the game by itself)
        xNPC = npcSpeed * love.mouse.getX() + (1.0 - npcSpeed) * xNPC
        yNPC = npcSpeed * love.mouse.getY() + (1.0 - npcSpeed) * yNPC

        --PLAYER MOVEMENT
        xPJ = love.mouse.getX()
        yPJ = love.mouse.getY() 
        
        --CALCULATE DIST PJ<->NPC
        distance = math.sqrt(math.pow(xPJ - xNPC, 2) + math.pow(yPJ - yNPC, 2))

    	if distance < beginShake then

    		shakeRange = math.pow(1 - (distance/beginShake), 2) * (shakeRangeMax)

    		xNPC = love.math.random( xNPC - shakeRange, xNPC + shakeRange)
    		yNPC = love.math.random( yNPC - shakeRange, yNPC + shakeRange)

    		xPJ = love.math.random( xPJ - shakeRange, xPJ + shakeRange)
    		yPJ = love.math.random( yPJ - shakeRange, yPJ + shakeRange)
        end


        if distance < beginToDecrease then
        	pjSize = pjSizeInitial / (beginToDecrease/distance)
        	pjLineWidth = 5 / (beginToDecrease/distance)
        else
        	pjSize = pjSizeInitial
        	pjLineWidth = lineWidthDefault
        end

        --DRAW NPC
        love.graphics.setLineWidth( npcLineWidth )
        love.graphics.circle("line", xNPC, yNPC, npcSize, 360)

        --DRAW PLAYER
        love.graphics.setLineWidth( pjLineWidth )
        love.graphics.circle("line", xPJ, yPJ, pjSize, 360)


    	--MUSIC & SOUND
        if distance < startS1 then
    		sound1:setVolume(math.pow(1 - (distance/startS1)/2, 2) * s1Max)
        	music:setVolume((1 - ((startS1 - distance)/startS1)) * volMusic) 
        else 
        	sound1:setVolume(0)
    	end

        if distance < startS2 then
        	sound2:setVolume(math.pow(1 - (distance/startS2)/2, 2))
        else 
        	sound2:setVolume(0)
    	end	

    	if distance < startWhistle then
    		whistle:setVolume(math.pow(1 - (distance/startWhistle)/2, 2))
    		whistle:play()
        else 
        	whistle:stop()
    	end	

        if distance < distEnd then 
            timeToBeginBeats = love.timer.getTime()
            timeBetweenBeats = love.timer.getTime() + 2
            scene = 1
        end
    end

    ---------------------------------------------------------------------------------------------------------------
    ---------------------------------------------------------------------------------------------------------------
    --OUTRO (scene 1)
    ---------------------------------------------------------------------------------------------------------------
    ---------------------------------------------------------------------------------------------------------------

    if scene == 1 then

        --SILENCE - ALL AUDIO STOPPED--

        love.audio.stop(music)
        love.audio.stop(sound1)
        love.audio.stop(sound2)
        love.audio.stop(whistle)

        --FINAL MESSAGE IS PRINTED--
        
        --Where the text is going to be printed
        --------------
        --| 1 | 2 | --
        --| 3 | 4 | --
        --------------
        
        if yPJ <= love.graphics.getHeight()/2 and xPJ <= love.graphics.getWidth()/2 then         --1

            love.graphics.print("Why did you run away?", xDistToAnim, yPJ + yDistToAnim) --love.graphics.getHeight()/2.2)

        elseif yPJ <= love.graphics.getHeight()/2 and xPJ >= love.graphics.getWidth()/2 then     --2

            love.graphics.print("Why did you run away?", love.graphics.getWidth()/2 + xDistToAnim, yPJ + yDistToAnim)  

        elseif yPJ >= love.graphics.getHeight()/2 and xPJ <= love.graphics.getWidth()/2 then     --3

            love.graphics.print("Why did you run away?", xDistToAnim, yPJ - yDistToAnim)

        else                                                                                     --4   

            love.graphics.print("Why did you run away?", love.graphics.getWidth()/2 + xDistToAnim, yPJ - yDistToAnim)

        end

        --BEAT ANIMATION--

        if love.timer.getTime() > timeToBeginBeats + 2 then

        	if charsBeatStatus == 3 then

            beat:play()
			charsBeatStatus = 0
			
        	end

            --GROWTHS--
            
            if charsBeatStatus == 0 then
                if animSize < maxDiameter then
                                    
                    love.graphics.setLineWidth( animSize / 2 )
                    love.graphics.circle("line", xPJ, yPJ, animSize, 360)
                    love.graphics.circle("line", xPJ, yPJ, animSize * 2, 360)

                    animSize = animSize + incrementInBeat

                else

                    charsBeatStatus = 1

                end
            end
            
            --DECREASES--

            if charsBeatStatus == 1 then
                if animSize > pjSizeInitial then
                                    
                    love.graphics.setLineWidth( animSize / 2 )
                    love.graphics.circle("line", xPJ, yPJ, animSize, 360)
                    love.graphics.circle("line", xPJ, yPJ, animSize * 2, 360)

                    animSize = animSize - incrementInBeat

                else
                    charsBeatStatus = 2
                    timeBetweenBeats = love.timer.getTime()
                end

            end

            --WAITS--

            if charsBeatStatus == 2 then
                if love.timer.getTime() < timeBetweenBeats + 2 then
                                    
                    love.graphics.setLineWidth( 5 )
                    love.graphics.circle("line", xPJ, yPJ, pjSizeInitial, 360)
                    love.graphics.circle("line", xPJ, yPJ, pjSizeInitial * 2, 360)

                else

                    love.graphics.circle("line", xPJ, yPJ, pjSizeInitial, 360)
                    love.graphics.circle("line", xPJ, yPJ, pjSizeInitial * 2, 360)                    

                    animRepeated = animRepeated + 1

                    if animRepeated == nAnimRepeats then
                       love.event.quit()
                    end
                    
                    beat:play()

                    volBeat = volBeat + incVolBeat
                    beat:setVolume(volBeat)
                    charsBeatStatus = 0

                end
            end
        end
    end

    ---------------------------------------------------------------------------------------------------------------
    ---------------------------------------------------------------------------------------------------------------
    --HANDLE INPUT
    ---------------------------------------------------------------------------------------------------------------
    ---------------------------------------------------------------------------------------------------------------

    --esc = quit game
    if love.keyboard.isDown("escape") then
    	love.event.quit()
    end

    --"PAUSES THE GAME" WHEN MOUSE IS OUT OF GAME SCREEN BLOCKS THE MOVEMENT OF NPC AND PLAYER 
    --Does it makes sense in browsers?
    if (love.mouse.getX() == 0 or love.mouse.getX() == love.graphics.getWidth() - 1 or			--Mouse in the border
       love.mouse.getY() == 0 or love.mouse.getY() == love.graphics.getHeight() - 1) and
       fullScreen == false then

    	npcSpeed = 0;
    else
    	npcSpeed = 0.0015;
    end

end