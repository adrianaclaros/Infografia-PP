-----------------------------------------------------------------------------------------
-- main.lua
-----------------------------------------------------------------------------------------

--== CONFIGURACIÓN DE PANTALLA Y FONDO ==
local CW = display.contentWidth
local CH = display.contentHeight

local fondo = display.newImageRect("fondo1.jpeg", CW, CH)
fondo.x = CW / 2
fondo.y = CH / 2

--== MOSTRAR INSTRUCCIONES ==
local function mostrarInstrucciones()
    local overlay = display.newRect(CW / 2, CH / 2, CW, CH)
    overlay:setFillColor(0, 0.5)

    local popup = display.newRoundedRect(CW / 2, CH / 2, CW * 0.8, CH * 0.67, 20)
    popup:setFillColor(1)

    local titulo = display.newText({
        text = "¿Cómo jugar?",
        x = CW / 2,
        y = CH / 2 - 140,
        font = native.systemFontBold,
        fontSize = 26
    })
    titulo:setFillColor(0)

    local texto = [[
Adivina la palabra secreta de 5 letras.

Cada intento te dará pistas por colores:
    - Verde: letra correcta y en posición correcta.
    - Amarillo: letra correcta en posición incorrecta.
    - Gris: letra incorrecta.

Tienes 6 intentos. ¡Suerte!
]]

    local cuerpoTexto = display.newText({
        text = texto,
        x = CW / 2,
        y = CH / 2 - 15,
        width = CW * 0.7,
        font = native.systemFont,
        fontSize = 16,
        align = "left"
    })
    cuerpoTexto:setFillColor(0)

    local cerrarBtn = display.newRoundedRect(CW / 2, CH / 2 + 120, 160, 40, 12)
    cerrarBtn:setFillColor(0.2, 0.6, 1)

    local cerrarTexto = display.newText({
        text = "Cerrar",
        x = cerrarBtn.x,
        y = cerrarBtn.y,
        font = native.systemFontBold,
        fontSize = 18
    })
    cerrarTexto:setFillColor(1)

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

-- Botón de ayuda '?'
local helpButton = display.newText({
    text = "?",
    x = 30,
    y = 30,
    font = native.systemFontBold,
    fontSize = 35
})
helpButton:setFillColor(1, 1, 1)

helpButton:addEventListener("tap", mostrarInstrucciones)

local colorVerde = {110/255,194/255,7/255}
local colorAmarillo = {1,235/255,0}
local colorGris = {0.7, 0.7, 0.7}

--== VARIABLES DEL JUEGO ==
local smallBoxSize = 20
local largeRectWidth = 200
local largeRectHeight = 30
local spacing = 7
local numSmallBoxes = 5

-- Crear los elementos gráficos
local function createGraphicElement(yPosition)
    local group = display.newGroup()
    local rectX = CW / 2
    local largeRect = display.newRoundedRect(rectX, 0, largeRectWidth, largeRectHeight, 10)
    largeRect:setFillColor(1)
    group:insert(largeRect)

    local totalWidthSmallBoxes = numSmallBoxes * smallBoxSize + (numSmallBoxes - 1) * spacing
    local startX = rectX - totalWidthSmallBoxes / 2 + smallBoxSize / 2
    local startY = largeRect.y + largeRectHeight / 2 + spacing + smallBoxSize / 2

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

local rects = {
    createGraphicElement(50),
    createGraphicElement(120),
    createGraphicElement(190),
    createGraphicElement(260),
    createGraphicElement(330),
    createGraphicElement(400)
}

local currentRectIndex = 1
local letrasPorRect = {}
local textosVisibles = {}

--== CARGAR PALABRAS ==
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

local function obtenerPalabraSecreta()
    local lista = cargarPalabras()
    if #lista == 0 then return nil end
    return lista[math.random(1, #lista)]
end

local palabraObjetivo = obtenerPalabraSecreta()
print("Palabra secreta:", palabraObjetivo)

--== MENSAJE FINAL ==
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

    local boton = display.newRoundedRect(CW / 2, CH / 2 + 70, 160, 40, 12)
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

--== TEXTO DINÁMICO ==
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

-------
local function pintarCuadros(palabraIngresada, palabraSecreta, grupo)
    local letrasSecreta = {}
    local usadasEnSecreta = {}
    local resultado = {}

    -- Paso 1: Inicialización
    for i = 1, 5 do
        letrasSecreta[i] = palabraSecreta:sub(i, i)
        usadasEnSecreta[i] = false
        resultado[i] = "gris"  -- Por defecto todos son grises
    end

    -- Paso 2: Revisar verdes
    for i = 1, 5 do
        local letraUsuario = palabraIngresada:sub(i, i)
        if letraUsuario == letrasSecreta[i] then
            resultado[i] = "verde"
            usadasEnSecreta[i] = true
        end
    end

    -- Paso 3: Revisar amarillos
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

    -- Paso 4: Pintar los cuadros según resultado
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


--== DETECCIÓN DE TECLADO ==
local function onKeyEvent(event)
    if event.phase == "down" then
        local key = event.keyName
        local palabraActual = letrasPorRect[currentRectIndex] or ""

        if key:match("^[a-zA-Z]$") and #palabraActual < 5 then
            letrasPorRect[currentRectIndex] = palabraActual .. string.upper(key)
            actualizarTexto()

        elseif key == "deleteBack" or key == "backspace" then
            letrasPorRect[currentRectIndex] = palabraActual:sub(1, -2)
            actualizarTexto()

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

Runtime:addEventListener("key", onKeyEvent)
