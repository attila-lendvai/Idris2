##### Options which a user might set before building go here #####

PREFIX ?= $(HOME)/.idris2

# Idris 1 executable that is used for bootstrapping us
BOOTSTRAP_IDRIS ?= idris-1.3.4

# Add any optimisation/profiling flags for C here (e.g. -O2)
CFLAGS := -Wall $(CFLAGS)

# clang compiles the output much faster than gcc!
CC ?= clang

##################################################################

# Make sure it's an absolute path. The 'override' is needed for the case when
# it's specified as `make BOOTSTRAP_IDRIS=foo bootstrap`, e.g. as in the nix
# build.
override BOOTSTRAP_IDRIS := $(shell command -v $(BOOTSTRAP_IDRIS) 2>/dev/null)

RANLIB ?= ranlib
AR ?= ar

LDFLAGS := $(LDFLAGS)

MACHINE := $(shell $(CC) -dumpmachine)
ifneq ($(.SHELLSTATUS), 0)
        $(error CC is not set to a valid C compiler)
else ifneq (,$(findstring cygwin, $(MACHINE)))
        OS := windows
        SHLIB_SUFFIX := .dll
else ifneq (,$(findstring mingw, $(MACHINE)))
        OS := windows
        SHLIB_SUFFIX := .dll
else ifneq (,$(findstring windows, $(MACHINE)))
        OS := windows
        SHLIB_SUFFIX := .dll
else ifneq (,$(findstring darwin, $(MACHINE)))
        OS := darwin
        SHLIB_SUFFIX := .dylib
        CFLAGS += -fPIC
else ifneq (, $(findstring bsd, $(MACHINE)))
        OS := bsd
        SHLIB_SUFFIX := .so
        CFLAGS += -fPIC
else
        OS := linux
        SHLIB_SUFFIX := .so
        CFLAGS += -fPIC
endif
