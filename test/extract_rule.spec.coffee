chai = require "chai"
Extrae = require "../src"
should = chai.should()
h = require "./testhelpers"
cheerio = require 'cheerio'

MovieModel = h.MovieModel
PersonModel = h.PersonModel
PersonCollection = h.PersonCollection
MovieWithNestedActors = h.MovieWithNestedActors
MovieWithNestedDirector = h.MovieWithNestedDirector
movieData = h.MOVIE_DATA
html = h.HTML

px = Extrae.Processors.NodeProcessors

describe 'ExtractRule', ()->
  $ = cheerio.load html
  extractorNoSelector = new Extrae.ExtractRule null, px.EXTRACT_TEXT
  extractorNoProcessFn = new Extrae.ExtractRule '.name'
  extractorNoSelectorNoProcessFn = new Extrae.ExtractRule()
  extractor = new Extrae.ExtractRule '.name', px.EXTRACT_TEXT
  rootItem = $('#movies .movie').first().find('.actor').first()
  rootItemName = rootItem.find('.name')

  describe '#process', () ->
    it 'should extract when created with selector and function', ()->
      ret = extractor.process rootItem
      ret.should.equal movieData[0].actors[0]

    it 'should extract when created without selector', ()->
      ret = extractorNoSelector.process rootItemName
      ret.should.equal movieData[0].actors[0]

    it 'should return selector when no processFn', ()->
      ret = extractorNoProcessFn.process rootItem
      ret.should.deep.equal rootItemName

    it 'should return selector when no processFn and no selector', ()->
      ret = extractorNoSelectorNoProcessFn.process rootItem
      ret.should.equal rootItem
