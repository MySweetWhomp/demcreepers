#####
##
# Dem Creepers!
# Entry for the GitHub Game Off 2013
# Author : Paul Joannon for H-Bomb
# <paul.joannon@gmail.com>
##
#####

class Wave
    constructor : ->
        @_mobs = []
        @_mobs.push window.DemCreepers.Pools.Gobs.get 300, 300
        @_mobs.push window.DemCreepers.Pools.Gobs.get 400, 300
        @_mobs.push window.DemCreepers.Pools.Gobs.get 300, 400

    update : (player, map) =>
        toDel = []
        _.map @_mobs, (mob, index) =>
            del = no
            _.map player._axes, (axe) =>
                if ((do axe._box.rect).collideRect (do mob._box.rect)) and axe._toGo >= 0
                    axe._toGo = -1
                    if --mob.pv <= 0
                        toDel.push index
                        del = yes
            if not del
                mob.update player, map
        toDel = toDel.sort (a, b) => b - a
        _.map toDel, (index) =>
            window.DemCreepers.Pools.Gobs.add (@_mobs.splice index, 1)[0]

    getToDraw : (viewport) => _.filter @_mobs, (mob) -> viewport.isPartlyInside mob._sprite

class MainGame
    constructor : ->
        @_paused = no

    setup : =>
        [rows, cols] = [30, 40]
        @_viewport = new jaws.Viewport
            x : 0
            y : 0
            max_x : cols * window.DemCreepers.Config.TileSize[0]
            max_y : rows * window.DemCreepers.Config.TileSize[1]
        @_map = new window.DemCreepers.Map rows, cols
        @_player = new window.DemCreepers.Player 100, 100
        @_wave = new Wave
        @_pauseText = new jaws.Text
            text : 'PAUSE'

    update : =>
        if jaws.pressedWithoutRepeat 'space'
            @_paused = not @_paused
        if not @_paused
            ### Player ###
            @_player.update @_viewport, @_map._map
            ### Monsters ###
            @_wave.update @_player, @_map._map
            ### Center viewport on Player ###
            @_viewport.centerAround @_player._box

    draw : =>
        do jaws.clear
        ### Draw the ground below everything ###
        @_viewport.drawTileMap @_map._ground
        ### Player ###
        window.DemCreepers.DrawBatch.add do @_player.getToDraw
        ### Ground ###
        # _.map (do @_map.all), (tile) =>
        #     window.DemCreepers.DrawBatch.add tile
        ### Monsters ###
        window.DemCreepers.DrawBatch.add @_wave.getToDraw @_viewport
        @_viewport.apply =>
            ### Draw all ###
            window.DemCreepers.DrawBatch.draw @_viewport

        ###
        # PAUSE
        ###
        if @_paused
            do @_pauseText.draw

        (document.getElementById 'playerX').innerHTML = @_player.x
        (document.getElementById 'playerY').innerHTML = @_player.y
        (document.getElementById 'viewportX').innerHTML = @_viewport.x
        (document.getElementById 'viewportY').innerHTML = @_viewport.y

if window.DemCreepers?
    window.DemCreepers.MainGame = MainGame