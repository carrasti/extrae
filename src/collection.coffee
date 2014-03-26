Backbone = require 'backbone'
u = require 'underscore'
Model = require './model'

###
Backbone.Collection subclass which acts as a list container
  for {Model} instances. It allows identifying the models by
  matching nodes via a selector
###
class Collection extends Backbone.Collection
  model: Model

  ###
  Allows performing validation over each model selector, this
  way some nodes selected can be filtered out.

  @param [Object] $ the cheerio selector for the item
  @return [Boolean] true if the item is valid
  @abstract
  ###
  validateItem : ($) ->
    true

  ###
  extracts the data from some cheerio list selector node passed, which
  contains the list of nodes to create models from.

  @param [Scraper] scraper the reference to a {Scraper}, it will be
    passed to extractors so it is possible to access some global
    properties contained on it

  @param [Object] $items a [cheerio](http://matthewmueller.github.io/cheerio/)
    HTML selector with all the nodes to extract data and create models from

  @param [Object] options any object that can be used in extractors.

  @return [Collection] this
  ###
  extractData: (scraper, $items, options) ->
    newitem = null

    u.each $items, (it)->
      # wrap with a cheerio selector
      $item = scraper.$ it

      # extract and add only the ones which pass the validation
      if @validateItem $item
        newitem = new @model()
        newitem.extractData scraper, $item, options
        @add newitem
    , @
    @

module.exports = Collection
