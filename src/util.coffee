{ toCamel, toSnake } = require "snake-camel"

wildcard = (text, before=true, after=true) ->
	"#{if before then "%" else ""}#{(text ? '').toLowerCase()}#{if after then "%" else ""}"

zeroPad = (num, places) -> String(num).padStart(places, "0")

module.exports = { toCamel, toSnake, wildcard, zeroPad }
