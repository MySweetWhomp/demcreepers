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
    constructor : (@x, @y, @speed, @feetShift, width, height) ->
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
        @_feets = new jaws.Sprite
            x : @x
            y : @y + @feetShift
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
        #do (do @_box.rect).draw
        #do (do @_feets.rect).draw

    moveOneComp : (comp, map) =>
        moved = yes

        old = @[comp]

        @[comp] += @["_v#{comp}"]

        if @_box.coll?
            distance = window.DemCreepers.Utils.pointDistance @_box.x, @_box.y, @_box.coll.x, @_box.coll.y
            @_box.moveTo @x, @y
            distance2 = window.DemCreepers.Utils.pointDistance @_box.x, @_box.y, @_box.coll.x, @_box.coll.y
            if distance2 < distance
                @[comp] -= @["_v#{comp}"]
                @_box.moveTo @x, @y
                moved = no
        else
            @_box.moveTo @x, @y

        @_feets.moveTo @x, @y + @feetShift
        box = do @_feets.rect

        if moved
            atRect = map.atRect box
            if atRect.length > 0
                atRect = _.sortBy atRect, (a) => - a.type.length
                for cell in atRect
                    cellRect = do cell.rect
                    if cellRect.collideRect box
                        if cell.type is 'Gob'
                            @[comp] -= @["_v#{comp}"] / 2
                            @_feets.moveTo @x, @y + @feetShift
                        else
                            moved = no
                            @_bump = yes
                            step = @["_v#{comp}"] / Math.abs @["_v#{comp}"]
                            @[comp] -= step
                            @_feets.moveTo @x, @y + @feetShift
                            box = do @_feets.rect
                            i = 0
                            while (cellRect.collideRect box)
                                @[comp] -= step
                                @_feets.moveTo @x, @y + @feetShift
                                box = do @_feets.rect
                        break
                    @_box.moveTo @x, @y
        return moved

    move : (map) =>
        if @_vx is 0 and @_vy is 0
            return
        movedX = (@moveOneComp 'x', map) if @_vx isnt 0
        movedY = (@moveOneComp 'y', map) if @_vy isnt 0
        movedX or movedY

class Player extends Character
    constructor : (@x, @y) ->
        super @x, @y, 6, 35, 12, 20
        @Mult = 1
        @Chain = 0
        @_hit = no
        @_feets.resizeTo 30, 25
        @_orientation = 'SW'
        @Dead = no
        @WOOSH = new jaws.Audio audio : 'audio/WOOSH.ogg', volume : window.DemCreepers.Volumes.FX
        @DEAD = [
            new jaws.Audio audio : 'audio/MORT01.ogg', volume : window.DemCreepers.Volumes.FX
            new jaws.Audio audio : 'audio/MORT02.ogg', volume : window.DemCreepers.Volumes.FX
        ]
        @GAMEOVER = new jaws.Audio audio : 'audio/GAMEOVER.ogg', volume : window.DemCreepers.Volumes.FX
        @_hp = 100
        @_attack = @attack
        @_changeStateOr = @changeStateOr
        @_getHit = @getHit
        @_onlasframe = =>
        @_sheet = new jaws.Animation
            sprite_sheet : 'img/Barbarian.gif'
            frame_size : [50, 50]
            orientation : 'right'
        @_sheet2 = new jaws.Animation
            sprite_sheet : 'img/Barbarian.gif'
            frame_size : [50, 50]
            orientation : 'right'
            frame_duration : 60
        @_state = 'idle'
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
                'N' : @_sheet2.slice 108, 111
                'NE' : @_sheet2.slice 111, 114
                'E' : @_sheet2.slice 114, 117
                'SE' : @_sheet2.slice 117, 120
                'S' : @_sheet2.slice 96, 99
                'SW' : @_sheet2.slice 99, 102
                'W' : @_sheet2.slice 102, 105
                'NW' : @_sheet2.slice 105, 108
            'dead' :
                'N' : @_sheet.slice 120, 127
        @_anims['dead']['E'] = @_anims['dead']['NE'] = @_anims['dead']['SE'] = @_anims['dead']['S'] =
        @_anims['dead']['SW'] = @_anims['dead']['W'] = @_anims['dead']['NW'] = @_anims['dead']['N']
        @_axes = []

    getToDraw : =>
        _.union @_axes, [@]

    simpleUpdate : =>
        @_sprite.setImage do @_anims[@_state][@_orientation].next

    update : (viewport, map) =>
        if @Dead
            return no
        if do @_anims[@_state][@_orientation].atLastFrame
            do @_onlasframe
        if @_state isnt 'dead'
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
        return yes

    draw : =>
        do @_sprite.draw
        try
            do super

    getHit : (n) =>
        @_getHit = =>
        setTimeout (=>
            @_getHit = @getHit
        ), 1000
        @_hit = yes
        @Chain = 0
        @Mult = 1
        if (@_hp -= n) <= 0
            if @_state isnt 'dead'
                do @DEAD[_.random 0, 1].play
                setTimeout (=>
                    do @GAMEOVER.play
                ), 800
            @_hp = 0
            @_state = 'dead'
            @_onlasframe = =>
                @Dead = yes
                @_onlasframe = =>

    changeStateOr : (state, orientation) =>
        @_state = state
        if orientation?
            @_orientation = orientation

    attack : (dir) =>
        do @WOOSH.play
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
            ), 50

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
        super @x, @y, 7, 0, 10, 10
        @_toGo = 500
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
            sprite_sheet : 'img/Axe.gif'
            frame_size : [20, 20]
            orientation : 'right'
            frame_duration : 75

    move : (map) =>
        if @_vx is 0 and @_vy is 0
            return

        @x += @_vx
        @_box.moveTo @x, @y

        @y += @_vy
        @_box.moveTo @x, @y


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
    constructor : (@x, @y, @speed, @feetShift, @pv, @reward, @distAttack, width, height, sheetName, frameSize) ->
        super @x, @y, @speed, @feetShift, 10, width, height
        @_state = 'run'
        @_sheet = new jaws.Animation
            sprite_sheet : "img/#{sheetName}"
            frame_size : frameSize
            orientation : 'right'
            frame_duration : 70
        @_changeOrientation = (o) => @_orientation = o
        @_attack = @attack
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
        @_bump = no
        @_distToPlayer = window.DemCreepers.Utils.pointDistance player.x, player.y, @x, @y
        @_changeOrientation window.DemCreepers.Utils.pointOrientation player.x, player.y, @x, @y
        @_sprite.setImage do @_anims[@_state][@_orientation].next
        if @_distToPlayer > @distAttack
            do @_move[@_orientation]
            moved = @move map
            if not moved
                oldOr = @_orientation
                ors = window.DemCreepers.Utils.getNextOr @_orientation
                i = 0
                while not moved
                    @_orientation = ors[i++]
                    break if @_orientation is oldOr
                    do @_move[@_orientation]
                    moved = @move map
                if moved
                    @_changeOrientation = =>
                    setTimeout (=>
                        @_changeOrientation = (o) => @_orientation = o
                    ), (if @_bump then (@speed * 200) else (@speed * 100))
            @_state = 'run'
        else
            @_vx = @_vy = 0
            @_attack player
        @_box.coll = undefined
        @_sprite.moveTo @x, @y

    attack : (player) =>
        @_state = 'attack'
        player._getHit 5
        @_attack = =>
        setTimeout (=>
            @_attack = @attack
        ), 1000

class Gob extends Monster
    constructor : (@x, @y) ->
        super @x, @y, 4, 10, 1, 10, 35, 15, 15, 'Gob.gif', [50, 50]
        @_feets.resizeTo 30, 20
        @_anims =
            'run' :
                'N' : @_sheet.slice 20, 30
                'NE' : @_sheet.slice 30, 40
                'E' : @_sheet.slice 30, 40
                'SE' : @_sheet.slice 30, 40
                'S' : @_sheet.slice 0, 10
                'SW' : @_sheet.slice 10, 20
                'W' : @_sheet.slice 10, 20
                'NW' : @_sheet.slice 10, 20
            'attack' :
                'N' : @_sheet.slice 70, 76
                'NE' : @_sheet.slice 60, 66
                'E' : @_sheet.slice 60, 66
                'SE' : @_sheet.slice 60, 66
                'S' : @_sheet.slice 40, 46
                'SW' : @_sheet.slice 50, 56
                'W' : @_sheet.slice 50, 56
                'NW' : @_sheet.slice 50, 56

    update : (player, map) =>
        try
            super player, map

    draw : =>
        do @_sprite.draw
        try
            do super

class Golem extends Monster
    constructor : (@x, @y) ->
        super @x, @y, 2, 75, 7, 50, 200, 50, 50, 'GOLEM.gif', [150, 160]
        @_feets.resizeTo 150, 40
        @_anims =
            'run' :
                'N' : @_sheet.slice 1, 2
                'NE' : @_sheet.slice 1, 2
                'E' : @_sheet.slice 1, 2
                'SE' : @_sheet.slice 1, 2
                'S' : @_sheet.slice 1, 2
                'SW' : @_sheet.slice 1, 2
                'W' : @_sheet.slice 1, 2
                'NW' : @_sheet.slice 1, 2
            'attack' :
                'N' : @_sheet.slice 1, 2
                'NE' : @_sheet.slice 1, 2
                'E' : @_sheet.slice 1, 2
                'SE' : @_sheet.slice 1, 2
                'S' : @_sheet.slice 1, 2
                'SW' : @_sheet.slice 1, 2
                'W' : @_sheet.slice 1, 2
                'NW' : @_sheet.slice 1, 2
        @_fist = new jaws.Sprite
            anchor : 'center'
            x : @x
            y : @y
            width: 70
            height : 70

    update : (player, map) =>
        try
            super player, map

        @_fist.moveTo @x, @y

        if 'E' in @_orientation
            @_fist.move 140, 0
        else if 'W' in @_orientation
            @_fist.move -140, 0
        if 'S' in @_orientation
            @_fist.move 0, 140
        else if 'N' in @_orientation
            @_fist.move 0, -140

        if @_state is 'attack' and (do @_fist.rect).collideRect (do player._box.rect)
            player._getHit 15

    draw : =>
        do @_sprite.draw
        if @_state is 'attack'
            do @_fist.draw
        try
            do super

    attack : (player) =>
        @_state = 'attack'
        @_attack = =>
        setTimeout (=>
            @_attack = @attack
        ), 1000

if window.DemCreepers?
    window.DemCreepers.Character = Character
    window.DemCreepers.Player = Player
    window.DemCreepers.Gob = Gob
    window.DemCreepers.Golem = Golem
