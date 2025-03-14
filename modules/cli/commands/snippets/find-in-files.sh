# Find text or content in files (also exclude files)
rg --files --glob "<filename-pattern>" | grep -v "<filenames-to-exclude>" | xargs rg -n "<searched-content>"
