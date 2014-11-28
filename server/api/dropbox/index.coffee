'use strict'

express = require('express')

dropbox = require './dropbox'

router = express.Router()

router.post '/', dropbox.ua, dropbox.product, dropbox.device, dropbox.add
router.post '/:dropbox_id/content', dropbox.updateContent
router.post '/:dropbox_id/upload', dropbox.upload
router.get '/:dropbox_id', dropbox.get
router.get '/', dropbox.list

module.exports = router
