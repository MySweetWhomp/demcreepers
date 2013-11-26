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
Waves = 1

Packs =
    Count : 2
    Value : 15

class Wave
    constructor : ->
        @HIT = new jaws.Audio audio : 'assets/audio/HIT.ogg', volume : window.DemCreepers.Volumes.FX
        @_mobs = []
        @_pack = 0

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

    nextPack : =>

class Wave1 extends Wave
    constructor : ->
        super 0
        do @regen

    regen : =>
        @_mobs = []
        [x, y] = do window.DemCreepers.Utils.getRandomSpawn
        @_mobs.push new window.DemCreepers.Gob x, y
        _.map [1..8], (i) =>
            setTimeout (=>
                @_mobs.push new window.DemCreepers.Gob x, y
            ), i * 100

    nextPack : =>
        ++@_pack
        if @_pack < 2
            do @regen
            return yes
        else
            return no

class Wave2 extends Wave
    constructor : ->
        super 0
        do @regen

    regen : =>
        @_mobs = []
        [x, y] = do window.DemCreepers.Utils.getRandomSpawn
        @_mobs.push new window.DemCreepers.Golem x, y
        _.map [1..6], (i) =>
            setTimeout (=>
                @_mobs.push new window.DemCreepers.Gob x, y
            ), i * 100

    nextPack : =>
        ++@_pack
        if @_pack < 2
            do @regen
            return yes
        else
            return no

class RandWave extends Wave
    constructor : (@nbPacks, @packsValue) ->
        super 0
        do @regen

    genPack : =>
        [x, y] = do window.DemCreepers.Utils.getRandomSpawn
        n = @packsValue
        while n > 0
            if n >= 10
                rand = _.random 0, 1
                if rand
                    @_mobs.push new window.DemCreepers.Golem x, y
                else
                    _.map [0..9], () =>
                        @_mobs.push new window.DemCreepers.Gob x, y
                n -= 10
            else
                @_mobs.push new window.DemCreepers.Gob x, y
                n -= 1

    regen : =>
        @_mobs = []
        max = Math.round (@nbPacks / 2)
        n = _.random 1, max
        while n > @nbPacks - @_pack
            n = _.random 1, max
        _.map [1..n], =>
            do @genPack
            ++@_pack
        return

    nextPack : =>
        if @_pack >= @nbPacks
            return no
        else
            do @regen
            return yes

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
        do @createMessages
        @_msg = new jaws.Sprite
            width : 300
            height : 20
            anchor : 'center'
            x : 400
            y : 300
            scale : 2
        @_msg2 = new jaws.Sprite
            width : 300
            height : 20
            anchor : 'center'
            x : 400
            y : 340
            scale : 2
        @_end = [no, no]
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
        # Waves
        ###
        @_waves = new jaws.SpriteList
        _.map [0..2], (i) =>
            @_waves.push new jaws.Sprite
                image : @_letters.frames[0]
                x : 250 - i * 17
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

    createMessages : =>
        @_messages =new jaws.Animation
            sprite_sheet : 'assets/img/HUD-ANIMATED.gif'
            frame_size : [300, 20]
            frame_duration : 70
            loop : no
            subsets :
                'wave' : [0, 6]
                'perfect' : [6, 13]
            on_end : =>
                setTimeout (=>
                    @_end = [no, no]
                    do @createMessages
                ), 1000

    update : (player) =>
        _.map [0..2], (i) =>
            (@_hp.at i).setImage @_letters.frames[0]
        _.map do ((String player._hp).split '').reverse, (n, i) =>
            (@_hp.at i).setImage @_letters.frames[n]

        _.map do ((String Waves).split '').reverse, (n, i) =>
            (@_waves.at i).setImage @_letters.frames[n]

        _.map do ((String Score).split '').reverse, (n, i) =>
            (@_score.at i).setImage @_letters.frames[n]

        _.map do ((String KillCount).split '').reverse, (n, i) =>
            (@_kills.at i).setImage @_letters.frames[n]

        if @_end[0]
            @_msg.setImage do @_messages.subsets['wave'].next
            @_msg2.setImage do @_messages.subsets['perfect'].next

    draw : =>
        do @_bg.draw
        do @_hp.draw
        do @_waves.draw
        do @_score.draw
        do @_kills.draw
        if @_end[0]
            do @_msg.draw
            if @_end[1]
                do @_msg2.draw

class MainGame
    constructor : ->
        @_paused = no
        @_texts = new jaws.SpriteSheet
            image : 'assets/img/HUD---TEXT.gif'
            frame_size : [80, 20]
        @_titleSheet = new jaws.SpriteSheet
            image : 'assets/img/HUD---PICTURES.gif'
            frame_size : [100, 80]
        @_quadtree = new jaws.QuadTree
        @_update = @titleUpdate
        @_draw = @titleDraw
        @_pressStart = new jaws.Sprite
            image : @_titleSheet.frames[2]
            anchor : 'center'
            scale : 2
            width : 100
            height : 80
            x : 400
            y : 220
        @_title = new jaws.Sprite
            image : 'assets/img/Title.gif'
            width : 380
            height : 53
            scale : 2
            x : 20
            y : 20
        @START = new jaws.Audio audio : 'assets/audio/START.ogg', volume : window.DemCreepers.Volumes.FX
        @MENU = new jaws.Audio
            audio : 'assets/audio/MENU.ogg'
            volume : window.DemCreepers.Volumes.Music
            loop : yes

    setup : =>
        do @MENU.play
        [rows, cols] = [9, 12]
        @_viewport = new jaws.Viewport
            x : 0
            y : 20
            max_x : cols * (window.DemCreepers.Config.TileSize[0] * 2)
            max_y : rows * (window.DemCreepers.Config.TileSize[1] * 2)
        @_hud = new HUD
        @_map = new window.DemCreepers.Map rows, cols
        @_player = new window.DemCreepers.Player 600, 450
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
        @_gameOverText = new jaws.Sprite
            image : @_texts.frames[2]
            anchor : 'center'
            x : 450
            y : 300
            scale : 2
        @_overlayText = 'pauseText'

    nextWave : =>
        do @_map.updateForNextWave

        if Waves < 2
            @_wave = new Wave1
        else if Waves < 3
            @_wave = new Wave2
        else
            if not (Waves % 4)
                rand = _.random 1, 2
                if rand is 1
                    ++Packs.Count
                else
                    Packs.Value += 5
            @_wave = new RandWave Packs.Count, Packs.Value

        ++Waves
        Score += 100
        @_hud._end[0] = yes
        if @_player._hp is 100
            Score += 500
            @_hud._end[1] = yes

    gameupdate : =>
        if (@_overlayText isnt 'gameOverText') and jaws.pressedWithoutRepeat 'space'
            @_paused = not @_paused
            if @_paused then do @_music.pause else do @_music.play

        if not @_paused
            if @_wave._mobs.length  is 0
                @_quadtree = new jaws.QuadTree
                if not (do @_wave.nextPack)
                    do @nextWave

            all = _.union (_.map @_wave._mobs, (item) -> item._box), [@_player._box]
            all = _.filter all, (x) => @_viewport.isPartlyInside x
            try
                if all.length > 1
                    @_quadtree.collide all, all, (a, b) =>
                        a.coll = b
                        b.coll = a

            ### Player ###
            if not (@_player.update @_viewport, @_map._map)
                @_paused = yes
                @_overlayText = 'gameOverText'
                do @_music.stop
            ### Monsters ###
            @_wave.update @_player, @_map
            ### Center viewport on Player ###
            @_viewport.centerAround @_player._box
            ### HUD ###
            @_hud.update @_player

            do @_quadtree.clear

    gamedraw : =>
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
            do @["_#{@_overlayText}"].draw

        ###
        (document.getElementById 'playerX').innerHTML = @_player.x
        (document.getElementById 'playerY').innerHTML = @_player.y
        (document.getElementById 'viewportX').innerHTML = @_viewport.x
        (document.getElementById 'viewportY').innerHTML = @_viewport.y
        ###

    titleUpdate : =>
        do @_player.simpleUpdate

        ### Center viewport on Player ###
        @_viewport.centerAround @_player._box

        if jaws.pressedWithoutRepeat 'enter'
            do @MENU.stop
            do @START.play
            setTimeout (=>
                @_music = new jaws.Audio {
                    audio : 'assets/audio/GAME_LOOP.ogg'
                    volume : window.DemCreepers.Volumes.Music
                    loop : 1
                }
                do @_music.play
                @_update = @gameupdate
                @_draw = @gamedraw
                @_wave = new Wave1
            ), 500

    titleDraw : =>
        do jaws.clear
        ### Draw the ground below everything ###
        @_viewport.drawTileMap @_map._ground
        ### Player ###
        window.DemCreepers.DrawBatch.add do @_player.getToDraw
        @_viewport.apply =>
            ### Draw all ###
            window.DemCreepers.DrawBatch.draw @_viewport
        do @_pressStart.draw
        do @_title.draw

    update : =>
        do @_update

    draw : =>
        do @_draw

if window.DemCreepers?
    window.DemCreepers.MainGame = MainGame