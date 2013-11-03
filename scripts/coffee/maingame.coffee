class MainGame
    constructor : ->
        @_paused = no

    setup : =>
        req = new XMLHttpRequest
        req.onload = () =>
            lines = req.response.split '\n'
            [rows, cols] = _.map (lines[0].split ' '), (e) => parseInt e
            lines = _.last lines, lines.length - 1
            @_viewport = new jaws.Viewport
                x : 0
                y : 0
                max_x : rows * 40
                max_y : cols * 40
            @_map = new window.Gauntlet.Map ((blocks) =>
                y = 0
                while y < cols
                    x = 0
                    while x < rows
                        if lines[y][x] is 'x'
                            blocks.push new jaws.Sprite
                                x : x * 40
                                y : y * 40
                                width : 40
                                height : 40
                        ++x
                    ++y
            ), 40, 40, rows, cols
            @_player = new window.Gauntlet.Player 100, 100
        req.open 'get', './assets/maps/0.txt', no
        req.overrideMimeType("text/plain; charset=x-user-defined");
        do req.send

    update : =>
        if jaws.pressedWithoutRepeat 'space'
            @_paused = not @_paused
        if not @_paused
            @_player.update @_map._map
            @_viewport.centerAround @_player._box

    draw : =>
        do jaws.clear
        @_viewport.apply =>
            window.Gauntlet.DrawBatch.add do @_player.getToDraw
            _.map (do @_map.all), (tile) =>
                window.Gauntlet.DrawBatch.add tile
            do window.Gauntlet.DrawBatch.draw

        (document.getElementById 'playerX').innerHTML = @_player.x
        (document.getElementById 'playerY').innerHTML = @_player.y
        (document.getElementById 'viewportX').innerHTML = @_viewport.x
        (document.getElementById 'viewportY').innerHTML = @_viewport.y

if window.Gauntlet?
    window.Gauntlet.MainGame = MainGame