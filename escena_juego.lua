local composer = require("composer")
local scene = composer.newScene()

-- Definir el ancho y alto de la pantalla
CW = display.contentWidth
CH = display.contentHeight

-- Declaración de las variables de los botones
local salirButton 
local helpButton

-- Colores para los cuadros de resultado
local colorVerde = {110/255,194/255,7/255}
local colorAmarillo = {1,235/255,0}
local colorGris = {0.7, 0.7, 0.7}

-- Propiedades de los cuadros
local smallBoxSize = 20
local largeRectWidth = 180
local largeRectHeight = 30
local spacing = 7
local numSmallBoxes = 5

-- Variables del juego
local rects = {}
local currentRectIndex = 1
local letrasPorRect = {}
local textosVisibles = {}
local palabraObjetivo

-- ELEMENTOS GRÁFICOS DE LOS INTENTOS
local function createGraphicElement(yPosition)
    -- Agrupar los elementos
    local group = display.newGroup()

    -- Rectángulo largo
    local rectX = CW / 2
    local largeRect = display.newRoundedRect(rectX, 0, largeRectWidth, largeRectHeight, 10)
    largeRect:setFillColor(1)
    group:insert(largeRect)

    local totalWidthSmallBoxes = numSmallBoxes * smallBoxSize + (numSmallBoxes - 1) * spacing
    local startX = rectX - totalWidthSmallBoxes / 2 + smallBoxSize / 2
    local startY = largeRect.y + largeRectHeight / 2 + spacing + smallBoxSize / 2

    -- Cuadros de texto
    for i = 1, numSmallBoxes do
        local box = display.newRect(startX + (i-1)*(smallBoxSize + spacing), startY, smallBoxSize, smallBoxSize)
        box.strokeWidth = 2
        box:setStrokeColor(0)
        box:setFillColor(unpack(colorGris))
        group:insert(box)
    end

    group.y = yPosition
    return group
end

-- MOSTRAR INSTRUCCIONES 
local function mostrarInstrucciones()
    -- Crear un fondo oscuro para la superposición de las instrucciones
    local overlay = display.newRect(CW / 2, CH / 2, CW, CH)
    overlay:setFillColor(0, 0.5)
    -- Crear las medidas del cuadro de instrucciones
    local popup = display.newRoundedRect(CW / 2, CH / 2, CW * 0.8, CH * 0.7, 20)
    popup:setFillColor(1)

    -- Título de las instrucciones
    local titulo = display.newText({
        text = "¿Cómo jugar?",
        x = CW / 2,
        y = CH / 2 - 148,
        font = native.systemFontBold,
        fontSize = 26
    })
    titulo:setFillColor(0)

    -- Cuerpo de las instrucciones
    local texto = [[
Adivina la palabra secreta de 5 letras. Cada intento te dará pistas por colores:

- Verde: letra correcta y en posición correcta.

- Amarillo: letra correcta en posición incorrecta.

- Gris: letra incorrecta.

Tienes 6 intentos. ¡Suerte!

]]
    local cuerpoTexto = display.newText({
        text = texto,
        x = CW / 2,
        y = CH / 2,
        width = CW * 0.7,
        font = native.systemFont,
        fontSize = 16,
        align = "left"
    })
    cuerpoTexto:setFillColor(0)

    -- Botón para cerrar las instrucciones
    local cerrarBtn = display.newRoundedRect(CW / 2, CH / 2 + 135, 155, 38, 12)
    cerrarBtn:setFillColor(0.2, 0.6, 1)

    local cerrarTexto = display.newText({
        text = "Cerrar",
        x = cerrarBtn.x,
        y = cerrarBtn.y,
        font = native.systemFontBold,
        fontSize = 18
    })
    cerrarTexto:setFillColor(1)

    -- Cerrar ventana de instrucciones
    local function cerrar()
        overlay:removeSelf()
        popup:removeSelf()
        titulo:removeSelf()
        cuerpoTexto:removeSelf()
        cerrarBtn:removeSelf()
        cerrarTexto:removeSelf()
    end

    cerrarBtn:addEventListener("tap", cerrar)
end

-- CARGAR PALABRAS 
local function cargarPalabras()
    local path = system.pathForFile("palabras.txt", system.ResourceDirectory)
    local palabras = {}

    local file, errorMsg = io.open(path, "r")
    if file then
        for line in file:lines() do
            local palabra = line:match("^%s*(.-)%s*$")
            if #palabra == 5 then
                table.insert(palabras, palabra:lower())
            end
        end
        io.close(file)
    else
        print("Error al abrir archivo:", errorMsg)
    end
    return palabras
end

-- OBTENER LA PALABRA SECRETA 
local function obtenerPalabraSecreta()
    local lista = cargarPalabras()
    if #lista == 0 then return nil end
    return lista[math.random(1, #lista)]
end

-- MOSTRAR EL MENSAJE FINAL
-- Mensaje victoria/derrota 
local function mostrarMensajeFinal(titulo, mensaje)
    local overlay = display.newRect(CW / 2, CH / 2, CW, CH)
    overlay:setFillColor(0, 0, 0, 0.5)

    local popup = display.newRoundedRect(CW / 2, CH / 2, CW * 0.8, CH * 0.4, 20)
    popup:setFillColor(1)

    local tituloText = display.newText({ text = titulo, x = CW / 2, y = CH / 2 - 60, font = native.systemFontBold, fontSize = 28 })
    tituloText:setFillColor(0)

    local mensajeText = display.newText({
        text = mensaje, x = CW / 2, y = CH / 2, width = CW * 0.7,
        font = native.systemFont, fontSize = 20, align = "center"
    })
    mensajeText:setFillColor(0)

    -- Boton para cerrar el mensaje
    local boton = display.newRoundedRect(CW / 2, CH / 2 + 60, 160, 40, 12)
    boton:setFillColor(0.2, 0.6, 1)

    local botonTexto = display.newText({
        text = "Aceptar", x = boton.x, y = boton.y, font = native.systemFontBold, fontSize = 18
    })
    botonTexto:setFillColor(1)

    local function cerrarPopup()
        overlay:removeSelf()
        popup:removeSelf()
        tituloText:removeSelf()
        mensajeText:removeSelf()
        boton:removeSelf()
        botonTexto:removeSelf()
    end

    boton:addEventListener("tap", cerrarPopup)
end

-- TEXTO DINÁMICO
-- Actualizacion del texto
local function actualizarTexto()
    if textosVisibles[currentRectIndex] then
        textosVisibles[currentRectIndex]:removeSelf()
        textosVisibles[currentRectIndex] = nil
    end

    local palabra = letrasPorRect[currentRectIndex] or ""
    local rectGroup = rects[currentRectIndex]
    local rect = rectGroup[1]

    local texto = display.newText({
        text = palabra,
        x = rect.x,
        y = rectGroup.y + rect.y,
        font = native.systemFontBold,
        fontSize = 20
    })
    texto:setFillColor(0)
    textosVisibles[currentRectIndex] = texto
end

-- PINTAR LOS CUADROS
-- Pintar los cuadros con los colores adecuados  
local function pintarCuadros(palabraIngresada, palabraSecreta, grupo)
    local letrasSecreta = {}
    local usadasEnSecreta = {}
    local resultado = {}

    -- Inicialización
    for i = 1, 5 do
        letrasSecreta[i] = palabraSecreta:sub(i, i)
        usadasEnSecreta[i] = false
        resultado[i] = "gris"
    end

    -- Revisar verdes
    for i = 1, 5 do
        local letraUsuario = palabraIngresada:sub(i, i)
        if letraUsuario == letrasSecreta[i] then
            resultado[i] = "verde"
            usadasEnSecreta[i] = true
        end
    end

    -- Revisar amarillos
    for i = 1, 5 do
        local letraUsuario = palabraIngresada:sub(i, i)
        if resultado[i] == "gris" then
            for j = 1, 5 do
                if not usadasEnSecreta[j] and letraUsuario == letrasSecreta[j] then
                    resultado[i] = "amarillo"
                    usadasEnSecreta[j] = true
                    break
                end
            end
        end
    end

    -- Pintar los cuadros según resultado
    for i = 1, 5 do
        if resultado[i] == "verde" then
            grupo[i+1]:setFillColor(unpack(colorVerde))
        elseif resultado[i] == "amarillo" then
            grupo[i+1]:setFillColor(unpack(colorAmarillo))
        else
            grupo[i+1]:setFillColor(unpack(colorGris))
        end
    end
end

-- SALIR DEL JUEGO Y VOLVER AL INICIO 
local function salirJuego(event)
    composer.gotoScene("escena_inicio", { effect = "fade", time = 300 })
    composer.removeScene("escena_juego") 
end

-- DETECCIÓN DE TECLADO 
local function onKeyEvent(event)
    if event.phase == "down" then
        local key = event.keyName
        local palabraActual = letrasPorRect[currentRectIndex] or ""

        -- Agregar las letras
        if key:match("^[a-zA-Z]$") and #palabraActual < 5 then
            letrasPorRect[currentRectIndex] = palabraActual .. string.upper(key)
            actualizarTexto()

        -- Borrar
        elseif key == "deleteBack" or key == "backspace" then
            letrasPorRect[currentRectIndex] = palabraActual:sub(1, -2)
            actualizarTexto()

        -- Verificacion de la palabra
        elseif (key == "enter" or key == "return") and #palabraActual == 5 then
            local palabraUsuario = palabraActual:lower()
            pintarCuadros(palabraUsuario, palabraObjetivo, rects[currentRectIndex]) -- Pintar cuadros según aciertos
            if palabraUsuario == palabraObjetivo then
                mostrarMensajeFinal("¡Ganaste!", "¡Adivinaste la palabra!")
                Runtime:removeEventListener("key", onKeyEvent)
            elseif currentRectIndex == #rects then
                mostrarMensajeFinal("Fin del juego", "La palabra era: " .. palabraObjetivo)
                Runtime:removeEventListener("key", onKeyEvent)
            else
                currentRectIndex = currentRectIndex + 1
                actualizarTexto()
            end
        end
    end
    return false
end

-- create()
function scene:create(event)
    local sceneGroup = self.view

    -- Cargar y posicionar el fondo de la pantalla
    local fondo = display.newImageRect("fondo1.jpeg", CW, CH)
    fondo.x = CW / 2
    fondo.y = CH / 2
    sceneGroup:insert(fondo)

    -- Inicializar la palabra objetivo
    palabraObjetivo = obtenerPalabraSecreta()
    print("Palabra secreta:", palabraObjetivo)

    -- **Reiniciar la tabla de letras por intento al inicio de cada partida**
    letrasPorRect = {}

    -- Crear los elementos gráficos de los intentos
    for i = 1, 6 do
        local graphicElement = createGraphicElement(65 + (i - 1) * 70)
        rects[i] = graphicElement
        sceneGroup:insert(graphicElement)
    end

    -- Botón de ayuda '?'
    helpButton = display.newText({
        text = "?",
        x = 30,
        y = 30,
        font = native.systemFontBold,
        fontSize = 35
    })
    helpButton:setFillColor(1, 1, 1)
    helpButton:addEventListener("tap", mostrarInstrucciones)
    sceneGroup:insert(helpButton)

    -- Botón de Salir
    salirButton = display.newRoundedRect(CW - 35, 30, 30, 30, 5)
    salirButton:setFillColor(0.5, 0.5, 0.5)
    local salirTexto = display.newText({
        text = "x",
        x = salirButton.x,
        y = salirButton.y,
        font = native.systemFontBold,
        fontSize = 24
    })
    salirTexto:setFillColor(1) 
    salirButton:addEventListener("tap", salirJuego)

    -- Insertar en el grupo de la escena
    sceneGroup:insert(salirButton)
    sceneGroup:insert(salirTexto)

    -- Iniciar la detección del teclado
    Runtime:addEventListener("key", onKeyEvent)

    -- Reiniciar el índice del intento actual
    currentRectIndex = 1

    -- Reiniciar la tabla de textos visibles
    textosVisibles = {}

    print("Función create() llamada en escena_juego")
end

-- show()
--function scene:show(event)
--    local sceneGroup = self.view
--    local phase = event.phase
--end

-- hide()
--function scene:hide(event)
--    local sceneGroup = self.view
--    local phase = event.phase
--end

-- destroy()
function scene:destroy(event)
    local sceneGroup = self.view
    print("La escena de juego va a ser destruida")

    -- Remover el listener del teclado
    Runtime:removeEventListener("key", onKeyEvent)

    -- Eliminar todos los objetos de texto visibles del sceneGroup
    for i, textoObj in pairs(textosVisibles) do
        if textoObj and textoObj.removeSelf then
            textoObj:removeSelf()
            textoObj = nil
        end
    end
    textosVisibles = {} 

    print("Función destroy() llamada en escena_juego")
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