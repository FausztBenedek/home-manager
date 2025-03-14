# Search fuzzy like in yaml files
git ls-files | grep '\\.ya\\?ml$' | while read -r file; do yq -o=properties "$file" | while read -r property; do echo "$file -- $property"; done; done | fzf --delimiter=" -- " --with-nth=2 --multi
