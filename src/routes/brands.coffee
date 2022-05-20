express = require "express"
util = require "../util"

router = express.Router()

# find brands matching prefix*
router.get "/:prefix", (req, res, next) ->
	console.log "---> get {brands-mount}/:prefix", req.params
	sql = """
		select distinct t.brand_name
		  from toobz t
		 where lower(t.brand_name) like $1
		 order by t.brand_name
	"""
	try
		prefix = util.wildcard req.params.prefix, false, true
		results = await req.app.locals.db.query sql, [ prefix ]
		res.status(200).json ( row.brand_name for row in results.rows )
	catch e
		console.error "ERROR", e
		res.status(500).json {status: "error", message: String(e)}

# list all brands
router.get "/", (req, res, next) ->
	console.log "[brands] get {brands-mount}/"
	sql = """
		select distinct t.brand_name
		  from toobz t
		 order by t.brand_name
	"""
	try
		results = await req.app.locals.db.query sql
		res.status(200).json ( row.brand_name for row in results.rows )
	catch e
		console.error "ERROR", e
		res.status(500).json {status: "error", message: String(e)}

module.exports = router
