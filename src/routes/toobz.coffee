express = require "express"
Toobz = require "../models/toobz"

router = express.Router()

# lookup item by inventoryNbr
router.get "/inventory/:inventoryNbr", (req, res, next) ->
	console.log "---> get {toobz-mount}/inventory/:inventoryNbr", req.params
	try
		toobz = new Toobz req.app.locals.db
		item = await toobz.findByInventoryNbr req.params.inventoryNbr
		res.status(200).json item
	catch e
		console.error "ERROR", e
		res.status(500).json {status: "error", message: String(e)}

# lookup item by inventoryNbr
router.delete "/inventory/:inventoryNbr", (req, res, next) ->
	console.log "---> delete {toobz-mount}/inventory/:inventoryNbr", req.params
	try
		toobz = new Toobz req.app.locals.db
		status = await toobz.deleteByInventoryNbr req.params.inventoryNbr
		res.status(200).json status
	catch e
		console.error "ERROR", e
		res.status(500).json {status: "error", message: String(e)}

# update an existing item
router.put "/inventory/:inventoryNbr", (req, res, next) ->
	console.log "---> put {toobz-mount}/inventory/:inventoryNbr", req.params
	try
		toobz = new Toobz req.app.locals.db
		item = await toobz.updateItem req.params.inventoryNbr, req.body
		res.status(200).json item
	catch e
		console.error "ERROR", e
		res.status(500).json {status: "error", message: String(e)}

# find items by *manufacturerPartNbr*
router.get "/partnumber/:manufacturerPartNbr", (req, res, next) ->
	console.log "---> get {toobz-mount}/partnumber/:manufacturerPartNbr", req.params
	try
		toobz = new Toobz req.app.locals.db
		items = await toobz.findByField "manufacturer_part_nbr", req.params.manufacturerPartNbr
		res.status(200).json items
	catch e
		console.error "ERROR", e
		res.status(500).json {status: "error", message: String(e)}

# find items by *alternatePartNbr*
router.get "/alternatepartnumber/:alternatePartNbr", (req, res, next) ->
	console.log "---> get {toobz-mount}/partnumber/:alternatePartNbr", req.params
	try
		toobz = new Toobz req.app.locals.db
		items = await toobz.findByField "alternate_part_nbr", req.params.alternatePartNbr
		res.status(200).json items
	catch e
		console.error "ERROR", e
		res.status(500).json {status: "error", message: String(e)}

# find items by *productName*
router.get "/product/:productName", (req, res, next) ->
	console.log "---> get {toobz-mount}/product/:productName", req.params
	try
		toobz = new Toobz req.app.locals.db
		items = await toobz.findByField "product_name", req.params.productName
		res.status(200).json items
	catch e
		console.error "ERROR", e
		res.status(500).json {status: "error", message: String(e)}

# find items by *productDesription*
router.get "/description/:productDescription", (req, res, next) ->
	console.log "---> get {toobz-mount}/name/:productDescription", req.params
	try
		toobz = new Toobz req.app.locals.db
		items = await toobz.findByField "product_description", req.params.productDescription
		res.status(200).json items
	catch e
		console.error "ERROR", e
		res.status(500).json {status: "error", message: String(e)}

# find items by productCondition 
router.get "/condition/:productCondition", (req, res, next) ->
	console.log "---> get {toobz-mount}/name/:productCondition", req.params
	try
		toobz = new Toobz req.app.locals.db
		items = await toobz.findByField "product_condition", req.params.productCondition, {match: "exact"}
		res.status(200).json items
	catch e
		console.error "ERROR", e
		res.status(500).json {status: "error", message: String(e)}

# find items by *manufacturerPartNbr* or *manufacturer* or *brandName* or *alternatePartNbr* or *productName* or *productDescription*
router.get "/search/:text", (req, res, next) ->
	console.log "---> get {toobz-mount}/search/:text", req.params
	try
		toobz = new Toobz req.app.locals.db
		items = await toobz.search req.params.text
		res.status(200).json items
	catch e
		console.error "ERROR", e
		res.status(500).json {status: "error", message: String(e)}

# create a new item
router.post "/", (req, res, next) ->
	console.log "---> post {toobz-mount}/inventory", req.body

	try
		toobz = new Toobz req.app.locals.db
		item = await toobz.createItem req.body
		res.status(200).json item
	catch e
		console.error "ERROR", e
		res.status(500).json {status: "error", message: String(e)}

module.exports = router
