Forked off of soundclouder.js [![Build Status](https://api.travis-ci.org/khilnani/soundclouder.js.png?branch=master)](https://travis-ci.org/khilnani/soundclouder.js)
===============

Provides seamless modular support for working with SoundCloud and Nodejs


SoundCloud APIs Implemented
===============
- Connection/Authorization Url
- OAuth Authorization (/oauth2/token)
- General GET, PUT, POST and DELETE.

Usage
==============

<pre>
var SoundCloudAPI = require("soundcloud-node");

// instantiate the client
var client = SoundCloudAPI(client_id, client_secret, redirect_uri);

// redirect to the url
var oauthInit = function(req, res) {
	var url = client.getConnectUrl();

    res.writeHead(301, Location: url);
    res.end();
}

var oauthHandleToken = function(req, res) {
	var query = req.query;

	client.getToken(query.code, function(err, tokens) {
        if (err)
            callback(err);
        else {
            callback(null, res);
        }
    });
}
</pre>
<pre>
client.get('/tracks/' + track_id, function (data) {
	console.log( data.title );
});
</pre>


Links
============
- Application Setup - http://developers.soundcloud.com/docs/api/guide#authentication
- Error Codes - http://developers.soundcloud.com/docs/api/guide#errors


Installation
============

Global
--------- 
- Run: <code>sudo npm install soundcloud-node -g</code>
- Usually installed at - /usr/local/lib/node_modules/soundcloud-node
