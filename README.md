


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
    
    # 4store endPoint
    endPoint = "http://0.0.0.0:10000"

    # create the 4store client
    n4store = require('n4store').createClient endPoint
    
    
    
