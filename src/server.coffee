xpress = require 'express'
http = require 'http'
u = require 'underscore'



class SiteAPI
  routes: {}

  constructor: (@id, @urlPortion, @scraperRequestParams = {}) ->

  addView: (viewName, urlGenerator, scraper, scraperOptions = {})->
    @routes[viewName] =
      name: viewName
      urlGenerator: urlGenerator
      scraper: scraper
      scraperOptions: scraperOptions
      scraperRequestParams: @scraperRequestParams




class Server
  siteApis: {}
  port: 3000
  constructor: (@express=null, @port=3000) ->
    @express = @express or xpress()

  serve: (serverOptions=null, port=null) ->
    port = port or @port
    args = [@express]
    me = @
    @express.get '/', (req, res) ->
      res.set('Content-Type', 'text/plain');
      ret = ''
      for siteApiId, siteApi of me.siteApis
        for route in siteApi[1]
          ret += route + "\n"
      res.send ret


    if serverOptions
      args.unshift serverOptions
    (http.createServer args...).listen port

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

      console.log('calling the scraper!')
      scraper.scrape \
          @apiResponseCallback(req, res),
          route.urlGenerator(req.query),
          {
            request: req,
            express: @
          }

  apiResponseCallback: (req, res) ->
    (err, response, data) ->
      res.set('Content-Type', 'application/json')
      if err
        res.status(500)
        res.send (JSON.stringify err)
      else
        res.send data.toJSON()


module.exports.Server = Server
module.exports.SiteAPI = SiteAPI
