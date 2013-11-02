class Character
    constructor : (@x, @y, @speed, width, height) ->
        @_box = new jaws.Sprite
            x : @x
            y : @y
            width : width
            height : height
            anchor : 'center'

    update : =>
        @_box.moveTo @x, @y

    draw : =>
        do (do @_box.rect).draw

class Player extends Character
    constructor : (@x, @y) ->
        super @x, @y, 7, 40, 40
        @_sprite = new jaws.Sprite
            x : @x
            y : @y
            image : 'assets/img/Barbarian.gif'
            anchor : 'center'

    update : =>
        @x = @_sprite.x
        @y = @_sprite.y
        do @handleInputs
        @_sprite.moveTo @x, @y
        try
            do super

    draw : =>
        do @_sprite.draw
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
        @x += @speed * mov.x
        @y += @speed * mov.y

if window.Gauntlet?
    window.Gauntlet.Character = Character
    window.Gauntlet.Player = Player