# Licensed under the Apache License. See footer for details.

views = require "./views"

#-------------------------------------------------------------------------------
module.exports = (mod) ->

    url_html = (name) -> ["/#{name}", "#{name}.html"]

    routes = 
        Home:       ["/",    "home.html"]
        Add:        url_html "add"
        Messages:   url_html "messages"
        Settings:   url_html "settings"
        Help:       url_html "help"

    #---------------------------------------------------------------------------
    mod.config ($routeProvider) ->

        $routeProvider.otherwise 
            redirectTo:  "/"

        for controller, [url, html] of routes
            $routeProvider.when url, 
                controller:  controller
                template:    views[html]

        return

    return

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
