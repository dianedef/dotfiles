import jsonSchemaPlugin from "eslint-plugin-json-schema-validator"
import tomlPlugin from "eslint-plugin-toml"
import tomlParser from "toml-eslint-parser"

export const tomlRules = {
	// https://ota-meshi.github.io/eslint-plugin-toml/rules/#toml-rules
	"toml/indent"                     : ["warn", "tab", { subTables: 1 }],
	"toml/keys-order"                 : "warn",
	"toml/no-non-decimal-integer"     : "warn",
	"toml/no-space-dots"              : "warn",
	"toml/padding-line-between-pairs" : "warn",
	"toml/padding-line-between-tables": "warn",
	"toml/quoted-keys"                : "warn",
	"toml/tables-order"               : "warn",

	// https://ota-meshi.github.io/eslint-plugin-toml/rules/#extension-rules
	"toml/array-bracket-newline"     : ["warn", "consistent"],
	"toml/array-bracket-spacing"     : "warn",
	"toml/array-element-newline"     : ["warn", "consistent"],
	"toml/comma-style"               : "warn",
	"toml/inline-table-curly-spacing": ["warn", "always"],
	"toml/key-spacing"               : ["warn", { align: "equal" }],
	"toml/spaced-comment"            : ["warn", "always", { markers: ["#"] }],
	"toml/table-bracket-spacing"     : "warn",
}

/** @type { import('eslint').Linter.Config[] } */
export const toml = [
	{
		files          : ["**/*.toml"],
		languageOptions: { parser: tomlParser },
		plugins        : {
			"toml"                 : tomlPlugin,
			"json-schema-validator": jsonSchemaPlugin,
		},
		rules: {
			// eslint-plugin-toml
			...tomlPlugin.configs["flat/recommended"].rules,
			...tomlRules,

			// eslint-plugin-json-schema-validator
			...jsonSchemaPlugin.configs["flat/recommended"].rules,
		},
	},
]
