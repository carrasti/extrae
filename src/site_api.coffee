
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

exports.SiteAPI = SiteAPI