local composer = require("composer")
local scene = composer.newScene()

-- Definir el ancho y alto de la pantalla
CW = display.contentWidth
CH = display.contentHeight

--create()
function scene:create(event)

    local sceneGroup = self.view

    -- Crear un fondo
    local fondo = display.newImageRect("fondo4.jpeg", CW, CH)
    fondo.x = CW / 2
    fondo.y = CH / 2

    sceneGroup:insert(fondo)

    local logo = display.newImageRect("w gato.png", 50, 50)
    logo.x = 50
    logo.y = 45

    sceneGroup:insert(logo)

    local titulo = display.newText({
        text = "   ordle",
        x = 98,
        y = 50,
        font = native.systemFontBold, -- Usamos la fuente en negrita del sistema
        fontSize = 30,
        align = "center"
    })
    titulo:setFillColor(0, 0, 0)
    sceneGroup:insert(titulo)

    -- Botón para iniciar el juego
    local boton_iniciar = display.newRoundedRect(CW / 2, CH / 2 + 150, 140, 40, 12)
    boton_iniciar:setFillColor(0.2, 0.6, 1)

    local texto_boton = display.newText({
        text = "Iniciar", -- Cambiamos el texto a "Iniciar"
        x = boton_iniciar.x,
        y = boton_iniciar.y,
        font = native.systemFontBold,
        fontSize = 18
    })
    texto_boton:setFillColor(1)

    sceneGroup:insert(boton_iniciar)
    sceneGroup:insert(texto_boton)

    -- Cambio de escena
    local function iniciarJuego(event)
        composer.gotoScene("escena_juego")
    end

    boton_iniciar:addEventListener("tap", iniciarJuego)

end

-- show()
--function scene:show(event)
--end

-- hide()
--function scene:hide(event)
--end

-- destroy()
function scene:destroy(event)
    local sceneGroup = self.view
    print("La escena de inicio va a ser destruida")
end

-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------
 
return scene