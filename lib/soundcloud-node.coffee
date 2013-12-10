https = require("https")
qs = require("querystring")

#  API Variables
host_api = 'api.soundcloud.com'
host_connect = 'https://soundcloud.com/connect'

#  Keep these private
client_id = null
client_secret = null
redirect_uri = null
access_token = null
user_id = null

###*
 * Returns the config data needed to build a connect url
 *
 * @private
 * @return {Object}  The required data
###
_getConfig = ->
    client_id: client_id
    client_secret: client_secret
    redirect_uri: redirect_uri
    response_type: 'code'
    scope: 'non-expiring'

###*
 * Return the current user_id value
 * @return {Number} 
###
_user_id = -> user_id

###*
 * Mixin variables with their respective
 * @type {[type]}
###
variables =
    '{id}': _user_id

_applyVariables = (path) ->
    path = path.replace(pattern, value()) for pattern, value of variables
    return path

###*
 * Builds the query to be ready for the request
 *
 * @private
 * @param  {String}   method       GET, POST, PUT or DELETE
 * @param  {String}   path         The query path
 * @param  {Object}   params
 * @param  {Function} callback
###
_setupRequest = (method, path, params, callback = ->) ->

    return callback(message: 'access_token is required.', null) if not access_token?

    requestData =
        method: method.toUpperCase()
        uri: host_api

    if path[0] isnt '/' then path = '/' + path

    requestData.path = _applyVariables(path)

    if typeof params is "function"
        callback = params
        params = null

    params = params or format: 'json'

    params.oauth_token = access_token

    requestData.params = params

    _request.apply(@, [requestData, callback])

###*
 * The function that does the actual query to SoundCloud
 *
 * @private
 * @param  {Object}   data     The request data
 * @param  {Function} callback
###
_request = (data, callback) ->
    params = qs.stringify(data.params)

    options =
        hostname: data.uri
        path: "#{data.path}?#{params}"
        method: data.method

    if data.method is "POST"
        options.path = data.path
        options.headers =
            "Content-Type": "application/x-www-form-urlencoded"
            "Content-Length": params.length

    req = https.request options, (response) ->
        body = ""

        response.on "data", (chunk) ->
            body += chunk

        response.on "end", ->
            try
                data = JSON.parse(body)

                # See http://developers.soundcloud.com/docs/api/guide#errors for full list of error codes
                unless response.statusCode is 200
                    callback data.errors, data
                else
                    callback null, data
            catch err
                callback err

    req.on "error", (err) ->
        callback err

    if data.method is "POST"
        req.write params
    req.end()

###*
 * @class
 * @namespace SoundCloud
###
module.exports = class SoundCloud

    ###
     * Initialize with client id, client secret and redirect url.
     *
     * @constructor
     * @param {String}  client_id
     * @param {String}  client_secret
     * @param {String}  redirect_uri
     * @param {Object=} credentials  Optional object with access_token and/or user_id
    ###
    constructor: (id, secret, uri, credentials) ->

        if not (@ instanceof SoundCloud) then return new SoundCloud(id, secret, uri, credentials)

        required = []

        [].slice.call(arguments, 0, -1).forEach (arg) ->
            required.push(arg) if not arg?

        if required.length
            console.log 'The following arguments are required: ', required
            return false

        client_id     = id
        client_secret = secret
        redirect_uri  = uri

        if credentials
            @setToken(credentials.access_token) if credentials.access_token
            @setUser(credentials.user_id) if credentials.user_id

    ###
     * Get the url to SoundCloud's authorization/connection page.
     *
     * @param {Object} options
     * @return {String}
    ###
    getConnectUrl: (options) ->
        options = _getConfig.call(@) if not options

        host_connect + "?" + ((if options then qs.stringify(options) else ""))

    setToken: (token) ->
        access_token = token

    setUser: (id) ->
        user_id = id

    ###
     * Using the provided code from the successful SoundCloud connect page, we send that
     * back to soundcloud to get the access_token, and we save it if it returns successful
     *
     * @param {String} code        code returned by SoundCloud
     * @param {Function} callback  provides (error, response)
    ###
    getToken: (code, callback) ->
        options =
            uri: host_api
            path: "/oauth2/token"
            method: "POST"
            params:
                client_id: client_id
                client_secret: client_secret
                grant_type: "authorization_code"
                redirect_uri: redirect_uri
                code: code

        _request.apply(@, [options, (err, resp) =>
            @setToken(resp.access_token) if resp.access_token
            callback.apply(this, arguments)
        ])

    getMe: (callback) ->        
        @get('me.json', callback)

    ###
     * Make an API call
     *
     * @param {String} path
     * @param {Object} params
     * @param {Function} callback(error, data)
    ###
    get: (path, params, callback) ->
        _setupRequest.apply(@, ["GET", path, params, callback])

    post: (path, params, callback) ->
        _setupRequest.apply(@, ["POST", path, params, callback])

    put: (path, params, callback) ->
        _setupRequest.apply(@, ["PUT", path, params, callback])

    delete: (path, params, callback) ->
        _setupRequest.apply(@, ["DELETE", path, params, callback])