console.log "===> Starting server..."
console.log "===> Environment"
console.log process.env

express = require "express"
bodyParser = require "body-parser"
cors = require "cors"
ToobzDb = require "./database"

fs = require "fs"
http = require "http"
https = require "https"
keyFile = process.env["SSL_KEYFILE"] or "serverkey.pem"
certFile = process.env["SSL_CERTFILE"] or "servercert.pem"
console.error "Loading SSL keyfile: #{keyFile}"
privateKey = fs.readFileSync keyFile, "utf8"
console.error "Loading SSL certfile: #{certFile}"
certificate = fs.readFileSync certFile, "utf8"
credentials = {key: privateKey, cert: certificate}

db = new ToobzDb(
	process.env.PGHOST or "localhost",
	process.env.PGPORT or 5432,
	process.env.PGDATABASE or "toobz",
	process.env.PGUSER or "postgres",
	process.env.PGPASS or ""
)

app = express()

db.connect()
db.initDb()

app.locals.db = db

app.use cors()
app.use bodyParser.json({limit: "50mb"})
app.use "/toobz", require "./routes/toobz"
app.use "/factz", require "./routes/factz"
app.use "/brands", require "./routes/brands"
app.use "/manufacturers", require "./routes/manufacturers"
app.use "/partnumbers", require "./routes/partnumbers"
app.use "/products", require "./routes/products"
app.use "/apidocs", express.static "#{__dirname}/apidocs"  # for pretty docz
app.use "/", express.static "#{__dirname}/public"  # basically just for the favicon :)

port = process.env.HTTP_PORT || 8000
securePort = process.env.HTTPS_PORT || 8443

httpServer = http.createServer app
httpsServer = https.createServer credentials, app

httpServer.listen port, () ->
	console.log "===> HTTP server is listening on port #{port} ..."
	console.log "HTTP ready"

httpsServer.listen securePort, () ->
	console.log "===> HTTPS server is listening on port #{securePort} ..."
	console.log "HTTPS ready"
