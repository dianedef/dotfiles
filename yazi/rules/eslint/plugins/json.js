import jsonSchemaPlugin from "eslint-plugin-json-schema-validator"
import jsoncPlugin from "eslint-plugin-jsonc"
import jsoncParser from "jsonc-eslint-parser"

export const jsoncRules = {
	// https://ota-meshi.github.io/eslint-plugin-jsonc/rules/#jsonc-rules
	"jsonc/no-binary-expression"            : "warn",
	"jsonc/no-binary-numeric-literals"      : "warn",
	"jsonc/no-escape-sequence-in-identifier": "warn",
	"jsonc/no-hexadecimal-numeric-literals" : "warn",
	"jsonc/no-number-props"                 : "warn",
	"jsonc/no-numeric-separators"           : "warn",
	"jsonc/no-octal-numeric-literals"       : "warn",
	"jsonc/no-parenthesized"                : "warn",
	"jsonc/no-plus-sign"                    : "warn",
	"jsonc/no-template-literals"            : "warn",
	"jsonc/no-unicode-codepoint-escapes"    : "warn",
	"jsonc/valid-json-number"               : "warn",

	// https://ota-meshi.github.io/eslint-plugin-jsonc/rules/#extension-rules
	"jsonc/array-bracket-newline"  : ["warn", "consistent"],
	"jsonc/array-bracket-spacing"  : "warn",
	"jsonc/array-element-newline"  : ["warn", "consistent"],
	"jsonc/comma-dangle"           : ["warn", "never"],
	"jsonc/comma-style"            : "warn",
	"jsonc/indent"                 : ["warn", "tab"],
	"jsonc/key-spacing"            : ["warn", { align: "colon" }],
	"jsonc/no-floating-decimal"    : "warn",
	"jsonc/object-curly-newline"   : "warn",
	"jsonc/object-curly-spacing"   : ["warn", "always"],
	"jsonc/object-property-newline": ["warn", { allowAllPropertiesOnSameLine: true }],
	"jsonc/quote-props"            : "warn",
	"jsonc/quotes"                 : ["warn", "double", { avoidEscape: true, allowTemplateLiterals: true }],
	"jsonc/space-unary-ops"        : ["warn", { words: true, nonwords: false }],
}

/** @type { import('eslint').Linter.Config[] } */
export const json = [
	{
		files          : ["**/*.{json,jsonc}"],
		languageOptions: { parser: jsoncParser },
		plugins        : {
			"jsonc"                : jsoncPlugin,
			"json-schema-validator": jsonSchemaPlugin,
		},
		rules: {
			// eslint-plugin-jsonc
			...jsoncPlugin.configs["flat/recommended-with-jsonc"].rules,
			...jsoncRules,

			// eslint-plugin-json-schema-validator
			...jsonSchemaPlugin.configs["flat/recommended"].rules,
		},
	},
	{
		files          : ["**/*.json5"],
		languageOptions: { parser: jsoncParser },
		plugins        : {
			"jsonc"                : jsoncPlugin,
			"json-schema-validator": jsonSchemaPlugin,
		},
		rules: {
			// eslint-plugin-jsonc
			...jsoncPlugin.configs["flat/recommended-with-json5"].rules,
			...jsoncRules,

			"jsonc/no-hexadecimal-numeric-literals": "off",
			"jsonc/no-plus-sign"                   : "off",
			"jsonc/valid-json-number"              : "off",

			"jsonc/comma-dangle": ["warn", "always-multiline"],
			"jsonc/quote-props" : ["warn", "consistent-as-needed"],

			// eslint-plugin-json-schema-validator
			...jsonSchemaPlugin.configs["flat/recommended"].rules,
		},
	},
	{
		files: ["package.json"],
		rules: {
			"jsonc/sort-keys": [
				"warn",
				{
					pathPattern: "^$",
					order      : [
						"name",
						"type",
						"version",
						"scripts",
						"engines",
						"packageManager",

						"bin",
						"main",
						"module",
						"browser",
						"exports",

						"private",
						"author",
						"repository",
						"homepage",
						"bugs",
						"funding",
						"license",
						"description",
						"keywords",
						"publishConfig",

						"dependencies",
						"devDependencies",
						"peerDependencies",
						"peerDependenciesMeta",
						"bundledDependencies",
						"optionalDependencies",
					],
				},
				{
					pathPattern: "^scripts.*$",
					order      : [
						{ keyPattern: "^pre:.*$" },
						{ keyPattern: "^dev.*$" },
						{ keyPattern: "^build.*$" },
						{ keyPattern: "^generate.*$" },
						{ keyPattern: "^preview.*$" },
						{ keyPattern: "^test.*$" },
						{ keyPattern: "^lint.*$" },
						{ keyPattern: "^release.*$" },
					],
				},
				{
					pathPattern: "^exports.*$",
					order      : ["import", "require", "types"],
				},
				{
					pathPattern: "^(dev|peer|bundled|optional)?[Dd]ependencies$",
					order      : { type: "asc" },
				},
			],
			"jsonc/key-spacing": ["warn", {}],
		},
	},
]
