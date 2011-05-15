/*
 * Copyright 2011 Ryan Berdeen. All rights reserved.
 * Distributed under the terms of the MIT License.
 * See accompanying file LICENSE.txt
 */

package com.ryanberdeen.echonest.api.v4.track {
  import com.adobe.serialization.json.JSON;
  import com.ryanberdeen.echonest.api.v4.ApiSupport;
  import com.ryanberdeen.echonest.api.v4.EchoNestError;

  import flash.events.DataEvent;
  import flash.events.Event;
  import flash.net.FileReference;
  import flash.net.URLLoader;
  import flash.net.URLRequest;
  import flash.net.URLRequestMethod;
  import flash.utils.ByteArray;

  /**
  * Methods to interact with the Echo Nest track API.
  *
  * <p>All of the API methods in this class accept basically the same
  * parameters. The <code>parameters</code> parameter contains the parameters
  * to pass to the Echo Nest method. For most methods, this will be
  * <strong><code>id</code></strong> or <strong><code>md5</code></strong>.
  * The <code>api_key</code> parameter will always be
  * set.</p>
  *
  * <p>The <code>loaderOptions</code> parameter contains the event listeners
  * for the loading process. Most importantly, the
  * <strong><code>onResponse</code></strong> method will be called with the
  * results of the API method. See the <code>ApiSupport.createLoader()</code>
  * method for a description of the loader options.</p>
  *
  * <p>For a description of the response formats, see the various
  * <code>process...Response()</code> methods.</p>
  *
  * <p>Be sure to set the <code>apiKey</code> property before calling any API
  * methods.</p>
  */
  public class TrackApi extends ApiSupport {
    /**
    * Adds the standard Echo Nest Flash API event listeners to a file
    * reference.
    *
    * @param options The event listener options. See
    *        <code>createLoader()</code> for the list of available options.
    * @param dispatcher The file reference to add the event listeners to.
    */
    public function addFileReferenceEventListeners(options:Object, fileReference:FileReference, responseProcessor:Function, ...responseProcessorArgs):void {
      // TODO document
      if (options.onOpen) {
        fileReference.addEventListener(Event.OPEN, options.onOpen);
      }

      if (options.onComplete) {
        fileReference.addEventListener(Event.COMPLETE, options.onComplete);
      }

      if (options.onResponse) {
        fileReference.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, function(e:DataEvent):void {
          try {
            var responseObject:* = parseRawResponse(e.data);
            responseProcessorArgs.push(responseObject);
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

      addEventListeners(options, fileReference);
    }

    public function loadAnalysis(track:Object, loaderOptions:Object):URLLoader {
      var loader:URLLoader = new URLLoader();

      if (loaderOptions.onComplete) {
        loader.addEventListener(Event.COMPLETE, loaderOptions.onComplete);
      }

      if (loaderOptions.onResponse) {
        loader.addEventListener(Event.COMPLETE, function(e:Event):void {
          var analysis:Object = JSON.decode(loader.data);
          loaderOptions.onResponse(analysis);
        });
      }

      addEventListeners(loaderOptions, loader);

      var request:URLRequest = new URLRequest();
      request.url = track.audio_summary.analysis_url;
      loader.load(request);
      return loader;
    }

    /**
    * Processes the response from the <code>upload</code> API method.
    *
    * @param response The response to process.
    *
    * @return The result of processing the response.
    *
    * @see #upload()
    * @see #uploadFileData()
    */
    public function processUploadResponse(response:*):Object {
      return response.track;
    }

    /**
    * Invokes the Echo Nest <code>upload</code> API method with a file
    * reference.
    *
    * <p>The <code>parameters</code> object must include a <code>track</code>
    * property, which must be a <code>FileReference</code> that may be
    * <code>upload()</code>ed.</p>
    *
    * @param parameters The parameters to include in the API request.
    * @param loaderOptions The event listener options for the loader.
    *
    * @see com.ryanberdeen.echonest.api.v3.ApiSupport#createRequest()
    * @see #processUploadResponse()
    * @see http://developer.echonest.com/docs/v4/track.html#upload
    */ 
    public function uploadFileReference(parameters:Object, loaderOptions:Object):URLRequest {
      var fileReference:FileReference = parameters.track;
      delete parameters.track;

      addFileReferenceEventListeners(loaderOptions, fileReference, processUploadResponse);
      var request:URLRequest = createRequest('track/upload', parameters);
      fileReference.upload(request, 'track');
      return request;
    }

    /**
    * Invokes the Echo Nest <code>upload</code> API method.
    *
    * <p>This method is for uploads using the <code>url</code> parameter.
    * To upload a file, use <code>uploadFileReference()</code>.
    *
    * @param parameters The parameters to include in the API request.
    * @param loaderOptions The event listener options for the loader.
    *
    * @return The <code>URLLoader</code> being used to perform the API call.
    *
    * @see com.ryanberdeen.echonest.api.v4.ApiSupport#createRequest()
    * @see com.ryanberdeen.echonest.api.v4.ApiSupport#createLoader()
    * @see #processUploadResponse()
    * @see http://developer.echonest.com/docs/v4/track.html#upload
    */
    public function upload(parameters:Object, loaderOptions:Object):URLLoader {
      var request:URLRequest = createRequest('track/upload', parameters);
      request.method = URLRequestMethod.POST;
      var loader:URLLoader = createLoader(loaderOptions, processUploadResponse);
      loader.load(request);
      return loader;
    }
  }
}
