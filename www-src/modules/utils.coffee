# Licensed under the Apache License. See footer for details.

window.utils = {}

#-------------------------------------------------------------------------------
utils.dump = (text) ->
    $log = $ "#log"
    $log.text text
    $log.show()

#-------------------------------------------------------------------------------
utils.log = (text) ->
    $log = $ "#log"
    $log.text "#{$log.text()}\n#{text}"
    $log.show()

#-------------------------------------------------------------------------------
watchWindowResizing = ->
    timeout = null

    #----------------------------------
    fireResizingComplete = ->
        $window = $(window)
        event = new CustomEvent "window-resizing-complete", 
            detail:
                width:  $window.width()
                height: $window.height()

        window.dispatchEvent event

    #----------------------------------
    $(window).resize ->
        clearTimeout(timeout) if timeout
        timeout = setTimeout(fireResizingComplete, 500)

#-------------------------------------------------------------------------------
watchWindowResizing()

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
