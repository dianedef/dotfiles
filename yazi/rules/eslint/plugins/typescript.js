import eslint from "@eslint/js"
import tseslint from "typescript-eslint"

import { jsRules } from "./javascript.js"

/** @type { import('eslint').Linter.Config[] } */
export const typescript = [
	{
		files          : ["**/*.{ts,tsx,cts,mts}"],
		languageOptions: {
			parser       : tseslint.parser,
			parserOptions: { projectService: true },
		},
		linterOptions: {
			reportUnusedDisableDirectives: "error",
		},
		plugins: {
			"@typescript-eslint": tseslint.plugin,
		},
		rules: {
			...eslint.configs.recommended.rules,
			...tseslint.configs.eslintRecommended.rules,
			...tseslint.configs.recommended.reduce((acc, cfg) => ({ ...acc, ...cfg.rules }), {}),
			...tseslint.configs.recommendedTypeChecked.reduce((acc, cfg) => ({ ...acc, ...cfg.rules }), {}),

			...jsRules,
			"@typescript-eslint/ban-ts-comment"       : "off",
			"@typescript-eslint/no-non-null-assertion": "off",
		},
	},
]
