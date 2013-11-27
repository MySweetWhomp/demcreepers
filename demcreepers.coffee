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

demcreepers = do express

demcreepers.set 'port', process.env.PORT || 8888
demcreepers.set 'views', __dirname
demcreepers.set 'view engine', 'jade'
demcreepers.use (require 'connect-assets') src : './assets'
demcreepers.use express.static './assets'

demcreepers.get '/', (req, res) ->
    res.render 'index'

demcreepers.get '/scores', (req, res) ->
    res.json [
        {name:'PAU',value:'100000'}
        {name:'ASA',value:'78382'}
        {name:'ASS',value:'42940'}
        {name:'OSY',value:'38022'}
        {name:'DED',value:'984'}
        {name:'TKH',value:'101'}
    ]

(http.createServer demcreepers).listen (demcreepers.get 'port'), ->
    console.log "Dem Creepers! up and running on #{demcreepers.get 'port'}"