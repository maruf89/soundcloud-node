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

Get OAuth token
---------------
<pre>
var SoundCloudAPI = require("soundcloud-node");

// instantiate the client
var client = new SoundCloudAPI(client_id, client_secret, redirect_uri);

// Connect User - Assuming you are using Express 
var oauthInit = function(req, res) {
    var url = client.getConnectUrl();

    res.writeHead(301, url);
    res.end();
};

// Get OAuth Token
// callback function from the connect url
var oauthHandleToken = function(req, res) {
    var query = req.query;

    client.getToken(query.code, function(err, tokens) {
        if (err)
            callback(err);
        else {
            callback(null, tokens);
        }
    });
};

//  By default upon authentication, the access_token is saved, but you can add it like
client.setToken(access_token);
</pre>

Get User
--------
After authenticating you can easily get the user object
<pre>
var user_id;

var getUser = client.getMe(function(err, user) {
    user_id = user.id;

    //  Then you can set it to the API like
    client.setUser(user_id);
});


</pre>

Initiate Client with OAuth Token
--------------------------------
<pre>
//  You can pass in credentials with either or both values, but 
//  you will need the access_token make authenticated requests
var credentials = {
    access_token: "{ACCESS_TOKEN}",
    user_id: "{USER_ID}"
};

client = new SoundCloudAPI(client_id, client_secret, redirect_uri, credentials);
</pre>


Get users favorite tracks
-------------------------
<pre>
client.get('/users/273281/favorites', function (data) {
    console.log(data.title);
});
</pre>
Or if the user id is set, it will automatically parse {id} into your user_id
<pre>
client.get('/users/{id}/favorites', function (data) {
    console.log(data.title);
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
- Run: <code>npm install soundcloud-node -g</code>

Github
---------
- Run: <code>git clone git@github.com:maruf89/soundcloud-node.git</code>

Extra
============
Forked off of soundclouder.js [![Build Status](https://api.travis-ci.org/khilnani/soundclouder.js.png?branch=master)](https://travis-ci.org/khilnani/soundclouder.js)


