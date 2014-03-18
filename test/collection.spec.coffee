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

describe 'Collection', ()->
    class MovieCollection extends Extrae.Collection
      model: MovieModel

    moviesScraper = new Extrae.Scraper '#movies .movie', MovieCollection
    moviesScraper.loadHtml(html)

    describe '#validateItem', ()->
        it 'should not filter anything if no validateItem', ()->
            col = new MovieCollection
            col.extractData moviesScraper,
                            (moviesScraper.$ moviesScraper.baseSelector)
            json = col.toJSON()
            json.length.should.equal 2

        it 'should filter if validateItem provided', ()->
            class FilteredMovieCollection extends MovieCollection
                validateItem: ($) ->
                    # return only movies from the 90s onwards
                    return (parseInt $.find('.year').text(), 10) >= 1990

            col = new FilteredMovieCollection
            col.extractData moviesScraper,
                            (moviesScraper.$ moviesScraper.baseSelector)
            json = col.toJSON()
            json.length.should.equal 1
            json[0].year.should.be.at.least 1990

    describe '#extractData', ()->

        it 'should extract items', ()->
            col = new MovieCollection
            col.extractData moviesScraper,
                            (moviesScraper.$ moviesScraper.baseSelector)
            json = col.toJSON()
            json.length.should.equal 2
            json[0].should.have.property 'year'
            json[0].should.have.property 'title'
            json[1].should.have.property 'year'
            json[1].should.have.property 'title'
            json[0].year.should.equal movieData[0].year
            json[0].title.should.equal movieData[0].title
            json[1].year.should.equal movieData[1].year
            json[1].title.should.equal movieData[1].title

