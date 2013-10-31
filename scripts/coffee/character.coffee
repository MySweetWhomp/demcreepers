class Character
    constructor : (@pos, @speed, width, height) ->
        @_rect = jaws.Rect @pos.x, @pos.y, width, height

    update : =>
        @_rect.moveTo @pos.x, @pos.y

    draw : =>
        do @_rect .draw

class Player extends Character
    constructor : (@pos) ->
        super @pos, 10, 100, 50

    update : =>
        do @handleInputs
        try
            do super

    handleInputs : =>
        mov = x : 0, y : 0
        if jaws.pressed 'up'
            --mov.y
        if jaws.pressed 'right'
            ++mov.x
        if jaws.pressed 'down'
            ++mov.y
        if jaws.pressed 'left'
            --mov.x
        @pos.x += @speed * mov.x
        @pos.y += @speed * mov.y

if window.Gauntlet?
    window.Gauntlet.Character = Character
    window.Gauntlet.Player = Player