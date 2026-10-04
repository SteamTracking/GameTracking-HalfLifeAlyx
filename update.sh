#!/bin/bash
set -euo pipefail

cd "${0%/*}"
. ../common.sh

echo "Processing Half-Life: Alyx..."

EXIT_CODE=0

ProcessDepot ".dll"
ProcessVPK

echo "::group::Extracting VPKs"

while IFS= read -r -d '' file
do
	echo " $file"

	# When updating vpk_extensions, also update "vpk:..." in files.json
	"$VRF_PATH" \
		--input "$file" \
		--output "$(echo "$file" | sed -e 's/\.vpk$/\//g')" \
		--vpk_cache \
		--vpk_decompile \
		--vpk_extensions "txt,lua,kv3,db,gameevents,res,cfg,vcss_c,vjs_c,vts_c,vxml_c,vsndevts_c,vsndstck_c,vpulse_c,vdata_c" \
		|| EXIT_CODE=$?
done <   <(find . -type f -name "pak01_dir.vpk" -print0)

echo "::endgroup::"

while IFS= read -r -d '' file
do
	sed -i '/\/\/# sourceMappingURL=/d' "$file"
done <   <(find . -type f -name "*.js" -print0)

ProcessToolAssetInfo
FixUCS2

CreateCommit "$(grep -o '[0-9\.]*' steam_buildid.txt)" "$(grep -o '[0-9\.]*' steam_buildid.txt)"

echo "Done"

exit "$EXIT_CODE"
