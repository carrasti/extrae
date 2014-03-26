
# @nodoc
TRIM_STRING = (str) ->
  if str then str.replace /^(\s|\r\n)+|(\s|\r\n)+$/g, '' else null

# @nodoc
EXTRACT_ATTR = (attr) ->
  ($) ->
    TRIM_STRING $.attr attr

###
General purpose class with facilities to extract data

###
class Processors
  # Replacements are just arrays of [regex, string] expressing a regular
  #  expression and the replacement to make
  @Replacements:
    REMOVE_NEWLINES: [/\r\n/g, '']
    REMOVE_DOUBLE_SPACES: [/\s+/g, ' ']
    REMOVE_UNUSED_SPACES_LEFT: [/>\s/g, '>']
    REMOVE_UNUSED_SPACES_RIGHT: [/<\s/g, '<']
  # preprocessors are lists of replacements
  @Preprocessors:
    FLATTEN : [
      Processors.Replacements.REMOVE_NEWLINES
      Processors.Replacements.REMOVE_DOUBLE_SPACES
      Processors.Replacements.REMOVE_UNUSED_SPACES_LEFT,
      Processors.Replacements.REMOVE_UNUSED_SPACES_RIGHT
    ]

  # string processors are functions applied to a string
  @StringProcessors:
    TRIM_STRING: TRIM_STRING
  # processors over a (Cheerio) selector
  @NodeProcessors:
    EXTRACT_ATTR: EXTRACT_ATTR
    EXTRACT_TITLE_ATTR: ($) ->
      (EXTRACT_ATTR 'title') $
    EXTRACT_HREF_ATTR: ($) ->
      (EXTRACT_ATTR 'href') $
    EXTRACT_SRC_ATTR: ($) ->
      (EXTRACT_ATTR 'src') $
    EXTRACT_ID_ATTR: ($) ->
      (EXTRACT_ATTR 'id') $
    EXTRACT_TEXT: ($) ->
      TRIM_STRING $.text()
    EXTRACT_HTML: ($) ->
      TRIM_STRING $.html()


module.exports = Processors
