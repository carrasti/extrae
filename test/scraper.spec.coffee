chai = require "chai"
Extrae = require "../src"
should = chai.should()
h = require "./testhelpers"
cheerio = require "cheerio"
httpModule = require 'http'

describe 'Scraper', ()->
  server = null
  serverUrl = 'http://127.0.0.1:9875/'

  # server to test scraper with url
  before ()->
    server = httpModule.createServer (req, res) ->
      if req.url == '/'
        res.writeHead 200, {'Content-Type': 'text/html'}
        res.end h.HTML
      else if req.url == '/error/'
        res.writeHead 500, {'Content-Type': 'text/plain'}
        res.end 'Error'
      else
        res.writeHead 500, {'Content-Type': 'text/plain'}
        res.end 'Not Found'

    server.listen 9875

  after ()->
    server.close()

  class TestModel extends Extrae.Model
  TestModel
    .addFieldDefinition 'name', new Extrae.Fields.StringField
    .addExtractRule 'name',
                    new Extrae.ExtractRule \
                              '.name',
                              Extrae.Processors.NodeProcessors.EXTRACT_TEXT
  extractHtml = '<body><div class="name">Alice</div></body>'
  testScraper = new Extrae.Scraper 'body', TestModel

  describe '#processHtml', ()->
    preprocesshtml = '<div>Rxexmxoxvxex</div>'

    it 'should apply replacements to html', () ->
      processHtmlScraper = new Extrae.Scraper null, null, [[/x/g, '']]
      ret = processHtmlScraper.processHtml preprocesshtml
      ret.should.equal '<div>Remove</div>'
      processHtmlScraper.preprocessors.push [/Rem/, 'M']
      ret = processHtmlScraper.processHtml preprocesshtml
      ret.should.equal '<div>Move</div>'
    it 'should not modify input if no preprocessors', ()->
      scraperNoPreprocessors = new Extrae.Scraper()
      ret = scraperNoPreprocessors.processHtml preprocesshtml
      ret.should.equal preprocesshtml

  describe '#applyParse', ()->
    parseMapHtml = '<!-- meaning_of_life=42 --><div>Rxexmxoxvxex</div>'

    it 'should parse maps', () ->
      parseMapScraper = new Extrae.Scraper null, null, null,
                              { 'meaningComment' : /<!-- ([a-z_]+)=(\d+) -->/ }
      parseMapScraper.applyParseMaps(parseMapHtml)
      parseMapScraper.parsedMaps.should.have.property 'meaningComment'
      res = parseMapScraper.parsedMaps.meaningComment
      res.length.should.equal 3
      res[1].should.equal 'meaning_of_life'
      res[2].should.equal '42'

  describe '#loadHtml', ()->
    loadHtmlHtml = '<div>Rxexmxoxvxex</div>'
    loadTestScraper = new Extrae.Scraper()
    it '''should generate cheerio object and set it to the class,
          also return it''', () ->
      $ = loadTestScraper.loadHtml(loadHtmlHtml)
      $.should.equal loadTestScraper.$
      # no way to test if it was parsed correctly, this is cheerio tests
      #territory
  describe '#extractData', ()->
    it 'should throw exception if no html parsed', () ->
      fn = ()->
        testScraper.extractData()
      (fn).should.throw(Error)
    it 'should return an instance of @returnClass if parsed', () ->
      testScraper.loadHtml extractHtml
      ret = testScraper.extractData()
      ret.should.be.an.instanceof TestModel
      (ret.get 'name').should.equal 'Alice'
  describe '#scrape', ()->
    it 'should do same as extract data in one call', () ->
      ret = testScraper.scrape extractHtml
      ret.should.be.an.instanceof TestModel
      (ret.get 'name').should.equal 'Alice'

  describe 'UrlScraper', (done)->
    urlScraper = new Extrae.UrlScraper \
                   serverUrl,
                   '#movies .movie',  # base selector for the items
                   h.MovieCollection  # collection for the results

    it 'should scrape the url if exists', (done) ->
      urlScraper.scrape (err, response, collection)->
        (!err).should.equal true
        collection.should.be.an.instanceof h.MovieCollection
        collection.length.should.equal 2
        m = collection.at(0)
        (m.get 'title').should.equal h.MOVIE_DATA[0].title
        done()

    it 'should throw error if status code is not for success', (done) ->
      urlScraper.scrape ((err, response, collection, errDescription)->
        (!!err).should.equal true
        done())
        , serverUrl + 'error/'
    it 'should throw error if there is any request error', (done) ->
      # this will fail as unknown protocol
      urlScraper.scrape ((err, response, collection, errDescription)->
        (!!err).should.equal true
        done())
        , 'xyz://example.com'