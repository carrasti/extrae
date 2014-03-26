u = require 'underscore'

###
Defines a rule to extract data. These rules consist of an optional selector
and an optional processor function.

When the rule is processed a cheerio selector is passed. If the rule defines
a selector the selector is matched under the passed base item selector. If the
rule defines a extractor function, then the process function is applied over
the cheerio selector.

###
class ExtractRule
  ###
  @param [String] selector a string with a selector to apply over the base
    selector passed when processing
  @param [Function] processFn a function used to extract some data out of
    cheerio selectors. This method must have the signature
    `function($el, options, model)`
  ###
  constructor: (@selector = null, @processFn = null) ->

  ###
  Executes the rule over a passed root item.

  @param [Object] $rootItem the cheerio selector element to extract data from
  @param [Object] options optional object passed to the process function
    function and which allows additional processing.
  @param [Model] model the model using this ExtractRule

  @return [Mixed] return the results from extracting the data or the selector
    for the item
  ###

  process: ($rootItem, options, model) ->
    $el = if @selector then $rootItem.find @selector else $rootItem

    if this.processFn and u.isFunction this.processFn
      this.processFn $el, options, model
    else
      $el

module.exports = ExtractRule

