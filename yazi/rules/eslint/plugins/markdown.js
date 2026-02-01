import markdown from "@eslint/markdown"
import tseslint from "typescript-eslint"

/** @type { import('eslint').Linter.Config[] } */
export const markdownConfig = [
	...markdown.configs.recommended,
	{
		files          : ["**/*.md/*.{js,jsx}"],
		languageOptions: {
			parserOptions: {
				ecmaFeatures: { impliedStrict: true },
			},
		},
	},
	{
		files  : ["**/*.md/*.{ts,tsx}"],
		plugins: {
			"@typescript-eslint": tseslint.plugin,
		},
	},
]

// Export as 'markdown' for backwards compatibility with index.js
export { markdownConfig as markdown }
