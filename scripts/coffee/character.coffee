class Character
    constructor : (@x, @y, @speed, width, height) ->
        @_box = new jaws.Sprite
            x : @x
            y : @y
            width : width
            height : height
            anchor : 'center'
        @_sprite = new jaws.Sprite
            x : @x
            y : @y
            anchor : 'center'
        @_vx = 0
        @_vy = 0
        @_orientation = 'S'

    update : (map) =>
        @move map
        @_sprite.moveTo @x, @y

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
        super @x, @y, 5, 25, 25
        @_sheet = new jaws.Animation
            sprite_sheet : 'assets/img/BarbarianTurnAround.gif'
            frame_size : [40, 40]
            orientation : 'right'
        @_anims =
            'N' : @_sheet.slice 4, 5
            'NE' : @_sheet.slice 5, 6
            'E' : @_sheet.slice 6, 7
            'SE' : @_sheet.slice 7, 8
            'S' : @_sheet.slice 0, 1
            'SW' : @_sheet.slice 1, 2
            'W' : @_sheet.slice 2, 3
            'NW' : @_sheet.slice 3, 4


    update : (map) =>
        @x = @_sprite.x
        @y = @_sprite.y
        do @handleInputs
        try
            super map
        @_sprite.setImage do @_anims[@_orientation].next

    draw : =>
        do @_sprite.draw
        try
            do super

    handleInputs : =>
        mov = x : 0, y : 0
        vComp = ''
        hComp = ''
        controls = window.Gauntlet.Controls[window.Gauntlet.ActiveControls]
        if jaws.pressed "#{controls.up}"
            --mov.y
            vComp = 'N'
        if jaws.pressed "#{controls.right}"
            ++mov.x
            hComp = 'E'
        if jaws.pressed "#{controls.down}"
            ++mov.y
            vComp = 'S'
        if jaws.pressed "#{controls.left}"
            --mov.x
            hComp = 'W'
        @_orientation = (vComp + hComp) || @_orientation
        @_vx = @speed * mov.x
        @_vy = @speed * mov.y

if window.Gauntlet?
    window.Gauntlet.Character = Character
    window.Gauntlet.Player = Player