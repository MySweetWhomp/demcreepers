class MainGame
    constructor : ->

    setup : =>
        @_viewport = new jaws.Viewport
            max_x : 2000 - 800
            max_y : 2000 - 600
        @_map = new window.Gauntlet.Map ((blocks) =>
            x = y = 0
            while y < 1
                while x < 20
                    blocks.push new jaws.Sprite
                        x : x * 40
                        y : y * 40
                        width : 40
                        height : 40
                    ++x
                ++y
        ), 40, 40, 20, 15
        @_player = new window.Gauntlet.Player 0, 100

    update : =>
        @_player.update @_map._map
        @_viewport.forceInsideVisibleArea @_player._sprite, 20

    draw : =>
        do jaws.clear
        @_viewport.apply =>
            window.Gauntlet.DrawBatch.add @_player
            _.map (do @_map.all), (tile) =>
                do tile.draw
            do window.Gauntlet.DrawBatch.draw

        (document.getElementById 'playerX').innerHTML = @_player.x
        (document.getElementById 'playerY').innerHTML = @_player.y
        (document.getElementById 'viewportX').innerHTML = @_viewport.x
        (document.getElementById 'viewportY').innerHTML = @_viewport.y

if window.Gauntlet?
    window.Gauntlet.MainGame = MainGame