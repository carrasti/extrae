u = require 'underscore'
###
Defines in a structured manner the way to define different views to extract
data from a site. This is used by the {Server} instances to define routes to
views to scrape data.

@example This is some example on how to use it:

  Extrae = require 'extrae'

  # contains Extrae.Scraper instances
  MovieScrapers = require './moviescrapers'

  movieSite = new Extrae.SiteAPI \
                        # id used by the Server
                        'example',
                        # url used by the Server, will add all the api urls
                        # under /example/
                        'example',
                        # default requestParams argument which will be passed
                        # to initialize  the scrapers of this SiteApi
                        { headers:{ 'Host':'www.example.com' } }

  # adds a view to scrape search results view
  movieSite.addView \
                # this will the server create url /example/movie-search/
                'movie-search',
                # generates the url to scrape based on the parameters passed
                # via get to the server url /example/movie-search/?s=string
                (params) ->
                    url = 'http://www.example.com/search/?q=' + params.s
                    url
                ,
                # the scraper instance used to extract the results from the page
                MovieScrapers.movieSearchScraper

  # adds a view to scrape search results view
  movieSite.addView \
                # this will the server create url /example/movie-detail/
                'movie-detail',
                # generates the url to scrape based on the parameters passed
                # via get to the server url /example/movie-search/?s=string
                (params) ->
                    url = 'http://www.example.com/movie/?q=' + params.id
                    url
                ,
                # the scraper instance to extract the results from the page
                MovieScrapers.movieDetailScraper

###
class SiteAPI

  # identifier for the api, it is used to the {Server} including the `SiteApi`
  # to register the views added
  id : null

  # used by the {Server} instance to place all the views defined in this
  # `SiteApi` under the url ... `/<urlPortion>/<viewName>/'
  urlPortion: null

  # optional scraperRequestParams which will be pased as default to the view
  # {Scraper} when instantiated
  scraperRequestParams: null

  # stores the routes for this `SiteApi` as key object pairs.
  routes: null

  ###
  @param [String] id identifier used for the siteApi. It is used by the {Server}
    instance to which the view is added. Must be unique between all the
    `SiteApi` instances added to the {Server}
  @param [String] urlPortion used by the {Server} instance, it determines the
    baseUrl under which all this `SiteApi` views will be available
  @param [Object] requestParams object with params to pass to the the scraper
    to all the views registered for this api
  ###
  constructor: (@id, @urlPortion, @scraperRequestParams = {}) ->
    @routes = {}

  ###
  Registers a view for this SiteApi. Views are defined with a name for it which
    will be used by the {Server} to determine the URL. A urlGenerator function
    which will generate the URL based in the arguments passed to the {Server}
    view registered. A {Scraper} instance with the scraper to use to
    extract results and optionally options passed to the scraper.

  @param [String] id identifier used for the siteApi. It is used by the {Server}
    instance to which the view is added. Must be unique between all the
    `SiteApi` instances added to the {Server}
  @param [String] urlPortion used by the {Server} instance, it determines the
    baseUrl under which all this `SiteApi` views will be available
  @param [Scraper] scraper {Scraper} instance used to extract the data received
    from the remote html view
  @param [Object] requestParams object with params to pass to the the scraper
    to all the views registered for this api
  ###
  addView: (viewName, urlGenerator, scraper, scraperOptions = {})->
    # set the default scraperRequestParams to the scraper at this point
    scraper.requestParams = u.defaults \
                                u.clone(scraper.requestParams || {}),
                                @scraperRequestParams

    @routes[viewName] =
      name: viewName
      urlGenerator: urlGenerator
      scraper: scraper
      scraperOptions: scraperOptions

module.exports = SiteAPI