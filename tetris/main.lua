pieces = {
    { 
        {0,0,0,0},
        {0,1,1,0},
        {0,1,1,0},
        {0,0,0,0}
    },
    {
        {0,0,0,0},
        {0,0,0,0},
        {1,1,1,1},
        {0,0,0,0}
    },
    { 
        {0,0,0,0},
        {0,1,0,0},
        {0,1,1,1},
        {0,0,0,0}
    },
    {
        {0,0,0,0},
        {0,0,1,0},
        {0,1,1,1},
        {0,0,0,0}
    }
}

field = {
    {0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0}
}

global_pieceColor = {10,128,0}  -- zolty, spadniety
global_clearMain = {255,0,0}   -- czerwony, opadajacy

blockSize = 32
fieldWidth = 10 -- nie dziala  #field[0] ani #(field[0]) wtf?
fieldHeight = 20 -- #field 

currPiece = pieces[love.math.random(#pieces)]
pieceActiveFallen = false
pieceActiveX = 3
pieceActiveY = 0

dx = 0
is_rotation = false
is_to_fall = false

is_game_still_on = true
global_points = 0

delta = 0
timeStep = 1

function love.load()
    windowWidth = love.graphics.getWidth()
    windowHeight = love.graphics.getHeight()
    mainFont = love.graphics.newFont("resources/Amatic-Bold.ttf", 24);
    smallFont = love.graphics.newFont("resources/Amatic-Bold.ttf", 16);
end

function love.keypressed(key, unicode)
    if key == 'w' then	is_rotation = true
    elseif key == 's' then  is_to_fall = true
    elseif key == 'a' then	dx = -1
    elseif key == 'd' then  dx = 1
    end
end

function love.update(dt)
    if is_game_still_on then
        delta = delta + dt
	
        if is_rotation then
            if canRotate(currPiece, pieceActiveX, pieceActiveY) then
                currPiece = rotate(currPiece)
            end
            is_rotation = false
        end
        
        if dx ~= 0 then
            mx = canMove(currPiece, pieceActiveX, pieceActiveY, dx)
            dx = dx * mx
            pieceActiveX = pieceActiveX + dx
            dx = 0
        end
        
        if is_to_fall then
            pieceActiveY = Drop(field, currPiece, pieceActiveX, pieceActiveY)

            delta = timeStep + 1

            is_to_fall = false
        end
        
        if delta > timeStep then
            pieceActiveFallen = Gravity(field, currPiece, pieceActiveX, pieceActiveY)

            if pieceActiveFallen then
                mergePiece(field, currPiece, pieceActiveX, pieceActiveY)
                
                --remove tetris's
                gainedPoints = removeFilled()
                if gainedPoints > 0 then
                    global_points = global_points + gainedPoints

                    if global_points > 1000 / timeStep then
                        timeStep = timeStep * 0.9
                    end
                end
                
                currPiece = pieces[love.math.random(#pieces)]
                pieceActiveX = 3
                pieceActiveY = 0
                is_game_still_on = checkAlive(currPiece, pieceActiveX, pieceActiveY)
                if not is_game_still_on then
                    currPiece = {
                        {1,0,0,1},
                        {0,1,1,0},
                        {0,1,1,0},
                        {1,0,0,1}
                    }
                end
            end

            delta = 0
        end
    else
        return true
    end

end

function love.draw()
    drawInterface()
    drawField(field)

    drawPieceField(currPiece, pieceActiveX, pieceActiveY)

    if not is_game_still_on then
        love.graphics.print(
            'Przegrana!',
            (fieldWidth) * blockSize/5,
            5 * blockSize,
            0,
            2,
            2
        )
    end
end

function Drop(field, piece, posx, posy)
    continueFall = true
    dy = 0

    while continueFall do
        y = 1
        while y < 5 do
            x = 1
            while x < 5 do
                if piece[y][x] == 1 then
                    if posy+y+dy >= 20 then
                        continueFall = false
                    elseif field[posy+y+dy+1][posx+x] == 1 then
                        continueFall = false
                    end
                end
                x = x + 1
            end
            y = y + 1
        end

        dy = dy + 1
    end

    return posy+dy-1
end

function checkAlive(piece, posx, posy)
    y = 1
    while y < 5 do
        x = 1
        while x < 5 do
            if piece[y][x] == 1 then
                if field[posy+y][posx+x] == 1 then
                    return false
                end
            end
            x = x + 1
        end
        y = y + 1
    end

    return true
end

function removeFilled()
    removedLines = 0

    y = fieldHeight
    while y > 0 do
        filledSpots = 0
        for x = 1, fieldWidth do
            filledSpots = filledSpots + field[y][x]
        end
        if filledSpots == 10 then
            i = y
            while i > 0 do
                if i > 1 then
                    field[i] = field[i-1]
                else
                    field[i] = {0,0,0,0,0,0,0,0,0,0}
                end
                i = i - 1
            end
            removedLines = removedLines + 1
        else
            y = y - 1
        end
    end

    return calculatePoints(removedLines)
end

function calculatePoints(lines)
    if lines == 0 then
        return 0
    else
        return lines + calculatePoints(lines-1)
    end
end

function canRotate(piece, posx, posy)
    ghostPiece = {
        {},{},{},{}
    }

    ghostPiece = rotate(piece)

    y = 1
    while y < 5 do
        x = 1
        while x < 5 do
            if ghostPiece[y][x] == 1 then
                if posx+x+dx > fieldWidth or posx+x+dx < 1 then
                    return false
                elseif field[posy+y][posx+x+dx] == 1 then
                    return false
                end
            end
            x = x + 1
        end
        y = y + 1
    end

    return true
end

function rotate(pieceIn)
    pieceOut = {
        {},{},{},{}
    }

    for j = 1, 4 do
        for i = 1, 4 do
            pieceOut[j][5-i] = pieceIn[i][j]
        end
    end

    return pieceOut
end

function canMove(piece, posx, posy, dx)
    mx = 1

    y = 1
    while y < 5 do
        x = 1
        while x < 5 do
            if piece[y][x] == 1 then
                if posx+x+dx > fieldWidth or posx+x+dx < 1 then
                    mx = 0
                elseif field[posy+y][posx+x+dx] == 1 then
                    mx = 0
                end
            end
            x = x + 1
        end
        y = y + 1
    end

    return mx
end

function mergePiece(field, piece, posx, posy)
    y = 1
    while y < 5 do
        x = 1
        while x < 5 do
            if piece[y][x] == 1 then
                field[posy+y][posx+x] = 1
            end
            x = x + 1
        end
        y = y + 1
    end
end

function Gravity(field, piece, posx, posy)
    isFallen = false

    y = 1
    while y < 5 do
        x = 1
        while x < 5 do
            if piece[y][x] == 1 then
                if posy + y + 1 > fieldHeight or field[posy+y+1][posx+x] == 1 then
                    isFallen = true
                end
            end
            x = x + 1
        end
        y = y + 1
    end

    if isFallen then
        return true
    else
        pieceActiveY = pieceActiveY + 1
        return false
    end
end

function drawField(field)
    y = 1
    while y < fieldHeight + 1 do
        x = 1
        while x < fieldWidth + 1 do
            if field[y][x] == 1 then
                posxd = x * blockSize
                posyd = y * blockSize
                drawBlock(posxd, posyd, global_pieceColor)
            end
            x = x + 1
        end
        y = y + 1
    end
end

function drawPieceField(piece, posx, posy)
    y = 1
    while y < 5 do
        x = 1
        while x < 5 do
            if piece[y][x] == 1 then
                posxd = (posx + x) * blockSize
                posyd = (posy + y) * blockSize
                drawBlock(posxd, posyd, global_clearMain)
            end
            x = x + 1
        end
        y = y + 1
    end
end

function drawBlock(posx, posy, color)
    love.graphics.setColor(color)
    love.graphics.rectangle("fill",
        posx - blockSize,
        posy - blockSize,
        blockSize,
        blockSize
    )
end

function drawInterface()
    love.graphics.setColor({255,255,255})
    love.graphics.rectangle("fill", 0, 0, fieldWidth * blockSize, fieldHeight * blockSize)
end    