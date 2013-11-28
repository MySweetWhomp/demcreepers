#####
##
# Dem Creepers!
# Entry for the GitHub Game Off 2013
# Author : Paul Joannon for H-Bomb
# <paul.joannon@gmail.com>
##
#####

express = require 'express'
http = require 'http'
path = require 'path'
mongodb = require 'mongodb'

demcreepers = do express
db = undefined

demcreepers.set 'port', process.env.PORT || 8888
demcreepers.set 'views', __dirname
demcreepers.set 'view engine', 'jade'
demcreepers.use do express.bodyParser
demcreepers.use (require 'connect-assets') src : './assets'
demcreepers.use express.static './assets'

demcreepers.get '/', (req, res) ->
    res.render 'index'

demcreepers.get '/scores', (req, res) ->
    (((do (db.collection 'score').find).sort {'value':-1}).limit 10).toArray (err, docs) =>
        res.json docs

demcreepers.post '/score', (req, res) ->
    if req.body.name? and req.body.score?
        item =
            name : req.body.name
            value : parseInt req.body.score
        (db.collection 'score').insert item, {w:1}, (err, obj) =>
            if err?
                console.error err
                res.send 500
            else
                res.send 200
    else
        res.send 500

mongodb.MongoClient.connect (process.env.MONGO || "mongodb://127.0.0.1:27017/demcreepers"), (err, _db) =>
    if err?
        console.error err
        process.exit 1
    db = _db
    (http.createServer demcreepers).listen (demcreepers.get 'port'), ->
        console.log "Dem Creepers! up and running on #{demcreepers.get 'port'}"