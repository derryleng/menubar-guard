BINARY  = menubar-guard
PREFIX ?= /usr/local/bin

.PHONY: build install uninstall clean

build:
	clang -O2 -o $(BINARY) main.c \
		-framework ApplicationServices \
		-framework CoreFoundation

install: build
	install -m 755 $(BINARY) $(PREFIX)/$(BINARY)
	@echo "Installed to $(PREFIX)/$(BINARY)"

uninstall:
	rm -f $(PREFIX)/$(BINARY)

clean:
	rm -f $(BINARY)
