class Character
    constructor : (@x, @y, @speed, width, height) ->
        @_box = new jaws.Sprite
            x : @x
            y : @y
            width : width
            height : height
            anchor : 'center'
        @_vx = 0
        @_vy = 0

    update : (map) =>
        @move map

    draw : =>
        do (do @_box.rect).draw

    move : (map) =>
        @x += @_vx
        @_box.moveTo @x, @y
        if (map.atRect (do @_box.rect)).length > 0
            @x -= @_vx
            @_box.moveTo @x, @y
        @y += @_vy
        @_box.moveTo @x, @y
        if (map.atRect (do @_box.rect)).length > 0
            @y -= @_vy
            @_box.moveTo @x, @y

class Player extends Character
    constructor : (@x, @y) ->
        super @x, @y, 7, 40, 40
        @_sprite = new jaws.Sprite
            x : @x
            y : @y
            image : 'assets/img/Barbarian.gif'
            anchor : 'center'

    update : (map) =>
        @x = @_sprite.x
        @y = @_sprite.y
        do @handleInputs
        try
            super map
        @_sprite.moveTo @x, @y

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
        @_vx = @speed * mov.x
        @_vy = @speed * mov.y

if window.Gauntlet?
    window.Gauntlet.Character = Character
    window.Gauntlet.Player = Player