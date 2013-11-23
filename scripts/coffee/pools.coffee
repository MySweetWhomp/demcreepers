#####
##
# Dem Creepers!
# Entry for the GitHub Game Off 2013
# Author : Paul Joannon for H-Bomb
# <paul.joannon@gmail.com>
##
#####

###
# Pool base class
###
class Pool
    constructor : ->
        @_queue = []

    get : =>

    add : (item) =>
        @_queue.push item

class GobPool extends Pool
    constructor : ->
        super 0
        @IN = new jaws.Audio audio : 'assets/audio/GOBGNAW.ogg', volume : 0.4

    get : (x, y) =>
        #do @IN.play
        if @_queue.length > 0
            gob = do @_queue.shift
            gob.x = x
            gob.y = y
            gob.pv = 1
            gob
        else
            new window.DemCreepers.Gob x, y

    add : (item) =>
        try
            do super

class GolemPool extends Pool
    get : (x, y) =>
        if @_queue.length > 0
            golem = do @_queue.shift
            golem.x = x
            golem.y = y
            golem.pv = 7
            golem
        else
            new window.DemCreepers.Golem x, y

    add : (item) =>
        try
            do super

if window.DemCreepers?
    window.DemCreepers.Pools =
        Gobs : new GobPool
        Golems : new GolemPool