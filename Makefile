SRC = src
TESTS = test/*.coffee
REPORTER = dot

all: test

test:
	@NODE_ENV=test ./node_modules/.bin/mocha \
		--compilers coffee:coffee-script/register \
		--reporter $(REPORTER) \
		--timeout 5000 \
		--growl \
		$(TESTS)

test-cov:
	@NODE_ENV=test ./node_modules/.bin/mocha \
		--require blanket \
		--compilers coffee:coffee-script/register \
		--reporter html-cov \
		--timeout 5000 \
		--growl \
		$(TESTS) > coverage.html

docs:
	@NODE_ENV=docs ./node_modules/.bin/codo $(SRC)



.PHONY: test-cov test docs
