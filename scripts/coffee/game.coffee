#####
##
# Dem Creepers!
# Entry for the GitHub Game Off 2013
# Author : Paul Joannon for H-Bomb
# <paul.joannon@gmail.com>
##
#####

class DrawBatch
    constructor : ->
        @_toDraw = []

    add : (elem) =>
        if jaws.isArray elem
            _.map elem, (e) =>
                @_toDraw.push e
        else
            @_toDraw.push elem

    draw : (viewport) =>
        @_toDraw = _.sortBy @_toDraw, (a) =>
            if a._box? then (do a._box.rect).bottom else a.y
        _.map @_toDraw, (item) => do item.draw
        @_toDraw = []

class Game
    constructor : ->
        if jaws?
            jaws.preventDefaultKeys ['up', 'right', 'down', 'left', 'w', 'a',
                                     's', 'd', 'space', 'left_mouse_button']
            jaws.assets.add ['assets/img/Barbarian.gif', 'assets/img/Gob.gif', 'assets/img/GobCorpse.gif',
                             'assets/img/Axe.gif', 'assets/img/HUD.gif', 'assets/img/HUD---TEXT.gif',
                             'assets/img/HUD-NUMBERSLETTERS.gif', 'assets/img/ground.gif', 'assets/audio/HIT.ogg',
                             'assets/audio/WOOSH.ogg', 'assets/img/GOLEM.gif', 'assets/img/BG---Tiles.gif']
        else
            throw "Not Implemented"

    start : =>
        jaws.start window.DemCreepers.MainGame

class Utils
    pointDirection : do ->
        _RADTODEGRATIO = 57.29577951308232
        (x1, y1, x2, y2) ->
            _RADTODEGRATIO * (Math.atan2 (y1 - y2), (x2 - x1))

    pointOrientation : do ->
        _ORFROMDIR = [ 'E', 'NE', 'N', 'NW', 'W', 'SW', 'S', 'SE', 'E' ]
        (x1, y1, x2, y2) ->
            _ORFROMDIR[(Math.round ((@pointDirection x1, y1, x2, y2) / 45)) + 4]

    pointDistance : (aX, aY, bX, bY) ->
        parseInt Math.abs Math.sqrt ((bX - aX) * (bX - aX)) + ((bY - aY) * (bY - aY))

window.DemCreepers =
    Game : Game
    Utils : new Utils
    DrawBatch : new DrawBatch
    Config :
        ActiveControls : 1
        TileSize : [50, 50]
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