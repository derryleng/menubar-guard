BINARY  = menubar-guard
PREFIX ?= /usr/local/bin

.PHONY: build install uninstall clean

build:
	swiftc -O -o $(BINARY) main.swift -framework Cocoa

install: build
	install -m 755 $(BINARY) $(PREFIX)/$(BINARY)
	@echo "Installed to $(PREFIX)/$(BINARY)"

uninstall:
	rm -f $(PREFIX)/$(BINARY)

clean:
	rm -f $(BINARY)
