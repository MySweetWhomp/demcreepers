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
            jaws.assets.add ['img/Barbarian.gif', 'img/Gob.gif', 'img/GobCorpse.gif',
                             'img/Axe.gif', 'img/HUD.gif', 'img/HUD---TEXT.gif',
                             'img/HUD-NUMBERSLETTERS.gif', 'audio/HIT.ogg', 'img/HUD-ANIMATED.gif',
                             'audio/WOOSH.ogg', 'img/GOLEM.gif', 'img/BG---Tiles.gif'
                             'img/Block.gif', 'img/Title.gif', 'audio/START.ogg',
                             'audio/GOLEMMORT.ogg', 'audio/GAME_LOOP.ogg', 'audio/MORT02.ogg',
                             'audio/GAMEOVER.ogg', 'audio/MORT01.ogg', 'img/HUD---PICTURES.gif',
                             'audio/MENU.ogg']
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
        x = if aX > bX then aX - bX else bX - aX
        y = if aY > bY then aY - bY else bY - aY
        parseInt Math.abs Math.sqrt (x * x) + (y * y)

    getTileId : (x) ->
        n = parseInt x
        if isNaN n
            10 + (do (do x.toLowerCase).charCodeAt) - 97 # 97 is 'a' ASCII code
        else
            n

    getRandomSpawn : ->
        n = _.random 0, 7
        if n is 0
            [600, -200]
        else if n is 1
            [1400, -200]
        else if n is 2
            [1400, 450]
        else if n is 3
            [1400, 1100]
        else if n is 4
            [600, 1100]
        else if n is 5
            [-200, 1100]
        else if n is 6
            [-200, 450]
        else if n is 7
            [-200, -200]

    getNextOr : (_or) ->
        if _or is 'N'
            ['NE','NW','E','W','SE','SW','S','N']
        else if _or is 'NE'
            ['E','N','SE','NW','S','W','SW','NE']
        else if _or is 'E'
            ['SE','NE','S','N','SW','SE','W','E']
        else if _or is 'SE'
            ['S','E','SW','NE','W','N','NW','SE']
        else if _or is 'S'
            ['SW','SE','W','E','NW','NE','N','S']
        else if _or is 'SW'
            ['W','S','NW','SE','N','E','NE','SW']
        else if _or is 'W'
            ['NW','SW','N','S','NE','SE','E','W']
        else if _or is 'NW'
            ['N','W','NE','SW','S','E','SE','NW']

window.DemCreepers =
    Game : Game
    Utils : new Utils
    DrawBatch : new DrawBatch
    Config :
        ActiveControls : 1
        TileSize : [50, 50]
    Volumes :
        FX : 0.1
        Music : 0.4
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