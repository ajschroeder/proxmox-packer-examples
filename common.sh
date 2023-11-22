follow_link() {
	FILE="$1"
	while [ -h "$FILE" ]; do
		# On macOS, readlink -f doesn't work.
		FILE="$(readlink "$FILE")"
	done
	echo "$FILE"
}

