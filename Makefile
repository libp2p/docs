SHELL=/bin/bash
DOMAIN="docs.libp2p.io"

IPFSLOCAL="http://localhost:8080/ipfs/"
IPFSGATEWAY="https://ipfs.io/ipfs/"
NPM=npm
NPMBIN=./node_modules/.bin
OUTPUTDIR=public
PKGDIR=content/reference/pkg
PORT=1313

ifeq ($(DEBUG), true)
	PREPEND=
	APPEND=
else
	PREPEND=@
	APPEND=1>/dev/null
endif

# Where Hugo should be installed locally
HUGO_LOCAL=./bin/hugo
# Path to Hugo binary to use when building the site
HUGO_BINARY=$(HUGO_LOCAL)
HUGO_VERSION=0.99.1
PLATFORM:=$(shell uname)
ifeq ('$(PLATFORM)', 'Darwin')
	PLATFORM=macOS
endif
MACH:=$(shell uname -m)
ifeq ('$(MACH)', 'x86_64')
	MACH=64bit
else ifeq ('$(MACH)', 'arm64')
    MACH=ARM64
else
	MACH=32bit
endif
HUGO_URL="https://github.com/gohugoio/hugo/releases/download/v$(HUGO_VERSION)/hugo_$(HUGO_VERSION)_$(PLATFORM)-$(MACH).tar.gz"


bin/hugo:
	@echo "Installing Hugo to $(HUGO_LOCAL)..."
	$(PREPEND)mkdir -p tmp_hugo $(APPEND)
	$(PREPEND)curl --location "$(HUGO_URL)" | tar -xzf - -C tmp_hugo && chmod +x tmp_hugo/hugo && mv tmp_hugo/hugo $(HUGO_LOCAL) $(APPEND)
	$(PREPEND)rm -rf tmp_hugo $(APPEND)

install: bin/hugo

build: clean install
	$(PREPEND)$(HUGO_BINARY) && \
	echo "" && \
	echo "Site built out to ./$(OUTPUTDIR)"

dev: bin/hugo
	$(PREPEND)( \
		$(HUGO_BINARY) server -w --port $(PORT) --bind 0.0.0.0 \
	)

serve:
	$(PREPEND)$(HUGO_BINARY) server

deploy:
	export hash=`ipfs add -r -Q $(OUTPUTDIR)`; \
		echo ""; \
		echo "published website:"; \
		echo "- $(IPFSLOCAL)$$hash"; \
		echo "- $(IPFSGATEWAY)$$hash"; \
		echo ""; \
		echo "next steps:"; \
		echo "- ipfs pin add -r /ipfs/$$hash"; \
		echo "- make publish-to-domain"

clean:
	$(PREPEND)[ ! -d $(OUTPUTDIR) ] || rm -rf $(OUTPUTDIR)
	$(PREPEND)[ ! -d $(PKGDIR) ] || rm -rf $(PKGDIR)/*/
	$(PREPEND)[ ! -d build/assets ] || rm -rf build/assets/*

.PHONY: build help deploy publish-to-domain clean
