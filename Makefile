PATH := ./node_modules/.bin:${PATH}
SRC = src
DOCS = docs
COVERAGE_FILE = $(DOCS)/coverage.html
TESTS = test/*.coffee
REPORTER = dot

all: build

init:
	npm install

test:
	@NODE_ENV=test mocha \
		--compilers coffee:coffee-script/register \
		--reporter $(REPORTER) \
		--timeout 5000 \
		--growl \
		$(TESTS)

test-cov:
	@mkdir -p $(DOCS)
	@NODE_ENV=test mocha \
		--require blanket \
		--compilers coffee:coffee-script/register \
		--reporter html-cov \
		--timeout 5000 \
		--growl \
		$(TESTS) > $(COVERAGE_FILE)

docs:
	@NODE_ENV=docs codo $(SRC) --output=$(DOCS)

clean-docs:
	rm -rf $(DOCS)

clean: clean-docs
	rm -rf lib/ test/*.js

build:
	coffee --bare --compile --output lib src/ && \
	coffee --bare --compile test/

dist: clean init docs build test

publish: dist
	npm publish



.PHONY: test-cov test docs init clean-docs clean build dist publish
