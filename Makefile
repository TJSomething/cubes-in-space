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

build/anime/anime-app.com: deps/${REDBEAN} deps/${ZIP} deps/${FULLMOON}
	mkdir -p build/anime
	cp src/anime/app.lua build/anime/.init.lua && \
		cp deps/${REDBEAN} build/anime/anime-app.com && \
		mkdir -p build/anime/.lua && \
		cp deps/${FULLMOON} build/anime/.lua/${FULLMOON} && \
		cd build/anime && \
		sh ../../deps/${ZIP} -r anime-app.com .init.lua .lua

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
