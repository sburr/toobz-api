express = require "express"
Factz = require "../models/factz"

router = express.Router()


router.get "/:id", (req, res, next) ->
	console.log "---> get {factz-mount}/:id", req.params.id
	try
		factz = new Factz req.app.locals.db
		fact = await factz.findById req.params.id
		res.status(200).json fact
	catch e
		console.error "ERROR", e
		res.status(500).json {status: "error", message: String(e)}

router.post "/", (req, res, next) ->
	console.log "---> post {factz-mount}/"
	try
		factz = new Factz req.app.locals.db
		fact = await factz.createFact req.body
		res.status(200).json fact
	catch e
		console.error "ERROR", e
		res.status(500).json {status: "error", message: String(e)}

router.put "/:id", (req, res, next) ->
	console.log "---> put {factz-mount}/:id", req.params.id
	try
		factz = new Factz req.app.locals.db
		fact = await factz.updateFact req.params.id, req.body
		res.status(200).json fact
	catch e
		console.error "ERROR", e
		res.status(500).json {status: "error", message: String(e)}

router.delete "/:id", (req, res, next) ->
	console.log "---> delete {factz-mount}/:id", req.params.id
	try
		factz = new Factz req.app.locals.db
		status = await factz.deleteById req.params.id
		res.status(200).json status
	catch e
		console.error "ERROR", e
		res.status(500).json {status: "error", message: String(e)}

router.get "/inventory/:inventoryNbr/name/:name", (req, res, next) ->
	console.log "---> get {factz-mount}/inventory/:inventoryNbr/name/:name", req.params.inventoryNbr, req.params.name
	try
		factz = new Factz req.app.locals.db
		facts = await factz.findByPartAndName req.params.inventoryNbr, req.params.name
		res.status(200).json facts
	catch e
		console.error "ERROR", e
		res.status(500).json {status: "error", message: String(e)}

router.get "/inventory/:inventoryNbr", (req, res, next) ->
	console.log "---> get {factz-mount}/inventory/:inventoryNbr", req.params.inventoryNbr
	try
		factz = new Factz req.app.locals.db
		facts = await factz.findByPart req.params.inventoryNbr
		res.status(200).json facts
	catch e
		console.error "ERROR", e
		res.status(500).json {status: "error", message: String(e)}

module.exports = router
