class MainGame
    constructor : ->

    setup : =>
        @_player = new window.Gauntlet.Player {x:100,y:100}

    update : =>
        do @_player.update

    draw : =>
        do jaws.clear
        do @_player.draw

if window.Gauntlet?
    window.Gauntlet.MainGame = MainGame