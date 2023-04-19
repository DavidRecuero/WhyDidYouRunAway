---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
--VARIABLES--
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------

--FULLSCREEN
local fsAsk = true

--ENEMY
local xNPC
local yNPC
local alfa = 0.0020 --npc "velocity"

local npcLineWidth = 5
local npcSize = 20.0
local npcSizeInitial = 20.0

--PLAYER
local xPJ
local yPJ

local pjLineWidth = 5
local pjSize = 10.0
local pjSizeInitial = 10.0

local lineWidthDefault = 5

--DISTANCE BETWEEN CHARACTERS

local distance

--ACTIVATE EVENTS
local startS1 = 300.0
local beginShake = 300.0
local beginToDecrease = 250.0
local startS2 = 100.0
local startPitido = 60.0
local distEnd = 2.0

--DEFINE ESCENE
local escena = 0   -- 0 game, 1 final
local whatToDo = 3 -- 0 crece, 1 decrece, 2 espera, 3 intro (empieza sonido latido y pasa a 0 al momento)

--SOUNDS
local volMusic = 0.15
local s1Max = 1.0
local volLatido = 0.1
local incVolLatido = 0.2

--SHAKE
local shakeRangeMax = 2.0

--ANIMATION
local animSize = 10.0
local repetirAnim = 0         --veces que se ha ejecutado la animcación
local nRepeticionesAnim = 8   --veces que se hará la animación
local incrementoEnLatido = 0.05
local diamMaximo = 11.0
local timeToBeginBeats
local timeBetweenBeats
local distYToAnim = 100 		  --Distancia del texto respecto a la animación
local distXToAnim 


---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
--LOAD-- ONCE AT THE BEGINNING
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------

function love.load()

	--love.window.setMode( 1024, 768)
	love.window.setFullscreen(fsAsk)

	if fsAsk == true then distXToAnim = 300				--posición del texto final depende de si fullscreen
	else distXToAnim = 50 
	end

	music = love.audio.newSource("WhyDidYouRunAwayMusicDeep.mp3", "static")
		music:setVolume(volMusic)
		music:setLooping(true)
	sound1 = love.audio.newSource("high-theta.mp3", "static")
		sound1:setVolume(0.0)
		sound1:setLooping(true)
	sound2 = love.audio.newSource("noise.mp3", "static")
		sound2:setVolume(0.0)
		sound2:setLooping(true)
	pitido = love.audio.newSource("pitido.wav", "static")
		pitido:setVolume(0.0)
        pitido:setLooping(true)
    latido = love.audio.newSource("Latido.mp3", "static")
        latido:setVolume(volLatido)

    love.audio.setVolume(1)

    love.graphics.setColor(255, 255, 255)
    love.mouse.setVisible( false )

	xNPC = love.graphics.getWidth()/2
	yNPC = love.graphics.getHeight() + 500

end

---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
--DRAW--ONCE PER FRAME--CLEAN/DRAW
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------

function love.draw()

	music:play()
	sound1:play()
	sound2:play()

    ---------------------------------------------------------------------------------------------------------------
    ---------------------------------------------------------------------------------------------------------------
    --GAMEPLAY
    ---------------------------------------------------------------------------------------------------------------
    ---------------------------------------------------------------------------------------------------------------

    if escena == 0 then
        --ENEMY
        xNPC = alfa * love.mouse.getX() + (1.0 - alfa) * xNPC
        yNPC = alfa * love.mouse.getY() + (1.0 - alfa) * yNPC

        --PLAYER
        xPJ = love.mouse.getX()
        yPJ = love.mouse.getY()

        --DIST PJ<->ENEMY
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

        --DRAW ENEMY
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

    	if distance < startPitido then
    		pitido:setVolume(math.pow(1 - (distance/startPitido)/2, 2))
    		pitido:play()
        else 
        	pitido:stop()
    	end	

        if distance < distEnd then 
            timeToBeginBeats = love.timer.getTime()
            timeBetweenBeats = love.timer.getTime() + 2
            escena = 1
        end
    end

    ---------------------------------------------------------------------------------------------------------------
    ---------------------------------------------------------------------------------------------------------------
    --FINAL
    ---------------------------------------------------------------------------------------------------------------
    ---------------------------------------------------------------------------------------------------------------

    if escena == 1 then

        --SE ESCRIBE MENSAJE--

        love.audio.stop(music)
        love.audio.stop(sound1)
        love.audio.stop(sound2)
        love.audio.stop(pitido)

        --WHERE TO PRINT THE TEXT--
        --------------
        --| 1 | 2 | --
        --| 3 | 4 | --
        --------------
        if yPJ <= love.graphics.getHeight()/2 and xPJ <= love.graphics.getWidth()/2 then         --1

            love.graphics.print("Why did you run away?", distXToAnim, yPJ + distYToAnim) --love.graphics.getHeight()/2.2)

        elseif yPJ <= love.graphics.getHeight()/2 and xPJ >= love.graphics.getWidth()/2 then     --2

            love.graphics.print("Why did you run away?", love.graphics.getWidth()/2 + distXToAnim, yPJ + distYToAnim)  

        elseif yPJ >= love.graphics.getHeight()/2 and xPJ <= love.graphics.getWidth()/2 then     --3

            love.graphics.print("Why did you run away?", distXToAnim, yPJ - distYToAnim)

        else                                                                                     --4   

            love.graphics.print("Why did you run away?", love.graphics.getWidth()/2 + distXToAnim, yPJ - distYToAnim)

        end

        --COMIENZA ANIMACIÓN--

        if love.timer.getTime() > timeToBeginBeats + 2 then

        	if whatToDo == 3 then

            latido:play()
			whatToDo = 0
			
        	end

            --TAMAÑO CRECE--

            if whatToDo == 0 then
                if animSize < diamMaximo then
                                    
                    love.graphics.setLineWidth( animSize / 2 )
                    love.graphics.circle("line", xPJ, yPJ, animSize, 360)
                    love.graphics.circle("line", xPJ, yPJ, animSize * 2, 360)

                    animSize = animSize + incrementoEnLatido

                else

                    whatToDo = 1

                end
            end

            --TAMAÑO DECRECE--

            if whatToDo == 1 then
                if animSize > pjSizeInitial then
                                    
                    love.graphics.setLineWidth( animSize / 2 )
                    love.graphics.circle("line", xPJ, yPJ, animSize, 360)
                    love.graphics.circle("line", xPJ, yPJ, animSize * 2, 360)

                    animSize = animSize - incrementoEnLatido

                else
                    whatToDo = 2
                    timeBetweenBeats = love.timer.getTime()
                end

            end

            --DESCANSA--

            if whatToDo == 2 then
                if love.timer.getTime() < timeBetweenBeats + 2 then
                                    
                    love.graphics.setLineWidth( 5 )
                    love.graphics.circle("line", xPJ, yPJ, pjSizeInitial, 360)
                    love.graphics.circle("line", xPJ, yPJ, pjSizeInitial * 2, 360)

                else

                    love.graphics.circle("line", xPJ, yPJ, pjSizeInitial, 360)
                    love.graphics.circle("line", xPJ, yPJ, pjSizeInitial * 2, 360)                    

                    repetirAnim = repetirAnim + 1

                    if repetirAnim == nRepeticionesAnim then
                       love.event.quit()
                    end
                    
                    latido:play()

                    volLatido = volLatido + incVolLatido
                    latido:setVolume(volLatido)
                    whatToDo = 0

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

    --solo sentido en versión de navegador (quizá ni aqui) (bloque mov NPC y PJ cuando raton se va de pantalla)
    if (love.mouse.getX() == 0 or love.mouse.getX() == love.graphics.getWidth() - 1 or			--Mouse in the border
       love.mouse.getY() == 0 or love.mouse.getY() == love.graphics.getHeight() - 1) and
       fsAsk == false then

    	alfa = 0;
    else
    	alfa = 0.0015;
    end

end