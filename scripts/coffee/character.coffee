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
        @_box.coll = undefined

    draw : =>
        do (do @_box.rect).draw

    moveOneComp : (comp, map) =>
        moved = yes
        box = do @_box.rect

        @[comp] += @["_v#{comp}"]

        if @_box.coll?
            distance = window.DemCreepers.Utils.pointDistance @_box.x, @_box.y, @_box.coll.x, @_box.coll.y
            @_box.moveTo @x, @y
            distance2 = window.DemCreepers.Utils.pointDistance @_box.x, @_box.y, @_box.coll.x, @_box.coll.y
            if distance2 <= distance
                @[comp] -= @["_v#{comp}"]
                @_box.moveTo @x, @y
                moved = no
        else
            @_box.moveTo @x, @y

        if moved
            atRect = map.atRect box
            if atRect.length > 0
                for cell in atRect
                    if (do cell.rect).collideRect box
                        if cell.type is 'Gob'
                            @[comp] -= @["_v#{comp}"] / 2
                            @_box.moveTo @x, @y
                        break

    move : (map) =>
        if @_vx is 0 and @_vy is 0
            return
        @moveOneComp 'x', map
        @moveOneComp 'y', map

class Player extends Character
    constructor : (@x, @y) ->
        super @x, @y, 6, 12, 20
        @_hp = 100
        @_attack = @attack
        @_changeStateOr = @changeStateOr
        @_onlasframe = =>
        @_sheet = new jaws.Animation
            sprite_sheet : 'assets/img/Barbarian.gif'
            frame_size : [50, 50]
            orientation : 'right'
        @_state = 'attack'
        @_anims =
            'idle' :
                'N' : @_sheet.slice 24, 28
                'NE' : @_sheet.slice 30, 34
                'E' : @_sheet.slice 36, 40
                'SE' : @_sheet.slice 42, 46
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
            'attack' :
                'N' : @_sheet.slice 108, 111
                'NE' : @_sheet.slice 111, 114
                'E' : @_sheet.slice 114, 117
                'SE' : @_sheet.slice 117, 120
                'S' : @_sheet.slice 96, 99
                'SW' : @_sheet.slice 99, 102
                'W' : @_sheet.slice 102, 105
                'NW' : @_sheet.slice 105, 108
        @_axes = []

    getToDraw : =>
        _.union @_axes, @

    update : (viewport, map) =>
        if do @_anims[@_state][@_orientation].atLastFrame
            do @_onlasframe
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

    changeStateOr : (state, orientation) =>
        @_state = state
        if orientation?
            @_orientation = orientation

    attack : (dir) =>
        old = @_orientation
        @_orientation = dir
        @_axes.push new Axe dir, @x, @y
        @_state = 'attack'
        @_attack = =>
        @_changeStateOr = =>
        @_onlasframe = =>
            @_orientation = old
            @_changeStateOr = @changeStateOr
            @_onlasframe = =>
            setTimeout (=>
                @_attack = @attack
            ), 200

    handleInputs : (viewport) =>
        ###
        # Movements
        ###
        mov = x : 0, y : 0
        vComp = ''
        hComp = ''
        controls = window.DemCreepers.Controls[window.DemCreepers.Config.ActiveControls]
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

        if not (newOr = vComp + hComp)
            @_changeStateOr 'idle'
        else
            @_changeStateOr 'run', (vComp + hComp)
        @_vx = @speed * mov.x
        @_vy = @speed * mov.y
        ###
        # Attacks
        ###
        if jaws.pressedWithoutRepeat "left_mouse_button"
            relX = @x - viewport.x
            relY = @y - viewport.y
            dir = window.DemCreepers.Utils.pointOrientation jaws.mouse_x, jaws.mouse_y, relX, relY
            @_attack dir
        ###
        # DEBUG
        ###
        if jaws.pressedWithoutRepeat "shift"
            @_attack @_orientation

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
            frame_duration : 75

    move : (map) =>
        if @_vx is 0 and @_vy is 0
            return
        box = do @_box.rect
        @x += @_vx
        @_box.moveTo @x, @y
        atRect = map.atRect box
        if atRect.length > 0
            for cell in atRect
                if (do cell.rect).collideRect box
                    break
        @y += @_vy
        @_box.moveTo @x, @y
        atRect = map.atRect box
        if atRect.length > 0
            for cell in atRect
                if (do cell.rect).collideRect box
                    break

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
    constructor : (@x, @y, @speed, @pv, @reward, width, height, sheetName, frameSize) ->
        super @x, @y, @speed, width, height
        @_sheet = new jaws.Animation
            sprite_sheet : "assets/img/#{sheetName}"
            frame_size : frameSize
            orientation : 'right'
            frame_duration : 70
        @_anims =
            'N' : @_sheet.slice 20, 30
            'NE' : @_sheet.slice 30, 40
            'E' : @_sheet.slice 30, 40
            'SE' : @_sheet.slice 30, 40
            'S' : @_sheet.slice 0, 10
            'SW' : @_sheet.slice 10, 20
            'W' : @_sheet.slice 10, 20
            'NW' : @_sheet.slice 10, 20
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
        @_sprite.setImage do @_anims[@_orientation].next
        do @_move[@_orientation]
        try
            super map

class Gob extends Monster
    constructor : (@x, @y) ->
        super @x, @y, 4, 1, 10, 15, 15, 'Gob.gif', [50, 50]

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
