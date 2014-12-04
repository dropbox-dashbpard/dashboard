'use strict'

express = require('express')

dropbox = require './dropbox'

router = express.Router()

router.post '/', dropbox.ua, dropbox.product, dropbox.device, dropbox.add
router.post '/:dropbox_id/content', dropbox.updateContent
router.post '/:dropbox_id/upload', dropbox.upload

router.get '/item/:dropbox_id', dropbox.get
router.get '/items', dropbox.list

router.get '/product/:product/version/:version', dropbox.list
router.get '/product/:product/trend', dropbox.trend
router.get '/product/:product/distribution/:category', dropbox.distribution
router.get '/product/:product/errorrate', dropbox.errorRate
router.get '/product/:product/errorrate/app/*', dropbox.errorRateOfApp
router.get '/product/:product/errorrate/tag/*', dropbox.errorRateOfTag
router.get '/product/:product/trendofversion', dropbox.trendOfVersion
router.get '/product/:product/distributionofversion/:category', dropbox.distributionOfVersion
router.get '/product/:product/errorrateofversion', dropbox.errorRateOfVersion

router.get '/product/:product/app', dropbox.apps
router.get '/product/:product/tag', dropbox.tags

router.get '/products', dropbox.products
router.get '/product/:product', dropbox.product

module.exports = router
