xpress = require 'express'
http = require 'http'
u = require 'underscore'


class Server
  port: 3000
  constructor: (@express=null, @port=3000, @host='127.0.0.1') ->
    @express = @express or xpress()
    @siteApis = {}

  serve: (serverOptions=null, port=null, host=null) ->
    port = port or @port
    host = host or @host
    args = [@express]
    me = @
    @express.get '/', (req, res) ->
      res.set('Content-Type', 'text/plain')
      ret = ''
      for siteApiId, siteApi of me.siteApis
        for route in siteApi[1]
          ret += route + "\n"
      res.send ret


    if serverOptions
      args.unshift serverOptions
    (http.createServer args...).listen port, host

  addSiteApi: (siteApi) ->
    routes = []
    @siteApis[siteApi.id] = [siteApi, routes]

    for routeName, route of siteApi.routes
      url = ['', siteApi.urlPortion, routeName].join('/')
      routes.push url
      @express.get url, @generateViewFn route

  generateViewFn: (route) ->
    (req, res) =>
      scraper = route.scraper

      scraper.scrape \
          @apiResponseCallback(req, res),
          route.urlGenerator(req.query),
          {
          request: req,
          express: @
          }

  apiResponseCallback: (req, res) ->
    (err, response, data) ->
      res.set('Content-Type', 'application/json; charset=utf-8')
      if err
        res.status(500)
        res.send (JSON.stringify err)
      else
        res.send data.toJSON()


module.exports = Server