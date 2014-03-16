# No API? No problem! #

Extrae is a framework to allow you easily extract data from web pages in a
structured manner.

It is written in **CoffeeScript** and uses [Backbone.js](http://backbonejs.org/)
to define classes and models for the data extracted,
[cheerio](https://github.com/MatthewMueller/cheerio) to provide jQuery-like node
selecting API over HTML and [request](https://github.com/mikeal/request) to
fetch HTML from the Internet.

## A simple example ##

You have some HTML you want to extract movies from. The HTML looks like this:

```coffee-script
html = """
<html><body>
    <ul id="movies">
        <li class="movie">
            <span class="title">The Terminator</span>
            <span class="year">1984</span>
        </li>
        <li class="movie">
            <span class="title">Terminator 2: Judgment Day</span>
            <span class="year">1991</span>
        </li>
    </ul>
</body></html>
"""
```

Let's extract all the movies and for each movie their title and year. The
collection of nodes for each movie can be extracted with the string selector
`#movies .movie`, then each element matched will be used as base to find the
title via the selector `.title` and year with `.year`.

You can define a **model** for each movie and the attributes to extract:

```coffee-script
Extrae = require "extrae"

class MovieModel extends Extrae.Model
MovieModel.fieldDefinitions =
    'title' : new Extrae.Fields.StringField 'title'
    'year'  : new Extrae.Fields.NumberField 'year'
```

And then the **rules** to extract every field. Rules consist on a
[string selector](https://github.com/MatthewMueller/cheerio#selectors) and a
function to extract the data. Extractor functions receive as parameter the
element(s) matched by the selector so you can use the cheerio API to extract
data.

```coffee-script
MovieModel.extractRules =
    'title' : new Extrae.ExtractRule '.title',
                                     ($) ->
                                        $.text()
    'year'  : new Extrae.ExtractRule '.name',
                                        paseInt $.text(), 10
```

Next define a **collection** for the movies and set as its model the
`MovieModel` written in the previous step:

```coffee-script
class MovieCollection extends Extrae.Collection
    model = MovieModel
```

All ready in our data layer, let's create a **scraper** to extract the data:

```coffee-script
scraper = new Extrae.Scraper \
                # base selector for the movie items for the collection
                '#movies .movie',
                # model or collection to extract the data and be returned
                MovieCollection
```

Now let's work the magic:

```coffee-script

# scraper.scrape will return a MovieCollection instance with the
# extracted data
extractedCollection = scraper.scrape html

# using Backbone.js toJSON method for the collection we can get all the data
# as a POJO (Plain Old Javascript Object)
extractedCollection.toJSON()

# [
#     { "title" : "The Terminator", "year" : 1984 },
#     { "title" : "Terminator 2: Judgment Day", "year" : 1991 }
# ]

# Use the data extracted wisely.
```

If the resource containing the HTML to parse is anywhere on the Internet, use
the `UrlScraper` class. The constructor is slightly different and results are
provided in a callback as fetching the data is asynchronous. See the example:

```coffee-script
scraper = new Extrae.UrlScraper \
                'http://example.com/movies.html',  # url for the resource
                '#movies .movie',  # base selector for the items
                MovieCollection  # model or collection for the results

# the UrlScrapper is asynchronous so data is handled in a callback
callback = (err, response, collection)->
    console.log collection.toJSON()

# scrape!
scraper.scrape callback
```
