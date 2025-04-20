.PHONY: push

push:
	git add .
	git commit -m "Update gem" || true
	git push -f origin main

.PHONY: install
install:
	bundle install

.PHONY: build
build:
	gem build ips_qr_code.gemspec