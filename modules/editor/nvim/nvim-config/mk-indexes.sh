rm -rf vim-data/generated
mkdir -p vim-data/generated

# all-files.bookmarks.json
echo "[" >vim-data/generated/all-files.bookmarks.json
find . \( -type d -name .idea -prune \) -o \
	\( -type d -name target -prune \) -o \
	\( -type d -name build -prune \) -o \
	\( -type d -name node_modules -prune \) -o \
	\( -type d -name .git -prune \) -o \
	\( -type d -name localonly -prune \) -o \
	\( -type d -name out -prune \) -o \
	\( -type d -name dist -prune \) -o \
	\( -type d -name .gradle -prune \) -o \
	\( -type f -name .factorypath -prune \) -o \
	-type f -print | while read -r line; do echo "{\"name\": \"${line##*/}\", \"ref\": \"$line\"},"; done | sed '$ s/,$//' >>vim-data/generated/all-files.bookmarks.json
echo "]" >>vim-data/generated/all-files.bookmarks.json

# prod-files.bookmarks.json
echo "[" >vim-data/generated/prod-files.bookmarks.json
find . \( -type d -name .idea -prune \) -o \
	\( -type d -name target -prune \) -o \
	\( -type d -name build -prune \) -o \
	\( -type d -name node_modules -prune \) -o \
	\( -type d -name .git -prune \) -o \
	\( -type d -name localonly -prune \) -o \
	\( -type d -name out -prune \) -o \
	\( -type d -name dist -prune \) -o \
	\( -type d -name .gradle -prune \) -o \
	\( -type d -name test -prune \) -o \
	\( -type f -name .factorypath -prune \) -o \
	\( -type f -iname "*.spec.ts*" -prune \) -o \
	\( -type f -iname "*.spec.lua" -prune \) -o \
	\( -type f -iname "*Test.java" -prune \) -o \
	-type f -print | while read -r line; do echo "{\"name\": \"${line##*/}\", \"ref\": \"$line\"},"; done | sed '$ s/,$//' >>vim-data/generated/prod-files.bookmarks.json
echo "]" >>vim-data/generated/prod-files.bookmarks.json
