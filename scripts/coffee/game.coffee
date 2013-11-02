class Game
    constructor : ->
        if jaws?
            jaws.preventDefaultKeys ['up', 'right', 'down', 'left']
            jaws.assets.add ['assets/img/Barbarian.gif']
        else
            throw "Not Implemented"

    start : =>
        jaws.start window.Gauntlet.MainGame

window.Gauntlet =
    Game : Game