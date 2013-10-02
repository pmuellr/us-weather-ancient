# Licensed under the Apache License. See footer for details.

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

