class DrawBatch
    constructor : ->
        @_toDraw = []

    add : (elem) =>
        if jaws.isArray elem
            _.map elem, (e) =>
                @_toDraw.push e
        else
            @_toDraw.push elem

    draw : =>
        @_toDraw = _.sortBy @_toDraw, 'y'
        _.map @_toDraw, (item) =>
            do item.draw
        @_toDraw = []

class Game
    constructor : ->
        if jaws?
            jaws.preventDefaultKeys ['up', 'right', 'down', 'left', 'w', 'a',
                                     's', 'd', 'space']
            jaws.assets.add ['assets/img/BarbarianTurnAround.gif'
                             'assets/img/GobTurnaround.gif']
        else
            throw "Not Implemented"

    start : =>
        jaws.start window.DemCreepers.MainGame

window.DemCreepers =
    Game : Game
    DrawBatch : new DrawBatch
    ActiveControls : 1
    Controls : [
        {
            'up' : 'w'
            'right' : 'd'
            'down' : 's'
            'left' : 'a'
        }
        {
            'up' : 'up'
            'right' : 'right'
            'down' : 'down'
            'left' : 'left'
        }
        {
            'up' : 'z'
            'right' : 'd'
            'down' : 's'
            'left' : 'q'
        }
    ]