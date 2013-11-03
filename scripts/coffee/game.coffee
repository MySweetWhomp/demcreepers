class DrawBatch
    constructor : ->
        @_toDraw = []

    add : (elem) =>
        @_toDraw.push elem

    draw : =>
        @_toDraw = _.sortBy @_toDraw, 'y'
        _.map @_toDraw, (item) =>
            do item.draw
        @_toDraw = []

class Game
    constructor : ->
        if jaws?
            jaws.preventDefaultKeys ['up', 'right', 'down', 'left']
            jaws.assets.add ['assets/img/BarbarianTurnAround.gif'
                             'assets/img/GobTurnaround.gif']
        else
            throw "Not Implemented"

    start : =>
        jaws.start window.Gauntlet.MainGame

window.Gauntlet =
    Game : Game
    DrawBatch : new DrawBatch
    ActiveControls : 0
    Controls : [
        {
            'up' : 'w'
            'right' : 'd'
            'down' : 's'
            'left' : 'a'
        }
    ]