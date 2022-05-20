util = require "../util"
Factz = require "./factz"

toBool = (text) ->
	if typeof text is "string"
		try
			text = !!JSON.parse text
		catch e
			text = false
	!!text

class Toobz
	constructor: (@db) ->

	findByInventoryNbr: (inventoryNbr="") ->
		sql = "select t.* from toobz t where t.inventory_nbr = $1"
		results = await @db.query sql, [ inventoryNbr ]
		item = util.toCamel results.rows[0]
		item.testStatus = toBool item.testStatus
		factz = new Factz @db
		item.facts = await factz.findByPart inventoryNbr
		item

	deleteByInventoryNbr: (inventoryNbr="") ->
		sql = "delete from toobz t where t.inventory_nbr = $1"
		results = await @db.query sql, [ inventoryNbr ]
		factz = new Factz @db
		await factz.deletePartFacts inventoryNbr
		{status: "success", message: "deleted"}

	# options.match = "exact" for "=" operator
	# options.match = "include" for "like" operator (default)
	findByField: (fieldName, fieldValue, options={match: "include"}) ->
		oper = if options.match is "exact" then "=" else "like"
		sql = "select t.* from toobz t where lower(t.#{fieldName}) #{oper} $1 order by t.manufacturer_part_nbr, t.manufacturer, t.brand_name, t.alternate_part_nbr, t.inventory_nbr"
		fieldValue = util.wildcard fieldValue
		results = await @db.query sql, [ fieldValue ]
		items = []
		factz = new Factz @db
		for row in results.rows
			item = util.toCamel row
			item.testStatus = toBool item.testStatus
			item.facts = await factz.findByPart item.inventoryNbr
			items.push item
		items

	search: (text) ->
		sql = [
			"select t.* from toobz t where lower(t.inventory_nbr) like $1 or lower(t.manufacturer_part_nbr) like $1 or lower(t.manufacturer) like $1 or lower(t.brand_name) like $1 or lower(t.alternate_part_nbr) like $1 or lower(t.product_name) like $1 or lower(t.product_description) like $1 order by t.manufacturer_part_nbr, t.manufacturer, t.brand_name, t.alternate_part_nbr, t.inventory_nbr"
			"select f.* from toobz_factz tf, factz f where tf.fact_id = f.id and tf.inventory_nbr = $1 order by f.name, f.value"
		]
		searchText = util.wildcard text
		results = await @db.query sql[0], [ searchText ]
		items = []
		factz = new Factz @db
		for row in results.rows
			item = util.toCamel row
			item.testStatus = toBool item.testStatus
			item.facts = await factz.findByPart item.inventoryNbr
			items.push item
		items

	createItem: (data={}) ->
		db = @db

		nextTubeId = () ->
			sql = "select nextval('inventory_nbr_seq')"
			results = await db.query sql
			nbr = results.rows[0].nextval
			"AK-#{util.zeroPad nbr, 6}"

		sql = "insert into toobz ( inventory_nbr, manufacturer_part_nbr, manufacturer, brand_name, alternate_part_nbr, product_name, product_description, product_condition, test_status, created_on, last_modified) values ( $1, $2, $3, $4, $5, $6, $7, $8, $9, NOW(), NOW())"

		inventoryNbr = await nextTubeId()
		{ manufacturerPartNbr, manufacturer, brandName, alternatePartNbr, productName, productDescription,
			productCondition, testStatus, facts } = data

		testStatus = String toBool testStatus
		results = await @db.query sql, [ inventoryNbr, manufacturerPartNbr, manufacturer, brandName,
			alternatePartNbr, productName, productDescription, productCondition, testStatus
		]

		factz = new Factz @db
		await factz.createPartFact inventoryNbr, fact for fact in facts

		@findByInventoryNbr inventoryNbr

	updateItem: (inventoryNbr="", data={}) ->
		db = @db

		validKeys = [ "manufacturerPartNbr", "manufacturer", "brandName", "alternatePartNbr", "productName", "productDescription", "productCondition", "testStatus" ]
		isValidField = (name) -> validKeys.includes name
		facts = data.facts
		delete data[key] for key of data when not isValidField key

		i = 1
		fields = util.toSnake data
		fields.testStatus = String(toBool fields.testStatus) if "testStatus" of fields 
		clauses = ( "#{key} = $#{i+=1}" for key of fields )
		return {error: "Empty update"} unless clauses.length
		values = ( value for key, value of fields )
		values.unshift inventoryNbr

		sql = "update toobz set #{clauses.join ", "}, last_modified = NOW() where inventory_nbr = $1"

		# TODO : validation/normalization
		results = await db.query sql, values

		factz = new Factz @db
		await factz.deletePartFacts inventoryNbr
		await factz.createPartFact inventoryNbr, fact for fact in facts

		@findByInventoryNbr inventoryNbr

module.exports = Toobz
