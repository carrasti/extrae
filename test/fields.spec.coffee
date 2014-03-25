chai = require "chai"
Extrae = require "../src"
should = chai.should()
h = require "./testhelpers"

MovieModel = h.MovieModel
PersonModel = h.PersonModel
PersonCollection = h.PersonCollection
MovieWithNestedActors = h.MovieWithNestedActors
MovieWithNestedDirector = h.MovieWithNestedDirector
movieData = h.MOVIE_DATA
html = h.HTML

describe 'Fields', ()->
    describe 'Field', ()->
        describe '#constructor', ()->
          it 'should build the instance', ()->
              opts = {a : "a"}
              field = new Extrae.Fields.Field opts
              field.type.should.equal Extrae.Fields.Field.prototype.type
              field.opts.should.equal opts

    describe 'StringField', ()->
        describe '#constructor', ()->
          it 'should build the instance', ()->
              opts = {a : "a"}
              field = new Extrae.Fields.StringField opts
              field.type.should.equal Extrae.Fields.StringField.prototype.type
              field.opts.should.equal opts

    describe 'NumberField', ()->
        describe '#constructor', ()->
          it 'should build the instance', ()->
              opts = {a : "a"}
              field = new Extrae.Fields.NumberField opts
              field.type.should.equal Extrae.Fields.NumberField.prototype.type
              field.opts.should.equal opts

    describe 'DateField', ()->
        describe '#constructor', ()->
          it 'should build the instance', ()->
              opts = {a : "a"}
              field = new Extrae.Fields.DateField opts
              field.type.should.equal Extrae.Fields.DateField.prototype.type
              field.opts.should.equal opts

    describe 'CollectionField', ()->
        describe '#constructor', ()->
            it 'should build the instance', ()->
                opts = {a : "a"}
                collectionClass = PersonCollection
                selector = '.movies'
                field = new Extrae.Fields.CollectionField \
                          selector,
                          collectionClass,
                          opts
                field.type.should.equal \
                                Extrae.Fields.CollectionField.prototype.type
                field.opts.should.equal opts
                field.klass.should.equal collectionClass
                field.selector.should.equal selector

            it 'should throw error if no class passed', ()->
                fn = () ->
                    new Extrae.Fields.CollectionField()
                fn.should.throw Error

    describe 'ModelField', ()->
        describe '#constructor', ()->
            it 'should build the instance', ()->
                opts = {a : "a"}
                modelClass = PersonModel
                selector = '.movie'
                field = new Extrae.Fields.CollectionField \
                          selector,
                          modelClass,
                          opts
                field.type.should.equal \
                                Extrae.Fields.CollectionField.prototype.type
                field.opts.should.equal opts
                field.klass.should.equal modelClass
                field.selector.should.equal selector
            it 'should throw error if no class passed', ()->
                fn = () ->
                    new Extrae.Fields.ModelField()
                fn.should.throw Error
