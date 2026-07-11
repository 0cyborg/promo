.PHONY: test

test:
	cd docs && python3 -m http.server 8090; cd -
