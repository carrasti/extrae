###
Base field class which represents a field for a model. This is subclassed into
  the different types fields can be
###
class Field
    # method property indicating the field type
    type: 'field'
    ###
    @param [Object] opts optional object with options
    ###
    constructor: (@opts = null) ->

###
Field definition for string data
###
class StringField extends Field
    type: 'string'

###
Field definition for Date data
###
class DateField extends Field
    type: 'date'

###
Field definition for numeric data
###
class NumberField extends Field
    type: 'number'


###
Field definition for a nested {Collection}
###
class CollectionField extends Field
    type: 'collection'
    ###
    @param [String] selector string selector to match all the items for the
      collection to extract the data from.
    @param [Class] klass {Collection} subclass used as content for the field
      and which will be used to extract the data using the selector
    @param [Object] opts optional object with options
    ###
    constructor: (@selector, @klass = null, @opts = null) ->
        if not klass
            throw new Error "Pass the class name of the collection as klass argument"


###
Field definition for a nested {Collection}
###
class ModelField extends Field
    type: 'model'
    ###
    Field definition for a nested {Model}
    @param [String] selector string selector to match the model base element to
      extract the data from.
    @param [Class] klass {Model} subclass used as content for the field and
      which will be used to extract the data using the selector
    @param [Object] opts optional object with options
    ###
    constructor: (@selector, @klass = null, @opts = null) ->
        if not klass
            throw new Error "Pass the class name of the model as klass argument"

module.exports =
    Field: Field
    StringField: StringField
    DateField: DateField
    NumberField: NumberField
    CollectionField: CollectionField
    ModelField: ModelField
