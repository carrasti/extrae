
class SiteAPI
  constructor: (@id, @urlPortion, @scraperRequestParams = {}) ->
    @routes = {}

  addView: (viewName, urlGenerator, scraper, scraperOptions = {})->
    @routes[viewName] =
      name: viewName
      urlGenerator: urlGenerator
      scraper: scraper
      scraperOptions: scraperOptions
      scraperRequestParams: @scraperRequestParams

module.exports = SiteAPI