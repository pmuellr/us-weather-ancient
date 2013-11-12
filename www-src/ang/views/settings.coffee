# Licensed under the Apache License. See footer for details.

AngTangle.controller settings = ($scope, Logger) ->
    $scope.setSubtitle "settings"

    $scope.appCache = 
        abort:     -> wrapped Logger, "abort"
        update:    -> wrapped Logger, "update"
        swapCache: -> wrapped Logger, "swapCache"
        reload:    -> window.location.reload(true)
        nuclear:   -> 
            wrapped Logger, "update"
            setTimeout (-> wrapped Logger, "swapCache"),  5000
            setTimeout (-> window.location.reload(true)), 7000
    return

#-------------------------------------------------------------------------------
wrapped = (Logger, name) ->
    try 
        window.applicationCache[name]()
    catch e
        Logger.log "excepting running window.applicationCache.#{name}(): #{e}"


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
