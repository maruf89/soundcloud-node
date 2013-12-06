https = require("https")
qs = require("querystring")
host_api = "api.soundcloud.com"
host_connect = "https://soundcloud.com/connect"

###*
 * Returns the config data needed to build a connect url
 *
 * @private
 * @return {Object}  The required data
###
_getConfig = ->
    client_id: @client_id
    client_secret: @client_secret
    redirect_uri: @redirect_uri
    response_type: 'code'
    scope: 'non-expiring'

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
    requestData =
        method: method.toUpperCase()
        uri: host_api

    if path[0] isnt '/' then path = '/' + path

    requestData.path = path

    if typeof params is "function"
        callback = params
        params = null

    params = params or format: "json"

    params.oauth_token = @access_token

    requestData.params = params

    _request.call @,
        method: method
        uri: host_api
        path: path
        qs: params
    , callback

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
            "Content-Length": qsdata.length

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
     * @param {String} client_id
     * @param {String} client_secret
     * @param {String} redirect_uri
    ###
    constructor: (client_id, client_secret, redirect_uri) ->

        if not (@ instanceof SoundCloud) then return new SoundCloud(client_id, client_secret, redirect_uri)

        required = []

        [].slice.call(arguments).forEach (arg) ->
            required.push(arg) if not arg?

        if required.length
            console.log 'The following arguments are required: ', required
            return false

        @client_id = client_id
        @client_secret = client_secret
        @redirect_uri = redirect_uri

    ###
     * Get the url to SoundCloud's authorization/connection page.
     *
     * @param {Object} options
     * @return {String}
    ###
    getConnectUrl: (options) ->
        options = _getConfig.call(@) if not options

        host_connect + "?" + ((if options then qs.stringify(options) else ""))

    setToken: (@access_token) ->

    ###
     * Perform authorization with SoundCLoud and obtain OAuth token needed
     *
     * for subsequent requests. See http://developers.soundcloud.com/docs/api/guide#authentication
     *
     * @param {String} code sent by the browser based SoundCloud Login that redirects to the redirect_uri
     * @param {Function} callback(error, access_token) No token returned if error != null
    ###
    getToken: (code, callback) ->
        options =
            uri: host_api
            path: "/oauth2/token"
            method: "POST"
            params:
                client_id: @client_id
                client_secret: @client_secret
                grant_type: "authorization_code"
                redirect_uri: @redirect_uri
                code: code

        _request.apply(@, [options, callback])

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