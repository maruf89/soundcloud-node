https = require("https")
qs = require("querystring")
log = require("dysf.utils").logger
host_api = "api.soundcloud.com"
host_connect = "https://soundcloud.com/connect"

_getConfig = ->
    client_id: @client_id
    client_secret: @client_secret
    redirect_uri: @redirect_uri
    response_type: 'code'
    scope: 'non-expiring'

_makeCall = (method, path, access_token, params, callback) ->

    if path and path.indexOf("/") is 0

        if typeof (params) is "function"
            callback = params
            params = {}

        callback = callback or ->

        params = params or
            oauth_token: access_token
            format: "json"

        _request.call @,
            method: method
            uri: host_api
            path: path
            qs: params
        , callback

    else
        callback(message: "Invalid path: " + path)
        false

_request = (data, callback) ->
    qsdata = (if (data.qs) then qs.stringify(data.qs) else "")
    options =
        hostname: data.uri
        path: "#{data.path}?#{qsdata}"
        method: data.method

    if data.method is "POST"
        options.path = data.path
        options.headers =
            "Content-Type": "application/x-www-form-urlencoded"
            "Content-Length": qsdata.length

    log.debug "Attempting Request: " + options.method + "; " + options.hostname + options.path

    req = https.request options, (response) ->
        log.debug "Request executed: " + options.method + "; " + options.hostname + options.path
        log.trace "Response http code: " + response.statusCode
        log.trace "Response headers: " + JSON.stringify(response.headers)
        body = ""

        response.on "data", (chunk) ->
            body += chunk
        
        #log.trace("chunk: " + chunk);
        response.on "end", ->
            log.trace "Response body: " + body
            try
                d = JSON.parse(body)
                
                # See http://developers.soundcloud.com/docs/api/guide#errors for full list of error codes
                unless response.statusCode is 200
                    log.error "SoundCloud API ERROR: " + response.statusCode
                    callback d.errors, d
                else
                    log.trace "SoundCloud API OK: " + response.statusCode
                    callback null, d
            catch e
                callback e

    req.on "error", (e) ->
        log.error "For Request: " + options.method + "; " + options.hostname + options.path
        log.error "Request error: " + e.message
        callback e

    if data.method is "POST"
        log.debug "POST Body: " + qsdata
        req.write qsdata
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
            qs:
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
     * @param {String} access_token
     * @param {Object} params
     * @param {Function} callback(error, data)
     * @return {Request}
    ###
    get: (path, params, callback) ->
        _makeCall.apply(@, ["GET", path, @access_token, params, callback])

    post: (path, params, callback) ->
        _makeCall.apply(@, ["POST", path, @access_token, params, callback])

    put: (path, params, callback) ->
        _makeCall.apply(@, ["PUT", path, @access_token, params, callback])

    delete: (path, params, callback) ->
        _makeCall.apply(@, ["DELETE", path, @access_token, params, callback])