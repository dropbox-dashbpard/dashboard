'use strict'

express = require('express')

dropbox = require './dropbox'
auth = require('../../lib/auth/auth')

router = express.Router()

router.post '/', dropbox.bearerAuth, dropbox.ua, dropbox.product, dropbox.device, dropbox.add
router.post '/:dropbox_id/content', dropbox.bearerAuth, dropbox.updateContent
router.post '/:dropbox_id/upload', dropbox.bearerAuth, dropbox.upload

router.get '/items/:dropbox_id', dropbox.localAuth, dropbox.get
router.get '/items', dropbox.localAuth, dropbox.list

router.get '/product/:product/version/:version', dropbox.localAuth, dropbox.list
router.get '/product/:product/trend', dropbox.localAuth, dropbox.trend
router.get '/product/:product/distribution/:category', dropbox.localAuth, dropbox.distribution
router.get '/product/:product/errorrate', dropbox.localAuth, dropbox.errorRate
router.get '/product/:product/errorrate/app/*', dropbox.localAuth, dropbox.errorRateOfApp
router.get '/product/:product/errorrate/tag/*', dropbox.localAuth, dropbox.errorRateOfTag
router.get '/product/:product/trendofversion', dropbox.localAuth, dropbox.trendOfVersion
router.get '/product/:product/distributionofversion/:category', dropbox.localAuth, dropbox.distributionOfVersion
router.get '/product/:product/errorrateofversion', dropbox.localAuth, dropbox.errorRateOfVersion

router.get '/product/:product/app', dropbox.localAuth, dropbox.apps
router.get '/product/:product/tag', dropbox.localAuth, dropbox.tags

router.get '/products', dropbox.localAuth, dropbox.productList
router.get '/product/:product', dropbox.localAuth, dropbox.productGet

router.get "/releases", dropbox.localAuth, dropbox.versionType

module.exports = router
