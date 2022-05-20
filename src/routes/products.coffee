express = require "express"
util = require "../util"

router = express.Router()

# find all product names matching prefix*
router.get "/:prefix", (req, res, next) ->
	console.log "---> get {products-mount}/:prefix", req.params
	sql = """
		select distinct t.product_name
		  from toobz t
		 where lower(t.product_name) like $1
		 order by t.product_name
	"""
	try
		prefix = util.wildcard req.params.prefix, false, true
		results = await req.app.locals.db.query sql, [ prefix ]
		res.status(200).json ( row.product_name for row in results.rows )
	catch e
		console.error "ERROR", e
		res.status(500).json {status: "error", message: String(e)}

# list all product names
router.get "/", (req, res, next) ->
	console.log "---> get {products-mount}/"
	sql = """
		select distinct t.product_name
		  from toobz t
		 order by t.product_name
	"""
	try
		results = await req.app.locals.db.query sql
		res.status(200).json ( row.product_name for row in results.rows )
	catch e
		console.error "ERROR", e
		res.status(500).json {status: "error", message: String(e)}

module.exports = router
