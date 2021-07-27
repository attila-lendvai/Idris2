INTERACTIVE ?= --interactive

.PHONY: testbin test

test: testbin
	./build/exec/runtests $(IDRIS2) $(INTERACTIVE) --only $(only)

testbin:
	$(BOOTSTRAP_IDRIS) --build tests.ipkg

clean:
	$(RM) -r build
	@find . -type f -name 'output' -exec rm -rf {} \;
	@find . -type f -name '*.ttc' -exec rm -f {} \;
	@find . -type f -name '*.ttm' -exec rm -f {} \;
	@find . -type f -name '*.ibc' -exec rm -f {} \;
