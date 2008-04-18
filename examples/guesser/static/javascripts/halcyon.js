// The Halcyon JavaScript client library.
// @dependency Prototype 1.6

var Halcyon = Class.create({
  "initialize": function(uri) {
    this.uri = uri;
  },
  "request": function(method, options, callback) {
    // default options
    path = options['path'] || '/';
    params = options['params'] || {};
    headers = options['headers'] || {};
    
    // request URI
    url = this.uri + path;
    
    // perform request
    new Ajax.Request(url, {
      "method": method,
      "parameters": params,
      "requestHeaders": headers,
      "onSuccess": function(transport) {
        return callback(transport.responseText.evalJSON());
      },
      "onFailure": function(transport) {
        return callback(transport.responseText.evalJSON());
      }
    });
  },
  "get": function(options, callback) {
    return this.request('get', options, callback);
  },
  "post": function(options, callback) {
    return this.request('post', options, callback);
  },
  "put": function(options, callback) {
    return this.request('put', options, callback);
  },
  "delete": function(options, callback) {
    return this.request('delete', options, callback);
  }
});
