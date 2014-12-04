'use strict'

express = require('express')

router = express.Router()

router.get '/location/:ip', require('./iplocation').ip2location

module.exports = router
