



exec = require("child_process").exec
assert = require 'assert'
async = require 'async'
request = require 'request'
sugar = require 'sugar'
path = require 'path'

debugn4store = false

describe 'N4Store', () ->


  dbName = "n4storeTestDb"
  #endPoint 
  port = 10000
  endPoint = "http://0.0.0.0:#{port}"

  n4store = null



  # setup and start backend and 4store http server 
  launchDb = (callback) ->
    async.series [
      (callback) ->
        exec "4s-backend-setup #{dbName}", (err) ->
          console.log "4s-backend-setup ", err if err
          callback null
      (callback) ->
        exec "4s-backend #{dbName}", (err) ->
          console.log "4s-backend", err if err
          callback null
      (callback) ->
        exec "4s-httpd -p #{port} #{dbName}", (err) ->
          console.log "4s-httpd", err if err
          callback null
    ]
    , () ->
      callback null



  # kill all 4s-backend and 4shttpd processes
  kill4sProcesses = (callback) ->
    async.series [
      
      # kill processes
      (callback) ->
        exec "pkill -f '^4s-backend #{dbName}$'", (err, body) ->
          # console.log "kill 4s-backend", err if err
          callback null
      (callback) ->
        exec "killall 4s-httpd", (err, body) ->
          # console.log "killall 4s-httpd", err if err
          callback null
    ]
    , () ->
      callback()


  # destroy the 4store db
  destroyDb = (callback) ->
    exec "4s-backend-destroy #{dbName}", (err) ->
      callback()



  # kill4sProcesses and launchDb
  resetDb = (callback) ->
    async.series [
      (callback) ->
        kill4sProcesses callback
      (callback) ->
        launchDb callback
    ], 
    () ->
      # create the 4store client
      n4store = require('../').createClient endPoint, null, debugn4store
      callback()
    

  # fixtures vars
  graph = 'urn:graph'

  triple = 
    subject: "urn:resource"
    predicate: "urn:predicate"
    object: "literal"

  turtleData = """
    <#{triple.subject}> <#{triple.predicate}> <#{triple.object}> .
    <#{triple.subject}> <#{triple.predicate}> <#{triple.object}> .
    <#{triple.subject}> <#{triple.predicate}> "literal 2" .
  """

  turtleFiles = [
    "#{__dirname}/fixtures/turtleData2.ttl"
    "#{__dirname}/fixtures/turtleData3.ttl"
  ]
  
  turtleFile = "#{__dirname}/fixtures/turtleData.ttl"
  turtleFilename = path.basename turtleFile 



  # done after mocha tests
  after (done) ->
    destroyDb done



  # assert that the number of triples is equal to n and return triples
  getNTriples = (n, callback) ->   
    n4store.get """
      SELECT ?s ?p ?o ?g
      WHERE {
        GRAPH ?g {
        ?s ?p ?o
        }
      }
    """, (err, sparql) ->
      assert.equal n, sparql.results.bindings.length 
      callback sparql.results.bindings



  # N4Store tests
  describe "Connection", () ->

    it "server must be starts on port #{port} ", (done) ->
      resetDb () ->
        request 
          method: "GET"
          url: "#{endPoint}/status"
        , (err, res, body) ->
          done(err) if err
          assert.equal true, (body.indexOf("Total # triples imported: 0") > -1)
          done()



  describe "SPARQL", () ->

    it "sparql get request should return 0 results", (done) ->
      getNTriples 0, (triples) ->
        done()

    it "should insert one triple and get 1 result", (done) ->
        n4store.post """
          INSERT {
            GRAPH <#{graph}> {
              <#{triple.subject}> <#{triple.predicate}> "#{triple.object}"
            }
          }
        """
        , (err, body) ->
          assert.equal err, null
          done err

    it "should get the same graph, subject, predicate and object in sparql get", (done) ->
      getNTriples 1, (triples) ->
        assert.equal triple.subject, triples[0].s.value 
        assert.equal triple.predicate, triples[0].p.value 
        assert.equal triple.object, triples[0].o.value 
        assert.equal graph, triples[0].g.value 
        done()

    it "should delete the triple based on subject", (done) ->
      n4store.post """
        DELETE {
          <#{triple.subject}> ?p ?o 
        } WHERE {
          <#{triple.subject}> ?p ?o 
        }
      """, (err, body) ->
        assert.equal null, err
        done err

    it "store should be empty", (done) ->
      getNTriples 0, (triples) ->
        done()



  describe "POST data (append data to a graph)", () ->


    describe "use postData", () ->

      it "should post turtle data (3 triples but 2 identical)", (done) ->
        n4store.postData turtleData, graph, (err, body) ->
          assert.equal null, err
          assert.equal true, (body.indexOf("200") > -1)
          done()
        , 'turtle'

      it "should get 2 result (4store compiled with --enable-dedup-insert) and 1 must have object as 'literal 2'", (done) ->
        getNTriples 2, (triples) ->
          assert.equal true, triples.any (triple) ->
            triple.o.value is "literal 2"
          done()


    describe "use postFile", () ->

      it "should append turtle data from file #{turtleFile}", (done) ->
        n4store.postFile turtleFile, null, (err) ->
          assert.equal null, err
          done()

      it "should contains 2 graphs", (done) ->
        n4store.getGraphs (err, uris) ->
          assert.equal 2, uris.length
          done()

      it "should contain one graph with #{turtleFilename}", (done) ->
        n4store.getGraphs (err, uris) ->
          assert.equal true, uris.any (uri) ->
            uri is "urn:#{turtleFilename}"
          done()


    describe "use postFiles", () ->

      it "should append two more files ", (done) ->
        n4store.postFiles turtleFiles, graph, (err) ->
          assert.equal null, err
          done err
        , 'turtle'

      it "should have 2 graph only", (done) ->
        n4store.getGraphs (err, uris) ->
          assert.equal 2, uris.length
          done()

      it "graph #{graph} must contains 5 triples", (done) ->
        getNTriples 7, (triples) ->
          done()



  describe "PUT data (replace data in a graph)", () ->


    describe "use put", () ->
      
      it "should replace data in graph #{graph}", (done) ->
        n4store.put """
          <#{triple.subject}> <#{triple.predicate}> <#{triple.object}> .
        """
        , graph
        , (err, body) ->
          assert.equal null, err
          assert.equal true, body.indexOf('201') > -1
          done()

      it "store should contains only 2 triples", (done) ->
        getNTriples 2, (triples) ->
          done()

      it "should replace data in urn:#{turtleFilename} graph", (done) ->
        n4store.put """
          <#{triple.subject}> <#{triple.predicate}> <#{triple.object}> .
        """
        , "urn:#{turtleFilename}"
        , (err, body) ->
          assert.equal null, err
          assert.equal true, body.indexOf('201') > -1
          done()

      it "store should contains only 2 triples", (done) ->
        getNTriples 2, (triples) ->
          done()

      it "should have two identical triples in two diffrent graph", (done) ->
        getNTriples 2, (triples) ->
          triple1 = triples[0]
          triple2 = triples[1]
          assert.equal true, triple1.s.value is triple2.s.value
          assert.equal true, triple1.p.value is triple2.p.value
          assert.equal true, triple1.o.value is triple2.o.value
          done()


    describe "use putFile", ()->

      it "should put file #{turtleFilename} in graph #{graph}", (done) ->
        n4store.putFile turtleFile, graph, (err, body) ->
          assert.equal null, err
          assert.equal true, body.indexOf('201') > -1
          done()

      it "should contain on one triple in graph #{graph}", (done) ->
        n4store.get """
          SELECT ?s ?p ?o 
          WHERE {
            GRAPH <#{graph}> {
              ?s ?p ?o
            }
          }
        """
        , (err, sparql) ->
          assert.equal true, sparql.results.bindings.length is 1
          triple = sparql.results.bindings.first()
          assert.equal "urn:resource2", triple.s.value
          assert.equal "urn:predicate", triple.p.value
          assert.equal "literal", triple.o.value
          done()


    describe "use putFiles", () ->

      it "should put files #{turtleFiles} in their own graph names", (done) ->
        n4store.putFiles turtleFiles, null, (err, body) ->
          done()

      it "should have 4 graph names ", (done) ->
        n4store.getGraphs (err, uris) ->
          assert.equal 4, uris.length
          done()



  describe "CONSTRUCT", () ->

    it "should return a construct turtle", (done) ->
      n4store.construct """
        CONSTRUCT {
          ?s ?p ?o 
        }
        WHERE {
          ?s ?p ?o
        }
      """
      , (err, turtle) ->
        assert.equal null, err
        assert.equal true, turtle.length > 0
        done()



  describe "DELETE graph", () ->

    it "should delete graph #{graph}", (done) ->
      n4store.delete graph, (err, body) ->
        assert.equal null, err
        assert.equal true, (body.indexOf("200") > -1)
        done()


