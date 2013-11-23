#####
##
# Dem Creepers!
# Entry for the GitHub Game Off 2013
# Author : Paul Joannon for H-Bomb
# <paul.joannon@gmail.com>
##
#####

Score = 0
KillCount = 0

class Wave
    constructor : ->
        @HIT = new jaws.Audio audio : 'assets/audio/HIT.ogg', volume : 0.4
        @_mobs = []
        @_mobs.push window.DemCreepers.Pools.Golems.get 300, 300
        return
        @_mobs.push window.DemCreepers.Pools.Gobs.get 400, 300
        @_mobs.push window.DemCreepers.Pools.Gobs.get 300, 400
        @_mobs.push window.DemCreepers.Pools.Gobs.get 300, 500
        @_mobs.push window.DemCreepers.Pools.Gobs.get 500, 300
        @_mobs.push window.DemCreepers.Pools.Gobs.get 400, 400
        @_mobs.push window.DemCreepers.Pools.Gobs.get 500, 500
        @_mobs.push window.DemCreepers.Pools.Gobs.get 500, 600
        @_mobs.push window.DemCreepers.Pools.Gobs.get 500, 700
        @_mobs.push window.DemCreepers.Pools.Gobs.get 500, 800
        @_mobs.push window.DemCreepers.Pools.Gobs.get 500, 900

    update : (player, map) =>
        toDel = []
        _.map @_mobs, (mob, index) =>
            del = no
            _.map player._axes, (axe) =>
                if ((do axe._box.rect).collideRect (do mob._box.rect)) and axe._toGo >= 0
                    axe._toGo = -1
                    if --mob.pv <= 0
                        #do mob._DEATH.play
                        toDel.push index
                        del = yes
                        map.add mob
                        Score += mob.reward
                        KillCount += 1
                        do @HIT.play
            if not del
                mob.update player, map._map
        toDel = toDel.sort (a, b) => b - a
        _.map toDel, (index) =>
            window.DemCreepers.Pools.Gobs.add (@_mobs.splice index, 1)[0]

    getToDraw : (viewport) => _.filter @_mobs, (mob) -> viewport.isPartlyInside mob._sprite

class HUD
    constructor : ->
        @_letters =new jaws.SpriteSheet
            image : 'assets/img/HUD-NUMBERSLETTERS.gif'
            frame_size : [15, 15]
            orientation : 'right'
        @_bg = new jaws.Sprite
            image : 'assets/img/HUD.gif'
            width: 400
            height: 20
            scale : 2
            x : 0
            y : 0
        ###
        # HP
        ###
        @_hp = new jaws.SpriteList
        _.map [0..2], (i) =>
            @_hp.push new jaws.Sprite
                image : @_letters.frames[0]
                x : 85 - i * 17
                y : 5
                scale : 2
        ###
        # Kills
        ###
        @_kills = new jaws.SpriteList
        _.map [0..3], (i) =>
            @_kills.push new jaws.Sprite
                image : @_letters.frames[0]
                x : 410 - i * 17
                y : 5
                scale : 2
        ###
        # Score
        ###
        @_score = new jaws.SpriteList
        _.map [0..10], (i) =>
            @_score.push new jaws.Sprite
                image : @_letters.frames[0]
                x : 750 - i * 17
                y : 5
                scale : 2

    update : (player) =>
        _.map [0..2], (i) =>
            (@_hp.at i).setImage @_letters.frames[0]
        _.map do ((String player._hp).split '').reverse, (n, i) =>
            (@_hp.at i).setImage @_letters.frames[n]
        _.map do ((String Score).split '').reverse, (n, i) =>
            (@_score.at i).setImage @_letters.frames[n]
        _.map do ((String KillCount).split '').reverse, (n, i) =>
            (@_kills.at i).setImage @_letters.frames[n]

    draw : =>
        do @_bg.draw
        do @_hp.draw
        do @_score.draw
        do @_kills.draw


class MainGame
    constructor : ->
        @_paused = no
        @_texts = new jaws.SpriteSheet
            image : 'assets/img/HUD---TEXT.gif'
            frame_size : [80, 20]
        @_quadtree = new jaws.QuadTree

    setup : =>
        [rows, cols] = [24, 32]
        @_viewport = new jaws.Viewport
            x : 0
            y : 20
            max_x : cols * window.DemCreepers.Config.TileSize[0]
            max_y : rows * window.DemCreepers.Config.TileSize[1]
        @_hud = new HUD
        @_map = new window.DemCreepers.Map rows, cols
        @_player = new window.DemCreepers.Player 100, 100
        @_wave = new Wave
        @_pauseOverlay = new jaws.Sprite
            x : 0
            y : 0
            width : 800
            height : 600
            color : 'rgba(0,0,0,.5)'
        @_pauseText = new jaws.Sprite
            image : @_texts.frames[0]
            anchor : 'center'
            x : 450
            y : 300
            scale : 2

    update : =>
        if jaws.pressedWithoutRepeat 'space'
            @_paused = not @_paused
        if not @_paused
            all = _.union (_.map @_wave._mobs, (item) -> item._box), [@_player._box]
            @_quadtree.collide all, all, (a, b) =>
                a.coll = b
                b.coll = a
            ### Player ###
            @_player.update @_viewport, @_map._map
            ### Monsters ###
            @_wave.update @_player, @_map
            ### Center viewport on Player ###
            @_viewport.centerAround @_player._box
            ### HUD ###
            @_hud.update @_player

    draw : =>
        do jaws.clear
        ### Draw the ground below everything ###
        @_viewport.drawTileMap @_map._ground
        ### Player ###
        window.DemCreepers.DrawBatch.add do @_player.getToDraw
        ### Ground ###
        _.map (do @_map.all), (tile) =>
            window.DemCreepers.DrawBatch.add tile
        ### Monsters ###
        window.DemCreepers.DrawBatch.add @_wave.getToDraw @_viewport
        @_viewport.apply =>
            ### Draw all ###
            window.DemCreepers.DrawBatch.draw @_viewport

        ### HUD ###
        do @_hud.draw

        ###
        # PAUSE
        ###
        if @_paused
            do @_pauseOverlay.draw
            do @_pauseText.draw

        (document.getElementById 'playerX').innerHTML = @_player.x
        (document.getElementById 'playerY').innerHTML = @_player.y
        (document.getElementById 'viewportX').innerHTML = @_viewport.x
        (document.getElementById 'viewportY').innerHTML = @_viewport.y

if window.DemCreepers?
    window.DemCreepers.MainGame = MainGame