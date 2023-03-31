.PHONY: all clean build deploy docker-test

REDBEAN=redbean.com
REDBEAN_VERSION=2.2
# leave empty for default, or use one of tiny-, asan-, original-, static-, unsecure-, original-tinylinux-
REDBEAN_MODE=asan-
REDBEAN_DL=https://redbean.dev/redbean-${REDBEAN_MODE}${REDBEAN_VERSION}.com

ZIP=zip.com
ZIP_DL=https://redbean.dev/zip.com

FULLMOON_DL=https://raw.githubusercontent.com/pkulchenko/fullmoon/ec21400d166794f5887c22f0f9a122fcc320610d/fullmoon.lua
FULLMOON=fullmoon.lua

FENNEL_VERSION=1.3.0
FENNEL_DL=https://fennel-lang.org/downloads/fennel-${FENNEL_VERSION}.tar.gz
FENNEL_ARC=fennel-${FENNEL_VERSION}.tar.gz
FENNEL=fennel.lua

NPD=--no-print-directory

all: download build

download: deps/${REDBEAN} deps/${ZIP}

build: out/anime-app.com out/root-app.com

deploy:
	fly deploy

docker-test: build
	docker run -p 8080:8080 -it $$(docker build -q .)

clean:
	rm -rf out build deps

deps/${REDBEAN}:
	mkdir -p deps
	curl -s ${REDBEAN_DL} -o $@ -z $@ && \
		chmod +x $@

deps/${ZIP}:
	mkdir -p deps
	curl -s ${ZIP_DL} -o $@ -z $@
	chmod +x $@

deps/${FULLMOON}:
	mkdir -p deps
	curl -s ${FULLMOON_DL} -o $@ -z $@
	chmod +x $@

deps/${FENNEL}:
	mkdir -p deps
	curl -s ${FENNEL_DL} -o deps/fennel-${FENNEL_VERSION}.tar.gz -z deps/fennel-${FENNEL_VESRION}.tar.gz
	cd deps/ && tar -xvf fennel-${FENNEL_VERSION}.tar.gz
	cp deps/fennel-${FENNEL_VERSION}/fennel.lua $@
	chmod +x $@

build/anime/anime-app.com: deps/${ZIP} deps/${FULLMOON} deps/${REDBEAN} deps/${FENNEL} src/anime/*.lua src/anime/*.fnl
	mkdir -p build/anime/.lua
	cp src/anime/app.lua build/anime/.init.lua && \
		cp src/anime/app.fnl build/anime/.lua/app.fnl && \
		cp deps/${REDBEAN} build/anime/anime-app.com && \
		cp deps/${FULLMOON} build/anime/.lua/${FULLMOON} && \
		cp deps/${FENNEL} build/anime/.lua/${FENNEL} && \
		cd build/anime && \
		sh ../../deps/${ZIP} -r anime-app.com .*.lua .lua

out/anime-app.com: build/anime/anime-app.com
	mkdir -p out
	cp build/anime/anime-app.com out/anime-app.com

build/cubes/root-app.com: deps/${REDBEAN} deps/${ZIP}
	mkdir -p build/cubes
	cp -r src/cubes/* build/cubes/ && \
		cp deps/${REDBEAN} build/cubes/root-app.com && \
		cd build/cubes && \
		sh ../../deps/${ZIP} -r root-app.com ./*.js ./*.html ./*.ico

out/root-app.com: build/cubes/root-app.com
	mkdir -p out
	cp build/cubes/root-app.com out/root-app.com
