


# n4store

n4store is a simple http client for 4store

# Installation 

    $ npm install n4store

# Usage 

Create a 4store kb 

    $ 4s-backend-setup demo
    $ 4s-backend demo
    $ 4s-httpd -p 10000 demo

Client usage 
<<<<<<< HEAD
=======
    ```coffee
    # 4store endPoint
    endPoint = "http://0.0.0.0:10000"

    # create the 4store client
    n4store = require('n4store').createClient endPoint
    
    
    # GET: sparql query
    n4store.get """
      SELECT ?s ?p ?o 
      WHERE {
        ?s ?p ?o
      }
    """
    , (err, sparql) ->
      # sparql is json results
      console.log sparql


    # POST: sparql UPDATE
    n4store.post """
      INSERT {
        GRAPH <urn:agraph> {
          <urn:aresource> <urn:apredicate> "a literal"
        }
      }
    """
    , (err, body) ->
      console.log body


    # DELETE: delet a graph
    n4store.delete <urn:agraph>, (err) ->
      # graph is deleted


    # postData: Append data to a graph
    n4store.postData """
      <urn:aresource> <urn:apredicate> "a literal"
    """
    , "urn:agraph"
    , (err) ->
      # data is appended to the graph
    , "turtle" # format


```coffeescript
# 4store endPoint
endPoint = "http://0.0.0.0:10000"

# create the 4store client
n4store = require('n4store').createClient endPoint


# GET: sparql query
n4store.get """
  SELECT ?s ?p ?o 
  WHERE {
    ?s ?p ?o
  }
"""
, (err, sparql) ->
  # sparql is json results
  console.log sparql


# POST: sparql UPDATE
n4store.post """
  INSERT {
    GRAPH <urn:agraph> {
      <urn:aresource> <urn:apredicate> "a literal"
    }
  }
"""
, (err, body) ->
  console.log body


# DELETE: delet a graph
n4store.delete <urn:agraph>, (err) ->
  # graph is deleted


# postData: Append data to a graph
n4store.postData """
  <urn:aresource> <urn:apredicate> "a literal"
"""
, "urn:agraph"
, (err) ->
  # data is appended to the graph
, "turtle" # format


# postFile: append local file content to a graph
n4store.postFile "my-file.ttl"
, "urn:agraph" # if null graph will be <urn:my-file.tll>
, (err) ->
  # file content is appended to the graph
, "turtle" # format


# postFiles: append local files content to a graph
n4store.postFiles ["my-file.ttl", "my-other-file.ttl"]
, "urn:agraph" # if null graph will be <urn:*.tll>
, (err) ->
  # files content is appended to the graph
, "turtle" # format


# put: replace data in a graph
n4store.put """
  <urn:aresource> <urn:apredicate> "a literal"
"""
, "urn:agraph"
, (err) ->
  # data is replaced
, "turtle" # format


# putFile: replace local file content in a graph
n4store.putFile "my-file.ttl"
, "urn:agraph" # if null graph will be <urn:my-file.tll>
, (err) ->
  # file content is replaced in the graph
, "turtle" # format


# putFiles: append local files content to a graph
n4store.putFiles ["my-file.ttl", "my-other-file.ttl"]
, null
, (err) ->
  # files content is replaced in graphs
, "turtle" # format


# CONSTRUCT: return a turtle graph
n4store.construct """
  CONSTRUCT {
    ?s ?p ?o
  }
  WHERE {
   ?s ?p ?o 
  }
"""
, (err, turtle) ->
  console.log turtle


# ASK
n4store.ask """
  ASK {
    ?s foaf:name "Alice"
  }
""", (err, bool) ->
  console.log bool # true or false


# getGraphs: return an array of graphs URIs
n4store.getGraphs (err, uris) ->
  # array of all graphs URIs


# getTypes: return an array of types URIs
n4store.getTypes (err, uris) ->
  # array of all types URIs


# setPrefix add a new prefix in the client prefixes list
n4store.setPrefix 'test', 'http://test.com/', (err) ->


# prefixes: list of all prefixes used for queries
console.log n4store.prefixes 
```

