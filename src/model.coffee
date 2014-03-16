Backbone = require 'backbone'
u = require 'underscore'

###
Backbone.Model subclass in which every model attribute
corresponds to the data to be extracted.

###
class Model extends Backbone.Model

    # map with attribute id and {Field} model definition
    fieldDefinitions: {}

    # hash with attribute id and an {ExtractRule}
    extractRules: {}

    ###
    Sets field definitions to the field definition map from a list of {Field}
      instances. It preserves field definitions made in superclasses.

    @param [Array] fieldDefinitions list of {Field} instances
    ####
    @setFieldDefinitionsFromList: (fieldDefinitions) ->
        ThisClass = @::constructor
        # create shallow copy of the original value
        ThisClass::fieldDefinitions = u.clone ThisClass::fieldDefinitions
        for it in fieldDefinitions
            ThisClass::fieldDefinitions[it.name] = it
        @

    ###
    Sets extractrules to the field definition map preserving rules defined in
      superclasses.

    @param [Object] extractRulesMap map with attribute name for keys and {ExtractRule} object
      as value
    ###
    @setExtractRulesMap : (extractRulesMap) ->
        ThisClass = @::constructor
        # extends the extract rules creating shallow copy every time
        ThisClass::extractRules = u.extend {}, (ThisClass::extractRules || {}), extractRulesMap
        @


    ###
    Overrides the default toJSON method serializing also nested models and collections

    @return [Object] Object serialized as json (no functions, etc)
    ###
    toJSON: ()->
        o = super()
        for key, value of o
            # serialize any attribute which has toJSON method
            if value and value.toJSON and u.isFunction value.toJSON
                o[key] = value.toJSON()
        o

    ###
    extracts the data from some cheerio node passed as base root node

    @param [Scraper] scraper the reference to a {Scraper}, it will be
      passed to extractors so it is possible to access some global
      properties contained on it

    @param [Object] $root a [cheerio](http://matthewmueller.github.io/cheerio/)
      HTML selector with the base element to be used for parsing data
      and locating nodes to extract data from.

    @param [Object] options any object that can be used in extractors.

    @return [Model] this
    ###
    extractData: (scraper, $root, options) ->

        # iterate over the field definitions
        for fieldKey, fieldItem of @fieldDefinitions

            # if there is a extractrule for the field key apply the rule
            if @extractRules[fieldKey]?
                @set fieldKey, (@extractRules[fieldKey].process $root, options, @)

            # if the field definition is for model or collection create the
            # corresponding class instance
            else if fieldItem.type in ['collection', 'model']
                $selectedItems = if fieldItem.selector? then $root.find fieldItem.selector else $root
                subitem = new fieldItem.klass()
                subitem.extractData scraper, $selectedItems, options
                @set fieldKey, subitem

            # in any other case just set the key to the same value it had or null
            else
                @set fieldKey, (this.get fieldKey) ? null
        @

module.exports = Model