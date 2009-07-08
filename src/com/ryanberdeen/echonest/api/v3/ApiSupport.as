/*
 * Copyright 2009 Ryan Berdeen. All rights reserved.
 * Distributed under the terms of the MIT License.
 * See accompanying file LICENSE.txt
 */

package com.ryanberdeen.echonest.api.v3 {
  import flash.events.Event;
  import flash.events.HTTPStatusEvent;
  import flash.events.IOErrorEvent;
  import flash.events.ProgressEvent;
  import flash.events.SecurityErrorEvent;
  import flash.net.URLLoader;
  import flash.net.URLRequest;
  import flash.net.URLRequestHeader;
  import flash.net.URLVariables;

  /**
  * Base class for Echo Nest API classes.
  */
  public class ApiSupport {
    public static const API_VERSION:int = 3;
    /**
    * @private
    */
    protected var _baseUrl:String = 'http://developer.echonest.com/api/';
    
    /**
    * @private
    */
    protected var _apiKey:String;

    /**
    * The API key to use for Echo Nest API requests.
    */
    public function set apiKey(apiKey:String):void {
      _apiKey = apiKey;
    }

    /**
    * Creates a request for an Echo Nest API method call with a set of
    * parameters.
    *
    * @param method The method to call.
    * @param parameters The parameters to include in the request.
    *
    * @return The request to use to call the method.
    */
    public function createRequest(method:String, parameters:Object):URLRequest {
      var variables:URLVariables = new URLVariables;
      variables.api_key = _apiKey;
      variables.version = API_VERSION;
      for (var name:String in parameters) {
        variables[name] = parameters[name];
      }

      var request:URLRequest = new URLRequest();
      request.url = _baseUrl + method;
      request.data = variables;

      return request;
    }

    /**
    * Creates a loader with event listeners.
    *
    * <p>The following options are supported:</p>
    *
    * <table><thead><tr><th>Option</th><th>Event</th></tr></thead><tbody>
    *   <tr>
    *     <td>onComplete</td>
    *     <td><code>Event.COMPLETE</code></td>
    *   </tr>
    *   <tr>
    *     <td>onResponse</td>
    *     <td>Called with the processed response.</td>
    *   </tr>
    *   <tr>
    *     <td>onEchoNestError</td>
    *     <td>Called with an <code>EchoNestError</code> if the status code is nonzero</td>
    *   </tr>
    *   <tr>
    *     <td>onProgress</td>
    *     <td><code>ProgressEvent.PROGRESS</code></td>
    *   </tr>
    *   <tr>
    *     <td>onSecurityError</td>
    *     <td><code>SecurityErrorEvent.SECURITY_ERROR</code></td>
    *   </tr>
    *   <tr>
    *     <td>onIoError</td>
    *     <td><code>IOErrorEvent.IO_ERROR</code></td>
    *   </tr>
    *   <tr>
    *     <td>onError</td>
    *     <td><code>IOErrorEvent.IO_ERROR</code><br/> <code>SecurityErrorEvent.SECURITY_ERROR</code></td>
    *   </tr>
    *   <tr>
    *     <td>onHttpStatus</td>
    *     <td><code>HTTPStatusEvent.HTTP_STATUS</code></td>
    *   </tr>
    * </tbody></table>
    *
    * @param options The event listener options.
    * @param responseProcessor The function that processes the XML response.
    */
    public function createLoader(options:Object, responseProcessor:Function = null, ...responseProcessorArgs):URLLoader {
      var loader:URLLoader = new URLLoader();

      if (options.onComplete) {
        loader.addEventListener(Event.COMPLETE, options.onComplete);
      }

      if (responseProcessor != null && options.onResponse) {
        loader.addEventListener(Event.COMPLETE, function(e:Event):void {
          try {
            var responseXml:XML = new XML(loader.data);
            checkStatus(responseXml);
            responseProcessorArgs.push(responseXml);
            var response:Object = responseProcessor.apply(responseProcessor, responseProcessorArgs);
            options.onResponse(response);
          }
          catch (e:EchoNestError) {
            if (options.onEchoNestError) {
              options.onEchoNestError(e);
            }
          }
        });
      }

      if (options.onProgress) {
        loader.addEventListener(ProgressEvent.PROGRESS, options.onProgress);
      }

      if (options.onSecurityError) {
        loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, options.onSecurityError);
      }

      if (options.onIoError) {
        loader.addEventListener(IOErrorEvent.IO_ERROR, options.onIoError);
      }

      if (options.onError) {
        loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, options.onError);
        loader.addEventListener(IOErrorEvent.IO_ERROR, options.onError);
      }

      if (options.onHttpStatus) {
        loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, options.onHttpStatus);
      }

      return loader;
    }

    /**
    * Throws an <code>EchoNestError</code> if the status indicates an error.
    *
    * @param The XML result of an Echo Nest API call.
    *
    * @throws EchoNestError When the status code is nonzero.
    */
    public function checkStatus(response:XML):void {
      if (response.status.code != 0) {
        throw new EchoNestError(response.status.code, response.status.message);
      }
    }
  }
}