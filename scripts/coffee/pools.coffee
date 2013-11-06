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
    get : (x, y) =>
        if @_queue.length > 0
            gob = do @_queue.shift
            gob.x = x
            gob.y = y
            gob
        else
            new window.DemCreepers.Gob x, y

    add : (item) =>
        item.pv = 1
        try
            do super

if window.DemCreepers?
    window.DemCreepers.Pools =
        Gobs : new GobPool