Soundcloud-node
===============

Provides seamless modular support for working with SoundCloud and Nodejs

Enhanced so you need to do less


SoundCloud APIs
===============
- Connection + Authorize User
- OAuth Authorization
- General GET, PUT, POST and DELETE request

Usage
==============

<pre>
var SoundCloudAPI = require("soundcloud-node");

// instantiate the client
var client = SoundCloudAPI(client_id, client_secret, redirect_uri);

// Connect User
var oauthInit = function(req, res) {
	var url = client.getConnectUrl();

    res.writeHead(301, Location: url);
    res.end();
};

// Get OAuth Token
var oauthHandleToken = function(req, res) {
	var query = req.query;

	client.getToken(query.code, function(err, tokens) {
        if (err)
            callback(err);
        else {
            callback(null, res);
        }
    });
};
</pre>
<pre>
client.get('/tracks/' + track_id, function (data) {
	console.log( data.title );
});
</pre>


Support
============
- Application Setup - http://developers.soundcloud.com/docs/api/guide#authentication
- Error Codes - http://developers.soundcloud.com/docs/api/guide#errors


To Install
============

NPM
---------
- Run: <code>sudo npm install soundcloud-node -g</code>

Github
---------
- Run: <code>git clone git@github.com:maruf89/soundcloud-node.git</code>

Extra
============
Forked off of soundclouder.js [![Build Status](https://api.travis-ci.org/khilnani/soundclouder.js.png?branch=master)](https://travis-ci.org/khilnani/soundclouder.js)


