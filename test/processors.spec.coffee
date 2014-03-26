chai = require "chai"
Extrae = require "../src"
should = chai.should()
cheerio = require 'cheerio'

describe 'Processors.StringProcessors', ()->
  describe 'TRIM_STRING', ()->
    TRIM_STRING = Extrae.Processors.StringProcessors.TRIM_STRING
    it 'should trim forward spaces', ()->
      TRIM_STRING(' a').should.equal 'a'
      TRIM_STRING('\ta').should.equal 'a'
      TRIM_STRING('\na').should.equal 'a'
      TRIM_STRING('  a').should.equal 'a'
      TRIM_STRING('\n\na').should.equal 'a'
      TRIM_STRING('\n\t a').should.equal 'a'
    it 'should trim backward spaces', ()->
      TRIM_STRING('a ').should.equal 'a'
      TRIM_STRING('a\t').should.equal 'a'
      TRIM_STRING('a\n').should.equal 'a'
      TRIM_STRING('a  ').should.equal 'a'
      TRIM_STRING('a\n\n').should.equal 'a'
      TRIM_STRING('a\n\t ').should.equal 'a'
    it 'should trim forward and backward spaces', ()->
      TRIM_STRING('  a ').should.equal 'a'
      TRIM_STRING('\ta\t').should.equal 'a'
      TRIM_STRING('\na\n').should.equal 'a'
      TRIM_STRING('  a  ').should.equal 'a'
      TRIM_STRING('a\n\n').should.equal 'a'
      TRIM_STRING('\n\t a\n\t ').should.equal 'a'
    it 'should not remove spaces in the middle of the string', ()->
      TRIM_STRING(' a b ').should.equal 'a b'
      TRIM_STRING('a\nb ').should.equal 'a\nb'
      TRIM_STRING('a\tb ').should.equal 'a\tb'

describe 'Processors.NodeProcessors', ()->
  href = '#one'
  title = 'title'
  aId = 'a_id'
  miscValue = 'misc_value'
  content = 'link text'
  imgSrc = 'http://placekitten.com/200/300'
  aHtml = """<a href="#{href}" title="#{title}"
              id="#{aId}"
              data-misc=" #{miscValue} "> #{content} </a>"""

  html = """<div>#{aHtml}</div><img src="#{imgSrc}"> """
  px = Extrae.Processors.NodeProcessors
  $ = cheerio.load html
  aEl = $('a')
  imgEl = $('img')
  divEl = $('div')

  describe 'EXTRACT_ATTR', () ->
    it 'should extract the content of a node attribute trimmed', ()->
      ret = px.EXTRACT_ATTR('data-misc')(aEl)
      ret.should.equal miscValue
    it 'should return null if attribute does not exist', ()->
      ret = px.EXTRACT_ATTR('src')(aEl)
      (ret is null).should.equal true

  describe 'EXTRACT_TITLE_ATTR', () ->
    ret = px.EXTRACT_TITLE_ATTR(aEl)
    it 'should extract the title attribute trimmed', ()->
      ret.should.equal title
  describe 'EXTRACT_HREF_ATTR', () ->
    ret = px.EXTRACT_HREF_ATTR(aEl)
    it 'should extract the href attribute trimmed', ()->
      ret.should.equal href
  describe 'EXTRACT_SRC_ATTR', () ->
    ret = px.EXTRACT_SRC_ATTR(imgEl)
    it 'should extract the src attribute trimmed', ()->
      ret.should.equal imgSrc
  describe 'EXTRACT_ID_ATTR', () ->
    ret = px.EXTRACT_ID_ATTR(aEl)
    it 'should extract the id attribute trimmed', ()->
      ret.should.equal aId
  describe 'EXTRACT_TEXT', () ->
    ret = px.EXTRACT_TEXT(aEl)
    it 'should extract the element text trimmed', ()->
      ret.should.equal content
  describe 'EXTRACT_HTML', () ->
    ret = px.EXTRACT_HTML(divEl)
    it 'should extract the html for the elemnt element trimmed', ()->
      aHtmlClean = (aHtml.replace /[\n\t]/g, ' ').replace /\s\s+/, ' '
      ret.should.equal aHtmlClean
