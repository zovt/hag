#!/bin/sh

echo "The index, sorted alphabetically"
echo ""

titles=$(rg \# | rg "[A-Za-z]+.md" | rg -v "Index.md")
header_1_idx=1
max_header_lvl=1
prev_header_lvl=1

echo "$titles" | sort --version-sort | while read -r line; do
		file=$(echo "$line" | cut -d':' -f1)
		header=$(echo "$line" | cut -d':' -f2)
		
		header_lvl=$(echo "$header" | tr -cd '#' | wc -c)
		if [ $header_lvl -lt $prev_header_lvl ]; then
				for i in $(seq 2 $max_header_lvl); do
						eval $(echo "header_"$i"_idx=1")
				done
				echo ""
		fi

		if [ $header_lvl -gt $max_header_lvl ]; then
				max_header_lvl=$header_lvl
				eval $(echo "header_"$header_lvl"_idx=1")
		fi

		spaces=$(seq 1 $((($header_lvl - 1) * 4)) | sed 's/.*/\ /' | tr -d '\n')
		header_clean=$(echo $header | sed 's/#\+ \?//')
		anchor=$(echo $header_clean \
								 | tr ':[A-Z]:' ':[a-z]' \
								 | tr ' ' '-' \
								 | tr -cd '[[:alnum:]-_]'
					)
		
		header_lvl_str=$(echo "\$header_"$header_lvl"_idx")
		header_idx=$(eval echo $header_lvl_str)

		echo "$spaces$header_idx. [$header_clean](./$file#$anchor)"

		eval $(echo "header_"$header_lvl"_idx=\$((\$header_idx + 1))")
		prev_header_lvl=$header_lvl
done
