request = require 'request'
cheerio = require 'cheerio'

###
Orchestrates transformation from HTML to {Model} or {Collection}.

Preprocessors to modify initial HTML before extracting the data can be defined
as well as some extractors of data which will be added to the scrapper after
parsing html, and can be used anywhere else the scraper is passed as parameter.
###
class Scraper

    # map with key -> regex data. These are applied to the HTML content string
    # and stored the {Scraper.parsedMaps} instance property
    parseMaps: {}

    # map of key -> strings accessible from the scraper which can be useful to
    # store values to be read in {ExtractRule} or other classes with access
    # to the scraper
    parsedMaps: {}

    # reference to cheerio. Equivalent to jQuery, it can be used as public
    # attribute from the scraper reference, for example in {Model},
    # {Collection}, {ExtractRule}, etc. instances
    $: null

    # base string selector used after parsing html to identify the {Model} or
    # {Collection} base elements.
    baseSelector: null

    # {Model} or {Collection} class definition which will be used to extract the
    # data.
    returnClass: null

    # array of regular expressions to be applied to the HTML content string
    # received before parsing it with cheerio.
    preprocessors: []

    # additional options which can be used inside of the scraper module via opts
    # attribute
    opts: {}

    ###
    @param [String] baseSelector base string selector used after parsing html to
      identify the {Model} or {Collection} base elements.
    @param [Mixed] returnClass {Model} or {Collection} class definition which
      will be used to extract the data.
    @param [Array] preprocessors array of regular expressions to be applied to
      the HTML content string received before parsing it with cheerio.
    @param [Object] parseMaps map with key -> regex data. These are applied to
      the HTML content string and stored the {Scraper.parsedMaps} instance
      property
    @param [opts] opts additional options which can be used inside of the
      scraper module via opts attribute
    ###
    constructor: (@baseSelector, @returnClass, @preprocessors = [], @parseMaps = {}, @opts = {}) ->

    ###
    Applies preprocessors over a string containing html

    @param [String] html HTML string to process
    @return [String] processed string
    ###
    processHtml: (html) ->
        content = html
        for item in @preprocessors
            content = content.replace item[0], item[1]
        content

    ###
    Generates the map of parsed data from a string

    @param [String] content string to generate the maps from
    @return [Object] the object with the map of parsed strings.
    ###
    applyParseMaps: (content) ->
        @parsedMaps = {}
        for key, re of @parseMaps
            @parsedMaps[key] = content.match(re)
        @parsedMaps

    ###
    Calls cheerio over some string to obtain the reference to cheerio

    @param [String] content string containing HTML to be parsed by cheerio
    @return [Object] a cheerio reference
    ###
    loadHtml: (content) ->
        @.$ = cheerio.load content
        @.$

    ###
    Uses the parsed data by cheerio and an instantiated {#returnClass} to
    extract the data according to the fields and rules defined in the
    {#returnClass}

    @param [Object] options optional set of options to be passed when extracting
      data
    @return [Mixed] {Model} or {Collection} instance with the data extracted
    ###
    extractData: (options = null) ->
        if not @.$
            throw Error "no data parsed"

        o = new @returnClass
        o.extractData @, (@.$ @.baseSelector), options
        o


    ###
    Performs all the needed operations to extract the data from some html,
    applying on the way data parsing and map generation.

    @param [String] html string with HTML to extract the data from
    @param [Object] options optional set of options to be passed when extracting
      data
    @return [Mixed] {Model} or {Collection} instance with the data extracted
    ###
    scrape: (html, options = null) ->
        content = @.processHtml html
        @.applyParseMaps content
        @.loadHtml content
        @.extractData options

###
Scraper which will fetch via an HTTP request the HTML data to extract the data
from. It uses the `request` module to perform the http fetching.
This adds asynchronicity so the results are returned via callback.ameter.
###
class UrlScraper extends Scraper

    # @param [String] url url to scrape
    constructor: (@url, args...) ->
        super args...
    ###
    Makes the request to fetch the data and in a callback calls the
    {Scraper#scrape} method over the returned HTML

    @param [Function] callback callback to perform when parsing of the data
      occurs. The signature for this callback is `function(err, response, data)`
      having `err` a value if some error occured, `response` the response as
      returned by the `request.get` call and `data` containing the instance
      to the {#returnClass} with data extracted or a object with error
      description.
    @param [String] url optional url which if passed will override the {#url}
      set for the class.
    @param [Object] options optional set of options to be passed when extracting
      data.
    ###
    scrape: (callback, url = null, options = null) ->
        url = if url then url else @.url
        request.get url, (error, response, body) =>
            if error
                callback error, response, {'error':'An error has occurred'}

            o = super body, options

            callback null, response, o

module.exports.Scraper = Scraper
module.exports.UrlScraper = UrlScraper