_ORFROMDIR = [ 'E', 'NE', 'N', 'NW', 'W', 'SW', 'S', 'SE', 'E' ]

class Character
    constructor : (@x, @y, @speed, width, height) ->
        @_box = new jaws.Sprite
            x : @x
            y : @y
            width : width
            height : height
            anchor : 'center'
            scale : 2
        @_sprite = new jaws.Sprite
            x : @x
            y : @y
            anchor : 'center'
            scale : 2
        @_vx = 0
        @_vy = 0
        @_orientation = 'S'
        @_bump = no

    getToDraw : =>
        @

    update : (map) =>
        @_bump = no
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
            @_bump = yes
        @y += @_vy
        @_box.moveTo @x, @y
        if (map.atRect (do @_box.rect)).length > 0
            @y -= @_vy
            @_box.moveTo @x, @y
            @_bump = yes

class Player extends Character
    constructor : (@x, @y) ->
        super @x, @y, 5, 25, 25
        @_hp = 100
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
        @_axes = []

    getToDraw : =>
        _.union @_axes, @

    update : (viewport, map) =>
        @x = @_sprite.x
        @y = @_sprite.y
        @handleInputs viewport
        try
            super map
        @_sprite.setImage do @_anims[@_orientation].next
        ###
        # Manage axes
        ###
        toDel = []
        _.map @_axes, (axe, index) =>
            axe.update map
            if axe._toGo <= 0
                toDel.push index
        toDel = toDel.sort (a, b) => b - a
        _.map toDel, (index) =>
            @_axes.splice index, 1

    draw : =>
        do @_sprite.draw
        try
            do super

    handleInputs : (viewport) =>
        ###
        # Movements
        ###
        mov = x : 0, y : 0
        vComp = ''
        hComp = ''
        controls = window.DemCreepers.Controls[window.DemCreepers.ActiveControls]
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
        ###
        # Attacks
        ###
        if jaws.pressedWithoutRepeat "left_mouse_button"
            relX = @x - viewport.x
            relY = @y - viewport.y
            dir = (Math.round ((window.DemCreepers.Utils.pointDirection jaws.mouse_x, jaws.mouse_y,
                relX, relY) / 45)) + 4
            dir = _ORFROMDIR[dir]
            @_axes.push new Axe dir, @x, @y

class Axe extends Character
    constructor : (dir, @x, @y) ->
        super @x, @y, 3, 10, 10
        @_toGo = 300
        @_dirx = @_diry = 0
        if (dir.indexOf 'N') >= 0
            @_diry = -1
        else if (dir.indexOf 'S') >= 0
            @_diry = 1
        if (dir.indexOf 'W') >= 0
            @_dirx = -1
        else if (dir.indexOf 'E') >= 0
            @_dirx = 1

    update : (map) =>
        @_vx = @speed * @_dirx
        @_vy = @speed * @_diry
        @_toGo -= @speed
        try
            super map
            if @_bump
                @_toGo = 0

    draw : =>
        try
            do super

class Monster extends Character
    constructor : (@x, @y, @speed, width, height, sheetName, frameSize) ->
        super @x, @y, @speed, width, height
        @_sheet = new jaws.Animation
            sprite_sheet : "assets/img/#{sheetName}"
            frame_size : frameSize
            orientation : 'right'
        @_move =
            'N' : () => @_vy = -@speed
            'NE' : () => @_vy = -@speed ; @_vx = @speed
            'E' : () => @_vx = @speed
            'SE' : () => @_vy = @speed ; @_vx = @speed
            'S' : () => @_vy = @speed
            'SW' : () => @_vy = @speed ; @_vx = -@speed
            'W' : () => @_vx = -@speed
            'NW' : () => @_vy = -@speed ; @_vx = -@speed

    update : (player, map) =>
        dir = (Math.round ((window.DemCreepers.Utils.pointDirection player.x, player.y,
            @x, @y) / 45)) + 4
        @orientation = _ORFROMDIR[dir]
        @_sprite.setImage @_anims[@orientation].frames[0]
        do @_move[@orientation]
        try
            super map

class Gob extends Monster
    constructor : (@x, @y) ->
        super @x, @y, 2, 15, 15, 'GobTurnaround.gif', [40, 40]
        @_anims =
            'N' : @_sheet.slice 4, 5
            'NW' : @_sheet.slice 5, 6
            'W' : @_sheet.slice 6, 7
            'SW' : @_sheet.slice 7, 8
            'S' : @_sheet.slice 0, 1
            'SE' : @_sheet.slice 1, 2
            'E' : @_sheet.slice 2, 3
            'NE' : @_sheet.slice 3, 4

    update : (player, map) =>
        try
            super player, map

    draw : =>
        do @_sprite.draw
        try
            do super

if window.DemCreepers?
    window.DemCreepers.Character = Character
    window.DemCreepers.Player = Player
    window.DemCreepers.Gob = Gob