 







# •••  REQUIRES                                
# •••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••

request = require 'request'
async   = require 'async'
fs      = require 'fs'
path    = require 'path'
exec = require('child_process').exec
 







# •••  create a N4STORE CLIENT   
# •••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••

exports.createClient = (endPoint, prefixes, debug) ->
  console.log 'create client'
  new N4Store endPoint, prefixes, debug
 







# •••  N4STORE CLIENT   
# •••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••

class N4Store 






  prefixes: 
    'rdf':          'http://www.w3.org/1999/02/22-rdf-syntax-ns#'
    'rdfs':         'http://www.w3.org/2000/01/rdf-schema#'
    'dc':           'http://purl.org/dc/terms/'
    'dc11':         'http://purl.org/dc/elements/1.1/'
    'skos':         'http://www.w3.org/2004/02/skos/core#'
    'geonames':     'http://www.geonames.org/ontology#'
    'wgs84_pos':    'http://www.w3.org/2003/01/geo/wgs84_pos#'
    'dbpedia-owl':  'http://dbpedia.org/ontology/'
    'foaf':         'http://xmlns.com/foaf/0.1/'
    'owl':          'http://www.w3.org/2002/07/owl#'
    'schema':       'http://schema.org/'






  constructor: (endPoint, prefixes = {}, @debug = false) ->

    # 4store uri's
    @sparqlUri = "#{endPoint}/sparql/"
    @updateUri = "#{endPoint}/update/"
    @dataUri   = "#{endPoint}/data/"

    console.log prefixes
    # extend prefixes
    for prefix, uri of prefixes 
      @setPrefix[prefix] = uri

    # set turtle prefix string
    @setPrefixesStr()






  # logs function if debug 

  log: (str) ->
    console.log str if @debug 

  time: (str) ->
    console.time str if @debug

  timeEnd: (str) ->
    console.timeEnd str if @debug






  # add a prefix to @prefixes

  setPrefix: (prefix, uri) ->
    console.log prefix, uri
    @prefixes[prefix] = uri
    @setPrefixesStr()






  # return all the prefixes contains in @prefixes array
  # as a sparql string of prefixes

  setPrefixesStr: ->
    @prefixesStr = ''
    for k, v of @prefixes
      @prefixesStr += "PREFIX #{k}: <#{v}> \n"






  # return an encoded sparql query with the prefixes added

  encodeQuery: (query) ->
    encodeURIComponent "#{@prefixesStr}\n #{query}"






  # •••  SPARQL GET QUERY •••

  get: (query, callback) ->

    @log query
    @time 'sparql query took: '

    request.get
      uri: "#{@sparqlUri}?query=#{@encodeQuery(query)}&soft-limit=0"
      headers: 
        "Accept": "application/sparql-results+json"
      ,
      (err, res, body) =>
        @log err if err
        @timeEnd 'sparql query took: '
        callback err, if body then JSON.parse(body) else null






  # ••• SPARQL POST QUERY  •••

  post: (query, callback) ->

    @log query
    @time "post took: "
    request.post
      uri: @updateUri
      body: "update=#{@encodeQuery(query)}"
      headers: 
        'Content-Type': 'application/x-www-form-urlencoded'
    ,
    (err, res, body) =>
      @log err if err
      @timeEnd "post took: "
      callback err, body






  # ••• CONSTRUCT QUERY •••

  construct: (query, callback) ->
    uri = "#{@sparqlUri}?query=#{@encodeQuery(query)}"

    @log query
    @time 'construct query took:'
    
    exec "rapper -i rdfxml -o turtle #{uri}", (err, data) =>
      @log err if err
      @timeEnd 'construct query took:'
      callback err, data





  # ••• ASK •••

  ask: (query, callback) ->

    @get query
    , (err, sparql) =>
      @log err if err
      callback err, sparql.boolean






  # ••• DELETE •••

  delete: (graph, callback) ->

    @time "deleting graph #{graph} took: "

    request.del
      uri: @dataUri + graph
    , 
    (err, res, body) =>
      @log err if err
      @timeEnd "deleting graph #{graph} took: "
      callback err, body






  # ••• PUT: REPLACE DATA IN A GRAPH •••

  put: (data, graph, callback, format="application/x-turtle") ->

    @time "put in #{graph} took: "

    request.put
      uri: @dataUri + graph
      body: data
      headers: 
        'Content-Type': if format then format else 'application/rdf+xml'
      , 
      (err, res, body) =>
        @log err if err
        @timeEnd "put in #{graph} took: "
        callback err, body






  # ••• PUT FILE IN GRAPH •••

  putFile: (file, graph, callback, format) ->
    fs.readFile file, (err, data) =>
      @log err if err
      graph = graph ? "urn:#{path.basename(file)}"
      @put data, graph, callback, format






  # ••• PUT FILES •••

  putFiles: (files, graph, callback, format) ->
    async.forEachSeries files, (file, callback) =>
      graph = graph ? "urn:#{path.basename(file)}"
      @putFile file, graph, callback, 
      graph = null
    , 
    (err) ->
      callback err






  # ••• POST DATA: Append data to a graph •••

  postData: (data, graph, callback, format="turtle") ->

    @time "post data in graph #{graph} took: "
    request.post
        uri: @dataUri
        body: "graph=#{encodeURIComponent(graph)}&data=#{encodeURIComponent(data)}#{ if format then ("&mime-type="+format) else "" }"
        headers: 
          'Content-Type': 'application/x-www-form-urlencoded'
      , 
      (err, res, body) =>
        @log err if err
        @timeEnd "post data in graph #{graph} took: "
        callback(err, body)






  # ••• POST FILE •••

  postFile: (file, graph, callback, format) ->
    fs.readFile file, (err, data) =>
      if err 
        @log err
        callback err
      else 
        graph = graph ? "urn:#{path.basename(file)}"
        @postData data, graph, callback, format






  # ••• POST FILES •••

  postFiles: (files, graph, callback, format) ->
    async.forEachSeries files, (file, callback) =>
      graph = graph ? "urn:#{path.basename(file)}"
      @postFile file, graph, callback, format
    , (err) =>
      @log err if err
      callback err




 







  # •••  HELPERS   
  # •••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••


  # ••• GET ALL GRAPH URIS •••
  # void -> error, array
  # return an array of graph uris 

  _getValues: (query, property, callback) ->
    @get query, (err, sparql) ->
      uris = for result in sparql?.results?.bindings 
        result[property].value
      callback err, uris
      
  getGraphs: (callback) ->
    @_getValues """
      SELECT DISTINCT ?g 
      WHERE { 
        GRAPH ?g { 
          ?s ?p ?o 
        } 
      } 
    """
    , 'g', callback

  getTypes: (callback) ->
    @_getValues """
      SELECT DISTINCT ?type 
      WHERE { 
        ?s rdf:type ?type 
      }
    """
    , 'type', callback












# unless module.parent

#   n4store = exports.createClient('http://0.0.0.0:8003', null, true)

#   n4store.getTypes (err, uris) ->
#     console.log uris