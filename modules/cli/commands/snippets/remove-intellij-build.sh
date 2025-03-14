# Remove /out directory that intellij puts the java build into
find . -name "out" -type d -not -path "*/node_modules/*" | while read -r outdir; do rm -rf $outdir; done
