Extrae = require "../src"

class MovieModel extends Extrae.Model
MovieModel.setFieldDefinitionsFromList [
        new Extrae.Fields.StringField 'title'
        new Extrae.Fields.NumberField 'year'
]
MovieModel.setExtractRulesMap {
        'title' : new Extrae.ExtractRule '.title', ($) -> $.text()
        'year'  : new Extrae.ExtractRule '.year', ($) ->  parseInt $.text(), 10
}

class PersonModel extends Extrae.Model
PersonModel.setFieldDefinitionsFromList [
    new Extrae.Fields.StringField 'name'
]
PersonModel.setExtractRulesMap {
      'name' : new Extrae.ExtractRule '.name', ($) -> $.text()
}

class PersonCollection extends Extrae.Collection
    model: PersonModel

class MovieWithNestedActors extends MovieModel
MovieWithNestedActors.setFieldDefinitionsFromList [
    new Extrae.Fields.CollectionField 'actors',
                                      '.actors .actor',
                                      PersonCollection
]

class MovieWithNestedDirector extends MovieModel
MovieWithNestedDirector.setFieldDefinitionsFromList [
    new Extrae.Fields.ModelField 'director', '.director', PersonModel
]

movieData = [{
  title: 'The Terminator'
  year: 1984
  actors: [
    'Arnold Schwarzenegger'
    'Linda Hamilton'
  ]},{
  title: 'Terminator 2: Judgment Day'
  year: 1991
  director: 'James Cameron'
}]

html = """
<html><body>
    <ul id="movies">
        <li class="movie">
            <span class="title">#{movieData[0].title}</span>
            <span class="year">#{movieData[0].year}</span>
            <ul class="actors">
              <li class="actor">
                <span class="name">#{movieData[0].actors[0]}</span>
              </li>
              <li class="actor">
                <span class="name">#{movieData[0].actors[1]}</span>
              </li>
            </ul>
        </li>
        <li class="movie">
            <span class="title">#{movieData[1].title}</span>
            <span class="year">#{movieData[1].year}</span>
            <span class="director">
              <span class="name">#{movieData[1].director}</span>
            </span>
        </li>
    </ul>
</body></html>
"""

exports.MovieModel = MovieModel
exports.PersonModel = PersonModel
exports.PersonCollection = PersonCollection
exports.MovieWithNestedActors = MovieWithNestedActors
exports.MovieWithNestedDirector = MovieWithNestedDirector
exports.MOVIE_DATA = movieData
exports.HTML = html

