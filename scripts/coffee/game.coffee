class Game
    constructor : ->
        if jaws?
            jaws.preventDefaultKeys ['up', 'right', 'down', 'left']
            jaws.assets.add []
        else
            throw "Not Implemented"

    start : =>
        jaws.start window.Gauntlet.MainGame

window.Gauntlet =
    Game : Game