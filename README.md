


# n4store

n4store is a simple http client for 4store

# Installation 

  $ npm install n4store

# Usage 

Create a 4store kb 

  $ $ 4s-backend-setup demo
  $ $ 4s-backend demo
  $ $ 4s-httpd -p 10000 demo

Create a client 

  $ 
  $ endPoint = "http://0.0.0.0:10000"
  $ require('n4store').createClient endPoint
  $ 