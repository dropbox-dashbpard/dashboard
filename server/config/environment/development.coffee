"use strict"

# Development specific configuration
# ==================================
module.exports =
  
  # MongoDB connection options
  mongo:
    # uri: "mongodb://localhost/dbboard-dev"
    uri: "mongodb://192.168.100.101/dbboard"

  seedDB: false

  url:
    errordetect: process.env.URL_ERRORDETECT or "http://cr.ota.xinqitec.com/api/0/ed"
