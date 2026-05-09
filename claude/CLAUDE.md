
## new files encoding
1. When you create a new Markdown file, save it as UTF-8 with BOM, and ensure trailing newline.  In maths, use the true Unicode minus (not hyphen-minus) where appropriate.
2. When, on the other hand, you create a file with executable logic (a source code file): make an additional pass to remove all unnecessary Unicode characters if possible to replace them with ASCII or omit completely.
3. Judiciously apply the above rules to new edits in existing files as well.
