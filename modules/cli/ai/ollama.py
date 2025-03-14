import sys

# Read the input from stdin
replacement_text = sys.stdin.read().strip()

# Read the file content
# TODO adjust path
with open('/Users/benedekfauszt/.config/home-manager/modules/cli/ai/check-grammar-prompt.txt', 'r') as file:
    content = file.read()

# Replace {{text}} with the input from stdin
updated_content = content.replace('{{text}}', replacement_text)


# Output the result to stdout
print(updated_content)
