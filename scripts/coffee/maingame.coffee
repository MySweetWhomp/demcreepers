class MainGame
    constructor : ->

    setup : =>
        @_viewport = new jaws.Viewport
            max_x : 2000 - 800
            max_y : 2000 - 600
        @_player = new window.Gauntlet.Player 0, 0

    update : =>
        do @_player.update
        @_viewport.forceInsideVisibleArea @_player._sprite, 20

    draw : =>
        do jaws.clear
        @_viewport.apply =>
            do @_player.draw

        (document.getElementById 'playerX').innerHTML = @_player.x
        (document.getElementById 'playerY').innerHTML = @_player.y
        (document.getElementById 'viewportX').innerHTML = @_viewport.x
        (document.getElementById 'viewportY').innerHTML = @_viewport.y

if window.Gauntlet?
    window.Gauntlet.MainGame = MainGame