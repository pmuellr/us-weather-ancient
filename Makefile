# Licensed under the Apache License. See footer for details.

.PHONY: vendor

BROWSERIFY  = node_modules/.bin/browserify
COFFEE      = node_modules/.bin/coffee
COFFEEC     = $(COFFEE) --bare --compile
MODULES_DIR = www/m

#-------------------------------------------------------------------------------
help:
	@echo "available targets:"
	@echo "   watch         - watch for changes, then build, then serve"
	@echo "   build         - build the server"
	@echo "   serve         - run the server"
	@echo "   vendor        - get vendor files"
	@echo "   help          - print this help"
	@echo ""
	@echo "You will need to run 'make vendor' before duing anything useful."

#-------------------------------------------------------------------------------
watch:
	@node_modules/.bin/node-supervisor \
		--extensions    "coffee|css|html|md|png" \
		--watch         "lib-src,www-src,tools" \
		--exec          "make" \
		--no-restart-on error \
		-- build-n-serve

#-------------------------------------------------------------------------------
build-n-serve: build serve

#-------------------------------------------------------------------------------
serve:
	@echo ""
	@echo "--------------------------------------------------------------------"
	@echo "running the server"
	@echo "--------------------------------------------------------------------"

	PORT=3002 node server.js --verbose

#-------------------------------------------------------------------------------
build: make-writeable _build make-read-only

#-------------------------------------------------------------------------------
_build:
	@mkdir -p lib
	@-rm -rf  lib/*

	@$(COFFEEC) --output lib lib-src/*.coffee 

	@mkdir -p www
	@rm   -rf www/*

	@mkdir -p $(MODULES_DIR)

	@cd www-src/views; ../../$(COFFEE) ../../tools/views2module.coffee * > ../../$(MODULES_DIR)/views.js

	@$(COFFEEC) --output $(MODULES_DIR)                    www-src/modules/*.coffee 
	@$(COFFEEC) --output $(MODULES_DIR)/controllers        www-src/modules/controllers/*.coffee 
	@$(COFFEEC) --output $(MODULES_DIR)/directives         www-src/modules/directives/*.coffee 
	@$(COFFEEC) --output $(MODULES_DIR)/filters            www-src/modules/filters/*.coffee 
	@$(COFFEEC) --output $(MODULES_DIR)/services           www-src/modules/services/*.coffee 

	@$(COFFEE) tools/key2module.coffee Google-Maps-API-key.txt > $(MODULES_DIR)/Google-Maps-API-key.js

	@echo "browserifying"
	@$(BROWSERIFY) \
		--debug \
		--outfile www/index.js \
		$(MODULES_DIR)/main.js

	@$(COFFEE) tools/split-sourcemap-data-url.coffee www/index.js

	@mkdir -p www/images
	@mkdir -p www/vendor

	@cp www-src/*.*         www
	@cp www-src/images/*    www/images
	@cp -R vendor/*         www/vendor

#-------------------------------------------------------------------------------
test: build
	node lib/weather.js locations
	node lib/weather.js 27511
	node lib/weather.js 35.78, -78.8

#-------------------------------------------------------------------------------
make-writeable: 
	@-chmod -R +w www/* lib/*

#-------------------------------------------------------------------------------
make-read-only: 
	@-chmod -R -w www/* lib/*

#-------------------------------------------------------------------------------
vendor: npm-modules bower

#-------------------------------------------------------------------------------
npm-modules: 
	@rm -rf node_modules
	@npm install

#-------------------------------------------------------------------------------
bower:
	@-rm -rf  bower_components
	@-rm -rf  vendor/*
	@mkdir -p vendor

	@bower install angular\#1.2.x
	@bower install angular-route\#1.2.x
	@bower install bootstrap\#3.0.x
	@bower install font-awesome\#3.2.x

	@cp bower_components/jquery/jquery.js      vendor
	@cp bower_components/jquery/jquery.min.js  vendor
	@cp bower_components/jquery/jquery.min.map vendor

	@cp bower_components/angular/angular.js         vendor
	@cp bower_components/angular/angular.min.js     vendor
	@cp bower_components/angular/angular.min.js.map vendor

	@cp bower_components/angular-route/angular-route.js         vendor
	@cp bower_components/angular-route/angular-route.min.js     vendor
	@cp bower_components/angular-route/angular-route.min.js.map vendor

	@mkdir vendor/bootstrap
	@mkdir vendor/bootstrap/css
	@mkdir vendor/bootstrap/fonts
	@mkdir vendor/bootstrap/js

	@cp bower_components/bootstrap/dist/css/*               vendor/bootstrap/css
	@cp bower_components/bootstrap/dist/fonts/*             vendor/bootstrap/fonts
	@cp bower_components/bootstrap/dist/js/*                vendor/bootstrap/js
	@cp bower_components/bootstrap/assets/js/html5shiv.js   vendor/bootstrap/js
	@cp bower_components/bootstrap/assets/js/respond.min.js vendor/bootstrap/js

	@mkdir vendor/font-awesome
	@mkdir vendor/font-awesome/css
	@mkdir vendor/font-awesome/font

	@cp bower_components/font-awesome/css/*  vendor/font-awesome/css
	@cp bower_components/font-awesome/font/* vendor/font-awesome/font

#	@rm -rf bower_components

#-------------------------------------------------------------------------------
icons:
	@echo converting icons with ImageMagick

	@convert -resize 0016x0016 www/images/icon-0512.png www/images/icon-0016.png
	@convert -resize 0032x0032 www/images/icon-0512.png www/images/icon-0032.png
	@convert -resize 0057x0057 www/images/icon-0512.png www/images/icon-0057.png
	@convert -resize 0064x0064 www/images/icon-0512.png www/images/icon-0064.png
	@convert -resize 0072x0072 www/images/icon-0512.png www/images/icon-0072.png
	@convert -resize 0076x0076 www/images/icon-0512.png www/images/icon-0076.png
	@convert -resize 0096x0096 www/images/icon-0512.png www/images/icon-0096.png
	@convert -resize 0114x0114 www/images/icon-0512.png www/images/icon-0114.png
	@convert -resize 0120x0120 www/images/icon-0512.png www/images/icon-0120.png
	@convert -resize 0128x0128 www/images/icon-0512.png www/images/icon-0128.png
	@convert -resize 0144x0144 www/images/icon-0512.png www/images/icon-0144.png
	@convert -resize 0152x0152 www/images/icon-0512.png www/images/icon-0152.png
	@convert -resize 0256x0256 www/images/icon-0512.png www/images/icon-0256.png
	@convert -resize 1024x1024 www/images/icon-0512.png www/images/icon-1024.png

#-------------------------------------------------------------------------------
icns: icons
	@mkdir -p tmp/app.iconset
	@rm -rf   tmp/app.iconset/*

	@cp www/images/icon-0016.png tmp/app.iconset/icon_16x16.png
	@cp www/images/icon-0032.png tmp/app.iconset/icon_16x16@2x.png
	@cp www/images/icon-0032.png tmp/app.iconset/icon_32x32.png
	@cp www/images/icon-0064.png tmp/app.iconset/icon_32x32@2x.png
	@cp www/images/icon-0128.png tmp/app.iconset/icon_128x128.png
	@cp www/images/icon-0256.png tmp/app.iconset/icon_128x128@2x.png
	@cp www/images/icon-0256.png tmp/app.iconset/icon_256x256.png
	@cp www/images/icon-0512.png tmp/app.iconset/icon_256x256@2x.png
	@cp www/images/icon-0512.png tmp/app.iconset/icon_512x512.png
	@cp www/images/icon-1024.png tmp/app.iconset/icon_512x512@2x.png

	@iconutil -c icns -o www/images/app.icns tmp/app.iconset


#-------------------------------------------------------------------------------
# Copyright 2013 Patrick Mueller
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#    http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#-------------------------------------------------------------------------------

