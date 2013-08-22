# Licensed under the Apache License. See footer for details.

.PHONY: vendor

BROWSERIFY = node_modules/.bin/browserify
COFFEE     = node_modules/.bin/coffee
COFFEEC    = $(COFFEE) --bare --compile

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
		--extensions    "coffee|js|css|html|md|png" \
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

	node server.js --verbose

#-------------------------------------------------------------------------------
build:
	@rm   -rf tmp/modules
	@mkdir -p tmp/modules

	@cd www-src/views; ../../$(COFFEE) ../../tools/views2module.coffee * > ../../tmp/modules/views.js

	@-rm -rf  lib/*
	@mkdir -p lib

	@echo "compiling coffee files"
	@$(COFFEEC) --output lib                            lib-src/*.coffee 
	@$(COFFEEC) --output tmp/modules                    www-src/modules/*.coffee 
	@$(COFFEEC) --output tmp/modules/controllers        www-src/modules/controllers/*.coffee 
	@$(COFFEEC) --output tmp/modules/directives         www-src/modules/directives/*.coffee 
	@$(COFFEEC) --output tmp/modules/filters            www-src/modules/filters/*.coffee 
	@$(COFFEEC) --output tmp/modules/services           www-src/modules/services/*.coffee 

	@echo "browserifying"
	@$(BROWSERIFY) \
		--debug \
		--outfile www/index.js \
		tmp/modules/main.js

	@$(COFFEE) tools/split-sourcemap-data-url.coffee www/index.js

#-------------------------------------------------------------------------------
test: build
	node lib/weather.js locations
	node lib/weather.js 27511
	node lib/weather.js 35.78, -78.8

#-------------------------------------------------------------------------------
vendor: 
	@rm -rf node_modules
	@npm install

	@-rm -rf  bower_components
	@-rm -rf  vendor/*
	@mkdir -p vendor

	@bower install bootstrap\#2.3.x
	@bower install angular\#1.0.x
	@bower install font-awesome\#3.2.x

	@cp bower_components/jquery/jquery.js    vendor
	@cp bower_components/angular/angular.js  vendor

	@mkdir vendor/bootstrap
	@mkdir vendor/bootstrap/css
	@mkdir vendor/bootstrap/img
	@mkdir vendor/bootstrap/js

	@cp bower_components/bootstrap/docs/assets/css/bootstrap*.css   vendor/bootstrap/css
	@cp bower_components/bootstrap/docs/assets/img/glyphicons-*.png vendor/bootstrap/img
	@cp bower_components/bootstrap/docs/assets/js/bootstrap.js      vendor/bootstrap/js

	@mkdir vendor/font-awesome
	@mkdir vendor/font-awesome/css
	@mkdir vendor/font-awesome/font

	@cp bower_components/font-awesome/css/font-awesome-ie7.css vendor/font-awesome/css
	@cp bower_components/font-awesome/css/font-awesome.css     vendor/font-awesome/css
	@cp bower_components/font-awesome/font/*                   vendor/font-awesome/font

	@rm -rf bower_components


#-------------------------------------------------------------------------------
icons:
	@echo converting icons with ImageMagick

	@convert -resize 032x032 www/images/icon-512.png www/images/icon-032.png
	@convert -resize 057x057 www/images/icon-512.png www/images/icon-057.png
	@convert -resize 064x064 www/images/icon-512.png www/images/icon-064.png
	@convert -resize 072x072 www/images/icon-512.png www/images/icon-072.png
	@convert -resize 096x096 www/images/icon-512.png www/images/icon-096.png
	@convert -resize 114x114 www/images/icon-512.png www/images/icon-114.png
	@convert -resize 128x128 www/images/icon-512.png www/images/icon-128.png
	@convert -resize 144x144 www/images/icon-512.png www/images/icon-144.png
	@convert -resize 256x256 www/images/icon-512.png www/images/icon-256.png

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

