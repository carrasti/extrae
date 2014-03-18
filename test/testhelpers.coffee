Extrae = require "../src"

class MovieModel extends Extrae.Model
MovieModel
    .addFieldDefinition 'title', new Extrae.Fields.StringField
    .addFieldDefinition 'year',  new Extrae.Fields.NumberField
    .addExtractRule 'title', new Extrae.ExtractRule '.title', ($) -> $.text()
    .addExtractRule 'year' , new Extrae.ExtractRule '.year', ($) ->  parseInt $.text(), 10


class PersonModel extends Extrae.Model
PersonModel
    .addFieldDefinition 'name', new Extrae.Fields.StringField
    .addExtractRule 'name', (new Extrae.ExtractRule '.name', ($) -> $.text())

class PersonCollection extends Extrae.Collection
    model: PersonModel

class MovieWithNestedActors extends MovieModel
MovieWithNestedActors.addFieldDefinition \
                        'actors',
                        new Extrae.Fields.CollectionField '.actors .actor',
                        PersonCollection

class MovieWithNestedDirector extends MovieModel
MovieWithNestedDirector.addFieldDefinition \
                        'director',
                        new Extrae.Fields.ModelField '.director',
                        PersonModel

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
