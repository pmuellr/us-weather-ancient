# Licensed under the Apache License. See footer for details.

main = exports

utils  = require "./utils"

main.mod = angular.module "app", ["ngRoute"]

require("./controllers/AddController")      main.mod
require("./controllers/BodyController")     main.mod
require("./controllers/HelpController")     main.mod
require("./controllers/HomeController")     main.mod
require("./controllers/MessagesController") main.mod
require("./controllers/SettingsController") main.mod
require("./directives/WChart")              main.mod
require("./filters/LogTime")                main.mod
require("./services/LogService")            main.mod
require("./services/LocationsService")      main.mod
require("./routes")                         main.mod

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
