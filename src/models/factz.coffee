util = require "../util"

class Factz
	constructor: (@db) ->

	findById: (id="") ->
		sql = "select f.* from factz f where f.id = $1"
		results = await @db.query sql, [ id ]
		util.toCamel results.rows[0]

	findByPart: (inventoryNbr="") ->
		sql = "select f.* from toobz_factz tf, factz f where tf.inventory_nbr = $1 and tf.fact_id = f.id order by f.name, f.value"
		results = await @db.query sql, [ inventoryNbr ]
		( util.toCamel row for row in results.rows )

	findByPartAndName: (inventoryNbr="", factName="") ->
		sql = "select f.* from toobz_factz tf, factz f where tf.inventory_nbr = $1 and tf.fact_id = f.id and lower(f.name) = $2 order by f.name, f.value"
		factName = util.wildcard factName, false, false
		results = await @db.query sql, [ inventoryNbr, factName ]
		( util.toCamel row for row in results.rows )

	deleteFact: (id) ->
		db = @db
		sqls = [
			"delete from factz f where f.id = $1"
			"delete from toobz_factz tf where tf.fact_id = $1"
		]
		makeTask = (sql, args) => db.query sql, args
		tasks = ( makeTask sql, [ id ] for sql in sqls )
		await Promise.all tasks
		{status: "success", message: "deleted"}
		
	deletePartFacts: (inventoryNbr) ->
		db = @db
		sqls = [
			"delete from factz f where f.id in (select tf.fact_id from toobz_factz tf where tf.inventory_nbr = $1)"
			"delete from toobz_factz tf where tf.inventory_nbr = $1"
		]
		makeTask = (sql, args) => db.query sql, args
		tasks = ( makeTask sql, [ inventoryNbr ] for sql in sqls )
		await Promise.all tasks
		{status: "success", message: "deleted"}

	createFact: (data={}) ->
		db = @db

		factId = undefined
		nextFactId = () ->
			sql = "select nextval('factz_id_seq') as nextval"
			results = await db.query sql
			id = results.rows[0].nextval
			factId = id
			id

		sqls = [
			"insert into factz ( id, name, value, description, created_on, last_modified) values ( $1, $2, $3, $4, NOW(), NOW())"
		]

		results = await db.query sqls[0], [await nextFactId(), data.name, data.value, data.description]

		@findById factId

	createPartFact: (inventoryNbr, data={}) ->
		db = @db

		factId = undefined
		nextFactId = () ->
			sql = "select nextval('factz_id_seq') as nextval"
			results = await db.query sql
			id = results.rows[0].nextval
			factId = id
			id

		sqls = [
			"insert into factz ( id, name, value, description, created_on, last_modified) values ( $1, $2, $3, $4, NOW(), NOW())"
			"insert into toobz_factz ( inventory_nbr, fact_id) values ( $1, $2)"
		]

		results = await db.query sqls[0], [await nextFactId(), data.name, data.value, data.description]
		results = await db.query sqls[1], [inventoryNbr, factId]

		@findById factId

	updateFact: (id, data={}) ->
		isValidField = (name) -> ["name", "value", "description"].includes name
		i = 1
		clauses = ( "#{key} = $#{i+=1}" for key of data when isValidField key )
		return {error: "Empty update"} unless clauses.length
		values = ( value for key, value of data when isValidField key )
		values.unshift id

		sql = "update factz set #{clauses.join ", "} where id = $1"

		# TODO : validation/normalization
		results = await @db.query sqls[0], values

		@findById id

module.exports = Factz
