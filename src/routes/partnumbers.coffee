express = require "express"
util = require "../util"

router = express.Router()

# find manufacturers matching prefix*
router.get "/:prefix", (req, res, next) ->
	console.log "---> get {partnumbers-mount}/:prefix", req.params
	sql = "select distinct t.manufacturer_part_nbr from toobz t where lower(t.manufacturer_part_nbr) like $1 order by t.manufacturer_part_nbr"
	try
		prefix = util.wildcard req.params.prefix, false, true
		results = await req.app.locals.db.query sql, [ prefix ]
		res.status(200).json ( row.manufacturer_part_nbr for row in results.rows )
	catch e
		console.error "ERROR", e
		res.status(500).json {status: "error", message: String(e)}

# list all manufacturers
router.get "/", (req, res, next) ->
	console.log "---> get {partnumbers-mount}/"
	sql = "select distinct t.manufacturer_part_nbr from toobz t order by t.manufacturer_part_nbr"
	try
		results = await req.app.locals.db.query sql
		res.status(200).json ( row.manufacturer_part_nbr for row in results.rows )
	catch e
		console.error "ERROR", e
		res.status(500).json {status: "error", message: String(e)}

module.exports = router
