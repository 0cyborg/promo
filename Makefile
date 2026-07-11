.PHONY: test lfs-check

test:
	cd docs && python3 -m http.server 8090; cd -

lfs-check:
	@echo "Checking that release binaries are stored via Git LFS..."
	@bad=0; \
	for f in $$(git ls-files -- ':(glob)docs/*/releases/**'); do \
		size=$$(git cat-file -s ":$$f" 2>/dev/null || echo 0); \
		if [ "$$size" = "0" ]; then \
			continue; \
		fi; \
		if ! git show ":$$f" 2>/dev/null | head -c 200 | grep -q "^version https://git-lfs.github.com/spec/v1"; then \
			echo "  NOT an LFS pointer: $$f"; \
			bad=1; \
		fi; \
	done; \
	if [ "$$bad" = "1" ]; then \
		echo "error: one or more release files are committed as raw blobs instead of LFS pointers" >&2; \
		echo "check .gitattributes covers the path, then re-add the file (or 'git lfs migrate import' if already committed)" >&2; \
		exit 1; \
	fi; \
	echo "OK - all tracked release files are LFS pointers."
