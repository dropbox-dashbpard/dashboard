'use strict'

express = require('express')

dropbox = require './dropbox'
product = require './product'
productModel = require './model'
productConfig = require './config'
auth = require('../../lib/auth/auth')

router = express.Router()

localAuth = [auth.ensureAuthenticated, dropbox.dbmodel]
bearerAuth = [auth.ensureToken, dropbox.dbmodel]

router.post '/', bearerAuth, dropbox.ua, dropbox.product, dropbox.device, dropbox.add
router.post '/:dropbox_id/content', bearerAuth, dropbox.updateContent
router.post '/:dropbox_id/upload', bearerAuth, dropbox.upload

router.get '/items/:dropbox_id', localAuth, dropbox.get
router.get '/items', localAuth, dropbox.list

# router.get '/product/:product/version/:version', localAuth, dropbox.list
router.get '/product/:product/trend', localAuth, dropbox.trend
router.get '/product/:product/distribution/:category', localAuth, dropbox.distribution
router.get '/product/:product/errorrate', localAuth, dropbox.errorRate
router.get '/product/:product/errorrate/app/*', localAuth, dropbox.errorRateOfApp
router.get '/product/:product/errorrate/tag/*', localAuth, dropbox.errorRateOfTag
router.get '/product/:product/trendofversion', localAuth, dropbox.trendOfVersion
router.get '/product/:product/distributionofversion/:category', localAuth, dropbox.distributionOfVersion
router.get '/product/:product/errorrateofversion', localAuth, dropbox.errorRateOfVersion

router.get '/product/:product/app', localAuth, dropbox.apps
router.get '/product/:product/tag', localAuth, dropbox.tags

router.get '/product', localAuth, product.list
router.get '/product/:product', localAuth, product.get

router.post '/product/:product/dist/:dist/version/:version', bearerAuth, product.updateVersions
router.delete '/product/:product/dist/:dist/version/:version', bearerAuth, product.rmVersion
router.post '/product/:product/dist/:dist/version', bearerAuth, product.updateVersions
router.get '/product/:product/version', bearerAuth, product.getVersions

router.get "/releases", localAuth, product.versionType

router.post '/productmodel', localAuth, productModel.add
router.get '/productmodel', localAuth, productModel.list
router.get '/productmodel/:id', localAuth, productModel.get
router.post '/productmodel/:id', localAuth, productModel.update
router.delete '/productmodel/:id', localAuth, productModel.del

router.post '/productconfig', localAuth, productConfig.add
router.get '/productconfig', localAuth, productConfig.list
router.get '/productconfig/:id', localAuth, productConfig.get
router.post '/productconfig/:id', localAuth, productConfig.update
router.delete '/productconfig/:id', localAuth, productConfig.del

module.exports = router
