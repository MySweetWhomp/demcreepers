class DrawBatch
    constructor : ->
        @_toDraw = []

    add : (elem) =>
        @_toDraw.push elem

    draw : =>
        @_toDraw = _.sortBy @_toDraw, 'y'
        @_toDraw.map (item) =>
            do item.draw
        @_toDraw = []

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
    DrawBatch : new DrawBatch