class MainGame
    constructor : ->
        @_paused = no

    setup : =>
        [rows, cols] = [30, 40]
        @_viewport = new jaws.Viewport
            x : 0
            y : 0
            max_x : cols * 40
            max_y : rows * 40
        @_map = new window.DemCreepers.Map 40, 40, rows, cols
        @_player = new window.DemCreepers.Player 100, 100
        @_gob = new window.DemCreepers.Gob 500, 500
        @_pauseText = new jaws.Text
            text : 'PAUSE'

    update : =>
        if jaws.pressedWithoutRepeat 'space'
            @_paused = not @_paused
        if not @_paused
            @_player.update @_viewport, @_map._map
            @_gob.update @_player, @_map._map
            @_viewport.centerAround @_player._box

    draw : =>
        do jaws.clear
        @_viewport.apply =>
            window.DemCreepers.DrawBatch.add do @_player.getToDraw
            window.DemCreepers.DrawBatch.add do @_gob.getToDraw
            _.map (do @_map.all), (tile) =>
                window.DemCreepers.DrawBatch.add tile
            do window.DemCreepers.DrawBatch.draw

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