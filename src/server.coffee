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

    # defines a index page which lists all the available scraping urls
    # the view is defined inline here, perhaps could be better somewhere else
    # or make it optional
    @express.get '/', (req, res) ->
      res.set('Content-Type', 'text/plain')
      ret = ''
      for siteApiId, siteApi of me.siteApis
        for route in siteApi[1]
          ret += route + "\n"
      res.send ret

    # if there are server options take them out of the arguments.
    # At the moment serverOptions is not used for anything but can be used
    # later to override some options from the server.
    if serverOptions
      args.unshift serverOptions

    # finally start serving
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

      # the options passed to the scraper include a reference to the request
      # and to the server itself, this will allow do powerful things inside
      # the scraper
      scraperOptions = {
        request: req,
        express: @
      }

      # add optional scraper options defined in the SiteApi view
      u.defaults(scraperOptions, route.scraperOptions or {})

      scraper.scrape \
          @apiResponseCallback(req, res),
          route.urlGenerator(req.query),
          scraperOptions

  apiResponseCallback: (req, res) ->
    (err, response, data) ->
      res.set('Content-Type', 'application/json; charset=utf-8')
      if err
        res.status(500)
        res.send (JSON.stringify err)
      else
        res.send data.toJSON()


module.exports = Server