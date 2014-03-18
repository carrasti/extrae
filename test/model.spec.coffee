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

describe 'Model', ()->

    describe '#setFieldDefinitionsFromList', ()->
        class ExtendedMovieModel extends MovieModel
        ExtendedMovieModel
          .addFieldDefinition 'runtime', new Extrae.Fields.NumberField

        it 'should keep the superclass prototype methods unmodified', ()->
          Object.keys(MovieModel::fieldDefinitions).length.should.equal 2
          Object.keys(ExtendedMovieModel::fieldDefinitions)\
                                                   .length.should.equal 3
          ExtendedMovieModel::fieldDefinitions.should.not
                                  .equal MovieModel::fieldDefinitions
          ExtendedMovieModel::fieldDefinitions.should.not
                                  .deep.equal MovieModel::fieldDefinitions
        it 'should add field to subclass', ()->
          ExtendedMovieModel::fieldDefinitions.should.have.property 'runtime'
          MovieModel::fieldDefinitions.should.not.have.property 'runtime'

    describe '#setExtractRulesMap', ()->
        class ExtendedMovieModel extends MovieModel
        ExtendedMovieModel
            .addExtractRule 'runtime', new Extrae.ExtractRule null, null

        it 'should keep the superclass prototype methods unmodified', ()->
          Object.keys(MovieModel::extractRules).length.should.equal 2
          Object.keys(ExtendedMovieModel::extractRules).length.should.equal 3
          ExtendedMovieModel::extractRules.should.not
                                  .equal MovieModel::extractRules
          ExtendedMovieModel::extractRules.should.not
                                  .deep.equal MovieModel::extractRules
        it 'should add extract rule only to subclass', ()->
          ExtendedMovieModel::extractRules.should.have.property 'runtime'
          MovieModel::extractRules.should.not.have.property 'runtime'

    describe '#toJSON()', ()->
        movie1 = new MovieModel {
          'title': movieData[0].title
          'year':movieData[0].year
        }

        nestedCol = new PersonCollection [{name:"nested1"}, {name:"nested2"}]
        nestedModel = new PersonModel {'name': "nested3"}
        movie2 = new MovieWithNestedActors {
          'title': movieData[1].title
          'year': movieData[1].year
          'actors': nestedCol
        }
        movie3 = new MovieWithNestedDirector {
          'title': movieData[1].title
          'year': movieData[1].year
          'director': nestedModel
        }

        it 'should serialize nested collections', ()->
          jsonData = movie2.toJSON()
          jsonData.should.have.property 'actors'
          jsonData.actors.should.be.a 'array'
          jsonData.actors.should.deep.equal nestedCol.toJSON()

        it 'should serialize nested models', ()->
          jsonData = movie3.toJSON()
          jsonData.should.have.property 'director'
          jsonData.director.should.be.a 'object'
          jsonData.director.should.deep.equal nestedModel.toJSON()

    describe '#extractData', ()->
        singleMovieScraper = new Extrae.Scraper '#movies .movie', MovieModel
        singleMovieScraper.loadHtml(html)

        it 'it should extract direct properties', ()->
            $rootEl = (singleMovieScraper.$ singleMovieScraper.baseSelector).first()
            model = new MovieModel {}
            model.extractData singleMovieScraper, $rootEl, null
            json = model.toJSON()
            json.should.have.property 'title'
            json.should.have.property 'year'
            json.title.should.equal movieData[0].title
            json.year.should.equal movieData[0].year

        it 'should extract nested collections', ()->
            $rootEl = (singleMovieScraper.$ singleMovieScraper.baseSelector).first()
            model = new MovieWithNestedActors {}
            model.extractData singleMovieScraper, $rootEl, null
            json = model.toJSON()
            json.should.have.property 'actors'
            json.actors.should.be.a 'array'
            json.actors.should.have.length 2
            json.actors[0].should.have.property 'name'
            json.actors[0].name.should.equal movieData[0].actors[0]
            json.actors[1].name.should.equal movieData[0].actors[1]

        it 'should extract nested models', ()->
            $rootEl = (singleMovieScraper.$ singleMovieScraper.baseSelector).eq(1)
            model = new MovieWithNestedDirector {}
            model.extractData singleMovieScraper, $rootEl, null
            json = model.toJSON()
            json.should.have.property 'director'
            json.director.should.be.a 'object'
            json.director.should.have.property 'name'
            json.director.name.should.equal movieData[1].director

        it 'should not extract anything if no ExtractRule for field', ()->
            class ExtendedMovieModel extends MovieModel
            ExtendedMovieModel
              .addFieldDefinition 'norulefield', new Extrae.Fields.Field

            $rootEl = (singleMovieScraper.$ singleMovieScraper.baseSelector).first()
            model = new ExtendedMovieModel {}
            model.extractData singleMovieScraper, $rootEl, null
            json = model.toJSON()
            json.should.have.property 'norulefield'
            (json.norulefield is null).should.equal true

