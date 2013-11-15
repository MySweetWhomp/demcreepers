#####
##
# Dem Creepers!
# Entry for the GitHub Game Off 2013
# Author : Paul Joannon for H-Bomb
# <paul.joannon@gmail.com>
##
#####

###
# Characters base class
###
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
        @_orientation = 'E'
        @_bump = no
        @_state = 'idle'

    getToDraw : => @

    update : (map) =>
        @_bump = no
        @move map
        @_sprite.moveTo @x, @y

    draw : =>
        do (do @_box.rect).draw

    move : (map) =>
        @x += @_vx
        @y += @_vy
        @_box.moveTo @x, @y

class Player extends Character
    constructor : (@x, @y) ->
        super @x, @y, 5, 25, 25
        @_hp = 100
        @_sheet = new jaws.Animation
            sprite_sheet : 'assets/img/Barbarian.gif'
            frame_size : [50, 50]
            orientation : 'right'
        @_anims =
            'idle' :
                'N' : @_sheet.slice 24, 28
                'NE' : @_sheet.slice 30, 34
                'E' : @_sheet.slice 36, 40
                'SE' : @_sheet.slice 44, 48
                'S' : @_sheet.slice 0, 4
                'SW' : @_sheet.slice 6, 10
                'W' : @_sheet.slice 12, 16
                'NW' : @_sheet.slice 18, 22
            'run' :
                'N' : @_sheet.slice 72, 78
                'NE' : @_sheet.slice 78, 84
                'E' : @_sheet.slice 84, 90
                'SE' : @_sheet.slice 90, 96
                'S' : @_sheet.slice 48, 54
                'SW' : @_sheet.slice 54, 60
                'W' : @_sheet.slice 60, 66
                'NW' : @_sheet.slice 66, 72
        @_axes = []

    getToDraw : =>
        _.union @_axes, @

    update : (viewport, map) =>
        @_vx = @_vy = 0
        viewport.forceInsideVisibleArea @_sprite, 20
        @x = @_sprite.x
        @y = @_sprite.y
        @handleInputs viewport
        try
            super map
        @_sprite.setImage do @_anims[@_state][@_orientation].next
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
        controls = window.DemCreepers.Controls[window.DemCreepers.Config.ActiveControls]
        if jaws.pressed "#{controls.up}"
            @_state = 'run'
            --mov.y
            vComp = 'N'
        if jaws.pressed "#{controls.right}"
            @_state = 'run'
            ++mov.x
            hComp = 'E'
        if jaws.pressed "#{controls.down}"
            @_state = 'run'
            ++mov.y
            vComp = 'S'
        if jaws.pressed "#{controls.left}"
            @_state = 'run'
            --mov.x
            hComp = 'W'

        if not (newOr = vComp + hComp)
            @_state = 'idle'
        else
            @_orientation = (vComp + hComp)
        @_vx = @speed * mov.x
        @_vy = @speed * mov.y
        ###
        # Attacks
        ###
        if jaws.pressedWithoutRepeat "left_mouse_button"
            relX = @x - viewport.x
            relY = @y - viewport.y
            dir = window.DemCreepers.Utils.pointOrientation jaws.mouse_x, jaws.mouse_y, relX, relY
            @_axes.push new Axe dir, @x, @y
        ###
        # DEBUG
        ###
        if jaws.pressedWithoutRepeat "shift"
            @_axes.push new Axe @_orientation, @x, @y

class Axe extends Character
    constructor : (dir, @x, @y) ->
        super @x, @y, 7, 10, 10
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
        @_sheet = new jaws.Animation
            sprite_sheet : 'assets/img/Axe.gif'
            frame_size : [20, 20]
            orientation : 'right'

    update : (map) =>
        @_vx = @speed * @_dirx
        @_vy = @speed * @_diry
        @_toGo -= @speed
        try
            super map
            if @_bump
                @_toGo = 0
        @_sprite.setImage do @_sheet.next

    draw : =>
        do @_sprite.draw
        try
            do super

###
# Monsters base class
###
class Monster extends Character
    constructor : (@x, @y, @speed, @pv, width, height, sheetName, frameSize) ->
        super @x, @y, @speed, width, height
        @_sheet = new jaws.Animation
            sprite_sheet : "assets/img/#{sheetName}"
            frame_size : frameSize
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
        ###
        # Define orientation based move methods
        # Allows not to check direction each game loop iteration
        ###
        @_move =
            'N' : () => @_vy = -@speed ; @_vx = 0
            'NE' : () => @_vy = -@speed ; @_vx = @speed
            'E' : () => @_vy = 0 ; @_vx = @speed
            'SE' : () => @_vy = @speed ; @_vx = @speed
            'S' : () => @_vy = @speed ; @_vx = 0
            'SW' : () => @_vy = @speed ; @_vx = -@speed
            'W' : () => @_vy = 0 ; @_vx = -@speed
            'NW' : () => @_vy = -@speed ; @_vx = -@speed

    update : (player, map) =>
        @_orientation = window.DemCreepers.Utils.pointOrientation player.x, player.y, @x, @y
        @_sprite.setImage @_anims[@_orientation].frames[0]
        if not (do @_box.rect).collideRect (do player._box.rect)
            do @_move[@_orientation]
        else
            @_vx = @_vy = 0
        try
            super map

class Gob extends Monster
    constructor : (@x, @y) ->
        super @x, @y, 2, 1, 15, 15, 'Gob.gif', [40, 40]

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
