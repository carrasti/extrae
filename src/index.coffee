Model = require './model'
Collection = require './collection'
Scraper = require './scraper'
Processors = require './processors'
Fields = require './fields'
ExtractRule = require './extract_rule'

Extrae = 
	Model: Model
	Collection: Collection
	Scraper: Scraper.Scraper
	UrlScraper: Scraper.UrlScraper
	Processors: Processors
	Fields: Fields
	ExtractRule: ExtractRule

module.exports = Extrae