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
    Adds several field definition to the field definition map preserving fields
    defined in superclasses. Every field definition is a 2 element array with
    `[ fieldName, Field instance ]`. Chainable.

    @param [Array] fieldDefinitions variable number of 2 element arrays
      `[ fieldName, Field instance ]`
    ###
    @addFieldDefinitions: (fieldDefinitions...) ->
        ThisClass = @::constructor
        for fieldDefinition in fieldDefinitions
            ThisClass.addFieldDefinition fieldDefinition...
        ThisClass

    ###
    Adds a field definition to the field definition map preserving fields defined
    in superclasses. Chainable.

    @param [String] fieldName name for the field
    @param [Field] field a Field instance
    ###
    @addFieldDefinition: (fieldName, field) ->
        ThisClass = @::constructor
        if ThisClass::fieldDefinitions == ThisClass.__super__.constructor::fieldDefinitions
            ThisClass::fieldDefinitions = u.clone ThisClass::fieldDefinitions

        ThisClass::fieldDefinitions[fieldName] = field
        ThisClass

    ###
    Adds several extract rules to the extract rules map preserving rules
    defined in superclasses. Every rule definition is a 2 element array with
    `[ fieldName, ExtractRule instance ]`. Chainable.

    @param [Array] extractRules variable number of 2 element arrays
      `[ fieldName, ExtractRule instance ]`
    ###
    @addExtractRules: (extractRules...) ->
        ThisClass = @::constructor
        for extractRule in extractRules
            ThisClass.addExtractRule extractRule...
        ThisClass

    ###
    Adds a extract rule to the extract rule map preserving rules defined
    in superclasses. Chainable.

    @param [String] fieldName name for the field
    @param [ExtractRule] rule a ExtractRule instance
    ###
    @addExtractRule: (fieldName, rule) ->
        ThisClass = @::constructor
        if ThisClass::extractRules == ThisClass.__super__.constructor::extractRules
            ThisClass::extractRules = u.clone ThisClass::extractRules

        ThisClass::extractRules[fieldName] = rule
        ThisClass

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