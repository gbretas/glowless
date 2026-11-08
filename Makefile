APP = build/MagSafeLED.app

all: build/magsafeledd $(APP)

build/magsafeledd: daemon/magsafeledd.c
	mkdir -p build
	clang -O2 -framework IOKit -o $@ $<

$(APP): app/MagSafeLED.swift app/Info.plist
	mkdir -p $(APP)/Contents/MacOS
	swiftc -O -o $(APP)/Contents/MacOS/MagSafeLED app/MagSafeLED.swift
	cp app/Info.plist $(APP)/Contents/
	codesign --force -s - $(APP)

clean:
	rm -rf build
