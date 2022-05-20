Pool = require("pg").Pool

class ToobzDb

	constructor: (
		@host = process.env.PGHOST || "localhost",
		@port = process.env.PGPORT || 5432,
		@database = process.env.PGDATABASE || "postgres",
		@user = process.env.PGUSER || "postgres",
		@password = process.env.PGPASSWORD || "") ->
			# just set the member vars

	query: (sql, params) ->
		console.log "[ToobzDb] querying db", sql, params
		@pool.query sql, params

	createTables: () ->
		sqls = [
			"""
			CREATE TABLE IF NOT EXISTS toobz (
				inventory_nbr text PRIMARY KEY,
				manufacturer_part_nbr text NOT NULL,
				manufacturer text,
				brand_name text,
				alternate_part_nbr text,
				product_name text,
				product_description text,
				product_condition text,
				test_status text,
				created_on timestamp,
				last_modified timestamp
			)"""
			"""
			CREATE TABLE IF NOT EXISTS factz (
				id bigint PRIMARY KEY DEFAULT nextval('factz_id_seq'),
				name text NOT NULL,
				value text,
				description text,
				created_on timestamp,
				last_modified timestamp
			)"""
			"""
			CREATE TABLE IF NOT EXISTS toobz_factz (
				inventory_nbr text,
				fact_id bigint,
				PRIMARY KEY(inventory_nbr, fact_id)
			)
			"""
		]

		console.log "[ToobzDb] creating tables..."
		done = (res) -> console.log "[ToobzDb] created tables", res.rows
		error = (err) -> console.log "[ToobzDb] error creating tables", err
		makeTask = (sql) => @query sql
		tasks = ( makeTask sql for sql in sqls )
		Promise.all(tasks).then(done).catch(error)

	createIndexes: () ->
		sqls = [
			"CREATE INDEX IF NOT EXISTS mfr_part_nbr_idx ON toobz (lower(manufacturer_part_nbr))"
			"CREATE INDEX IF NOT EXISTS mfr_idx ON toobz (lower(manufacturer))"
			"CREATE INDEX IF NOT EXISTS brand_name_idx ON toobz (lower(brand_name))"
			"CREATE INDEX IF NOT EXISTS alt_part_nbr_idx ON toobz (lower(alternate_part_nbr))"
			"CREATE INDEX IF NOT EXISTS prod_name_idx ON toobz (lower(product_name))"
			"CREATE INDEX IF NOT EXISTS prod_desc_idx ON toobz (lower(product_description))"
			"CREATE INDEX IF NOT EXISTS prod_cond_idx ON toobz (lower(product_condition))"
			"CREATE INDEX IF NOT EXISTS test_status_idx ON toobz (lower(test_status))"
			"CREATE INDEX IF NOT EXISTS search_idx ON toobz (lower(manufacturer_part_nbr), lower(manufacturer), lower(brand_name), lower(alternate_part_nbr), lower(product_name), lower(product_description))"
			"CREATE INDEX IF NOT EXISTS fact_name_idx ON factz (lower(name))"
			#"CREATE INDEX IF NOT EXISTS fact_value_idx ON factz (lower(value))"   # nb: inline images are huge!
		]
		
		console.log "[ToobzDb] creating indexes..."
		done = (res) -> console.log "[ToobzDb] created indexes", res.rows
		error = (err) -> console.log "[ToobzDb] error creating indexes", err
		makeTask = (sql) => @query sql
		tasks = ( makeTask sql for sql in sqls )
		Promise.all(tasks).then(done).catch(error)

	createSequences: () ->
		sqls = [
			"CREATE SEQUENCE IF NOT EXISTS inventory_nbr_seq AS bigint"
			"CREATE SEQUENCE IF NOT EXISTS factz_id_seq AS bigint"
		]
		
		console.log "[ToobzDb] creating sequences..."
		done = (res) -> console.log "[ToobzDb] created sequences", res.rows
		error = (err) -> console.log "[ToobzDb] error creating sequences", err
		makeTask = (sql) => @query sql
		tasks = ( makeTask sql for sql in sqls )
		Promise.all(tasks).then(done).catch(error)

	connect: () ->
		console.log "[ToobzDb] connecting...", { user: @user, host: @host, database: @database, password: @password, port: @port }
		@pool = new Pool({ user: @user, host: @host, database: @database, password: @password, port: @port })
		@pool.on "error", (err, client) -> console.log "[ToobzDb] unexpected error on idle client", err

	initDb: () ->
		console.log "[ToobzDb] initializing..."
		@createSequences()
		@createTables()
		@createIndexes()

	closeDb: () ->
		await @pool.end()


module.exports = ToobzDb
