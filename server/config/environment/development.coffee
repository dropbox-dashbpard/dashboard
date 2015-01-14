"use strict"

# Development specific configuration
# ==================================
module.exports =
  
  # MongoDB connection options
  mongo:
    uri: "mongodb://localhost/dbboard-dev"

  seedDB: true

  url:
    errordetect: process.env.URL_ERRORDETECT or "http://cr.ota.xinqitec.com/api/0/ed"
