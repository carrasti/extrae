Model = require './model'
Collection = require './collection'
Scraper = require './scraper'
Processors = require './processors'
Fields = require './fields'
ExtractRule = require './extract_rule'
Server = require './server'
SiteAPI = require './site_api'

Extrae =
  Model: Model
  Collection: Collection
  Scraper: Scraper.Scraper
  UrlScraper: Scraper.UrlScraper
  UrlScraperWithParams: Scraper.UrlScraperWithParams
  Processors: Processors
  Fields: Fields
  ExtractRule: ExtractRule
  Server: Server
  SiteAPI: SiteAPI

module.exports = Extrae
