us-weather
================================================================================

node library and server/web app providing weather data from 
<http://graphical.weather.gov/xml/rest.php>



installation
--------------------------------------------------------------------------------

After `git clone`ing this project, you will need to run:

* `npm install`
* `grunt build`

So, you'll need to have `grunt` installed globally, available via `npm`.
See <http://gruntjs.com/> for more information.



usage
--------------------------------------------------------------------------------

To run the server, you can run one of

    npm start
    node server
    node lib/cli

Set the HTTP port, Google Maps API key, etc, via command-line
switches, environment variables, and JSON config files.  Run `node server ?`
for more information.

For more information on obtaining a Google Maps API Key, see the
[Google Maps JavaScript API v3 Getting Started documentation](https://developers.google.com/maps/documentation/javascript/tutorial#api_key).



hacking
--------------------------------------------------------------------------------

Run `jbuild watch` to run the build workflow such that when a source file
changes, the server will be rebuilt and relaunched.



license
--------------------------------------------------------------------------------

Licensed under [the Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0.html)