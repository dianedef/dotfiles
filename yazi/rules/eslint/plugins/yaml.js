import jsonSchemaPlugin from "eslint-plugin-json-schema-validator"
import ymlPlugin from "eslint-plugin-yml"
import ymlParser from "yaml-eslint-parser"

export const ymlRules = {
	// https://ota-meshi.github.io/eslint-plugin-yml/rules/#yaml-rules
	"yml/block-mapping-colon-indicator-newline"   : "warn",
	"yml/block-mapping-question-indicator-newline": "warn",
	"yml/block-mapping"                           : ["warn", { singleline: "never", multiline: "always" }],
	"yml/block-sequence-hyphen-indicator-newline" : "warn",
	"yml/block-sequence"                          : ["warn", { singleline: "never", multiline: "always" }],
	"yml/indent"                                  : "warn",
	"yml/no-trailing-zeros"                       : "warn",
	"yml/plain-scalar"                            : "warn",
	"yml/quotes"                                  : "warn",

	// https://ota-meshi.github.io/eslint-plugin-yml/rules/#extension-rules
	"yml/flow-mapping-curly-newline"  : "warn",
	"yml/flow-mapping-curly-spacing"  : ["warn", "always"],
	"yml/flow-sequence-bracket-newline": ["warn", "consistent"],
	"yml/flow-sequence-bracket-spacing": "warn",
	"yml/key-spacing"                 : ["warn", { align: "colon" }],
	"yml/no-multiple-empty-lines"     : ["warn", { max: 1, maxBOF: 0, maxEOF: 1 }],
	"yml/spaced-comment"              : ["warn", "always"],
}

/** @type { import('eslint').Linter.Config[] } */
export const yaml = [
	{
		files          : ["**/*.{yaml,yml}"],
		languageOptions: { parser: ymlParser },
		plugins        : {
			"yml"                  : ymlPlugin,
			"json-schema-validator": jsonSchemaPlugin,
		},
		rules: {
			// eslint-plugin-yml
			...ymlPlugin.configs["flat/recommended"].rules,
			...ymlRules,

			// eslint-plugin-json-schema-validator
			...jsonSchemaPlugin.configs["flat/recommended"].rules,
		},
	},
]
