chai = require "chai"
Extrae = require "../src"
should = chai.should()

describe 'Model', ()->
    class MockModel extends Extrae.Model
        fieldDefinitions:
            'name' : new Extrae.Fields.StringField 'name'

    class MockCollection extends Extrae.Collection
        model: MockModel

    class MovieModel extends Extrae.Model
        fieldDefinitions:
            'title' : new Extrae.Fields.StringField 'title'
            'year'  : new Extrae.Fields.NumberField 'year'

    class ModelWithNestedCollection extends MovieModel
    ModelWithNestedCollection::fieldDefinitions.nested = \
              new Extrae.Fields.CollectionField 'nested', null, MockCollection

    class ModelWithNestedModel extends MovieModel
    ModelWithNestedModel::fieldDefinitions.nested = \
              new Extrae.Fields.ModelField 'nested', null, MockModel

    describe '#toJSON()', ()->
        movie1 = new MovieModel {
          'title':'The Terminator'
          'year':1984
        }
        nestedCol = new MockCollection [{name:"nested1"}, {name:"nested2"}]
        nestedModel = new MockModel {'name': "nested3"}
        movie2 = new ModelWithNestedCollection {
          'title':'Terminator 2: Judgment Day'
          'year':1991,
          'nested': nestedCol
        }
        movie3 = new ModelWithNestedModel {
          'title':'Terminator 2: Judgment Day'
          'year':1991,
          'nested': nestedModel
        }

        it 'should serialize nested collections', ()->
          jsonData = movie2.toJSON()
          jsonData.should.have.property 'nested'
          jsonData.nested.should.be.a 'array'
          jsonData.nested.should.deep.equal nestedCol.toJSON()

        it 'should serialize nested models', ()->
          jsonData = movie3.toJSON()
          jsonData.should.have.property 'nested'
          jsonData.nested.should.be.a 'object'
          jsonData.nested.should.deep.equal nestedModel.toJSON()
