# Usage: ./mermaid-watch.sh <file.mmd>
set -euo pipefail

MMD_FILE="${1:-example.mermaid}"
[[ -f "$MMD_FILE" ]] && echo "Serveing file, edit with the following command:" || {
	cat "$MMDC_EXEMPLE_FILE" >"$MMD_FILE"
	echo "File created, edit with the following command:"
}
echo "$EDITOR $(pwd)/$MMD_FILE"

command -v mmdc &>/dev/null || {
	echo "mmdc not found. Run: npm install -g @mermaid-js/mermaid-cli"
	exit 1
}
command -v fswatch &>/dev/null || {
	echo "fswatch not found. Run: brew install fswatch  OR  sudo apt install fswatch"
	exit 1
}

MMD_FILE="$(cd "$(dirname "$MMD_FILE")" && pwd)/$(basename "$MMD_FILE")"
SVG_FILE="${MMD_FILE%.mmd}.svg"
HTML_FILE="${MMD_FILE%.mmd}.html"

render() {
	echo "⟳  Rendering…"
	if mmdc -i "$MMD_FILE" -o "$SVG_FILE" -p "$MMDC_PUPPETEER_CONFIG" 2>/tmp/mmdc_err; then
		SVG_CONTENT="$(cat "$SVG_FILE")"
		cat >"$HTML_FILE" <<HTML
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta http-equiv="refresh" content="1">
  <style>
    body { margin: 0; display: flex; justify-content: center; align-items: center; min-height: 100vh; background: #f8f8f8; }
    svg  { max-width: 95vw; max-height: 95vh; }
  </style>
</head>
<body>
$SVG_CONTENT
</body>
</html>
HTML
		echo "✓  Done → $HTML_FILE"
	else
		echo "✗  mmdc error:"
		cat /tmp/mmdc_err >&2
	fi
}

render

# Open browser on first run
if command -v open &>/dev/null; then
	open "$HTML_FILE" # macOS
elif command -v xdg-open &>/dev/null; then
	xdg-open "$HTML_FILE" # Linux
fi

echo "Watching $MMD_FILE  (Ctrl-C to stop)"
fswatch -o "$MMD_FILE" | while read -r; do render; done
