


# n4store

n4store is a simple http client for 4store

# Installation 

    $ npm install n4store

# Usage 

Create a 4store kb 

    $ 4s-backend-setup demo
    $ 4s-backend demo
    $ 4s-httpd -p 10000 demo

## Create client

```coffeescript
# 4store endPoint
endPoint = "http://0.0.0.0:10000"

# create the 4store client
n4store = require('n4store').createClient endPoint
```


## SPARQL GET request
```coffeescript
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
```


## SPARQL UPDATE POST request
```coffeescript
n4store.post """
  INSERT {
    GRAPH <urn:agraph> {
      <urn:aresource> <urn:apredicate> "a literal"
    }
  }
"""
, (err, body) ->
  console.log body
```


## DELETE request
```coffeescript
# delete a graph
n4store.delete <urn:agraph>, (err) ->
  # graph is deleted
```


## Append data to a graph
```coffeescript
n4store.postData """
  <urn:aresource> <urn:apredicate> "a literal"
"""
, "urn:agraph"
, (err) ->
  # data is appended to the graph
, "turtle" # format
```


## postFile
```coffeescript
# append local file content to a graph
n4store.postFile "my-file.ttl"
, "urn:agraph" # if null graph will be <urn:my-file.tll>
, (err) ->
  # file content is appended to the graph
, "turtle" # format
```


## postFiles
```coffeescript
# postFiles: append local files content to a graph
n4store.postFiles ["my-file.ttl", "my-other-file.ttl"]
, "urn:agraph" # if null graph will be <urn:*.tll>
, (err) ->
  # files content is appended to the graph
, "turtle" # format
```


## PUT
```coffeescript
# replace data in a graph
n4store.put """
  <urn:aresource> <urn:apredicate> "a literal"
"""
, "urn:agraph"
, (err) ->
  # data is replaced
, "turtle" # format
```


## putFile
```coffeescript
# replace the content of a graph by the file content
n4store.putFile "my-file.ttl"
, "urn:agraph" # if null graph will be <urn:my-file.tll>
, (err) ->
  # file content is replaced in the graph
, "turtle" # format
```


## putFiles
```coffeescript
# replace the content of graphs by the files content
n4store.putFiles ["my-file.ttl", "my-other-file.ttl"]
, null
, (err) ->
  # files content is replaced in graphs
, "turtle" # format
```


## CONSTRUCT
```coffeescript
# return a turtle graph
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
```


## ASK
```coffeescript
# ASK request
n4store.ask """
  ASK {
    ?s foaf:name "Alice"
  }
""", (err, bool) ->
  console.log bool # true or false
```


## helpers

```coffeescript
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

