APP = build/Glowless.app

all: build/glowlessd $(APP)

build/glowlessd: daemon/glowlessd.c
	mkdir -p build
	clang -O2 -framework IOKit -o $@ $<

$(APP): app/Glowless.swift app/Info.plist
	mkdir -p $(APP)/Contents/MacOS
	swiftc -O -o $(APP)/Contents/MacOS/Glowless app/Glowless.swift
	cp app/Info.plist $(APP)/Contents/
	codesign --force -s - $(APP)

clean:
	rm -rf build
