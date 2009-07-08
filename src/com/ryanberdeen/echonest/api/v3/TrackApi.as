/*
 * Copyright 2009 Ryan Berdeen. All rights reserved.
 * Distributed under the terms of the MIT License.
 * See accompanying file LICENSE.txt
 */

package com.ryanberdeen.echonest.api.v3 {
  import com.ryanberdeen.net.MultipartFormDataEncoder;

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
  * The <code>api_key</code> and <code>version</code> parameters will always be
  * set.</p>
  * 
  * <p>The <code>loaderOptions</code> parameter contains the event listeners
  * for the loading process. Most importantly, the
  * <strong><code>onResponse</code></strong> method will be called with the
  * results of the API method.</p>
  * 
  * <p>The methods in this class return data from the Echo Nest API in a simple
  * array format.</p>
  * 
  * <p>For example:</p>
  * <pre>
  * var trackApi:TrackApi = new TrackApi();
  * trackApi.apiKey = 'EJ1B4BFNYQOC56SGF';
  *
  * trackApi.getMode({id: 'music://id.echonest.com/~/TR/TRLFPPE11C3F10749F'}, {
  *   onResponse: function(mode:Array):void {
  *     trace('Mode: ' + mode[0] +', confidence: ' + mode[1]);  // Mode: 1, confidence: 1
  *   }
  * });
  * </pre>
  * 
  * <p>Be sure to set the <code>apiKey</code> property before calling any API
  * methods.</p>
  */
  public class TrackApi extends ApiSupport {
    /**
    * Creates a request to invoke the Echo Nest API <code>upload</code> method.
    *
    * @param fileData The file data to upload.
    *
    * @return The request to use to invoke the method.
    */
    public function createUploadFileDataRequest(fileData:ByteArray):URLRequest {
      var encoder:MultipartFormDataEncoder = new MultipartFormDataEncoder();
      encoder.addParameters({
        version: API_VERSION,
        api_key: _apiKey,
        wait: 'N'
      });
      encoder.addFile('file', 'file', fileData);

      var request:URLRequest = new URLRequest();
      request.url = _baseUrl + 'upload';
      request.data = encoder.data;
      request.contentType = 'multipart/form-data; boundary=' + encoder.boundary;
      request.method = URLRequestMethod.POST;

      return request;
    }

    /**
    * Processes the response from the <code>upload</code> API method.
    *
    * @param response The response to process.
    *
    * @return The result of processing the response.
    *
    * @see #uploadFileData()
    */
    public function processUploadResponse(response:XML):Object {
      var track:XMLList = response.track;
      return {
        id: track.@id.toString(),
        md5: track.@md5.toString(),
        ready: track.@ready == 'true'
      }
    }

    /**
    * Processes the response from an Echo Nest API method that returns a list
    * of numbers with confidence values.
    *
    * @param name The element name of the list items.
    * @param response The response to process.
    *
    * @return The result of processing the response.
    *
    * @see #getSimpleAnalysisList()
    */
    public function processSimpleAnalysisListResponse(name:String, response:XML):Array {
      var result:Array = [];

      for each (var item:XML in response.analysis[name]) {
        result.push([Number(item), Number(item.@confidence)]);
      }

      return result;
    }

    /**
    * Invokes an Echo Nest API method that returns a list of numbers with
    * confidence values.
    *
    * @param name The singular name of the type of item to get. For example, for
    *        <code>get_bars</code>, the name is <code>bar</code>.
    * @param parameters The parameters to include in the API request.
    * @param loaderOptions The event listener options for the loader.
    *
    * @return The <code>URLLoader</code> being used to perform the API call.
    *
    * @see ApiSupport#createRequest()
    * @see ApiSupport#createLoader()
    * @see #processSimpleAnalysisListResponse()
    */
    public function getSimpleAnalysisList(name:String, parameters:Object, loaderOptions:Object):URLLoader {
      var request:URLRequest = createRequest('get_' + name + 's', parameters);
      var loader:URLLoader = createLoader(loaderOptions, processSimpleAnalysisListResponse, name);
      loader.load(request);
      return loader;
    }

    /**
    * Processes the response from an Echo Nest API method that returns a
    * number.
    *
    * @param name The name of the element containing the result value.
    * @param response The response to process.
    *
    * @return The result of processing the response.
    *
    * @see #getNumber()
    */
    public function processNumberResponse(name:String, response:XML):Number {
      return Number(response.analysis[name]);
    }

    /**
    * Invokes an Echo Nest API method that returns a number.
    *
    * @param name The name of the type of item to get. For example for
    *        <code>get_duration</code>, the name is <code>duration</code>.
    * @param parameters The parameters to include in the API request.
    * @param loaderOptions The event listener options for the loader.
    *
    * @return The <code>URLLoader</code> being used to perform the API call.
    *
    * @see ApiSupport#createRequest()
    * @see ApiSupport#createLoader()
    * @see #processNumberResponse()
    */
    public function getNumber(name:String, parameters:Object, loaderOptions:Object):URLLoader {
      var request:URLRequest = createRequest('get_' + name, parameters);
      var loader:URLLoader = createLoader(loaderOptions, processNumberResponse, name);
      loader.load(request);
      return loader;
    }

    /**
    * Processes the response from an Echo Nest API method that returns a number
    * with a confidence value.
    *
    * @param name The name of the element containing the result value.
    * @param response The response to process.
    *
    * @see #getNumberWithConfidence()
    *
    * @return The result of processing the response.
    */
    public function processNumberWithConfidenceResponse(name:String, response:XML):Array {
      var item:XMLList = response.analysis[name];
      return [Number(item), Number(item.@confidence)];
    }

    /**
    * Invokes an Echo Nest API method that returns a number with a confidence
    * value.
    *
    * @param name The name of the type of item to get. For example for
    *        <code>get_duration</code>, the name is <code>duration</code>.
    * @param parameters The parameters to include in the API request.
    * @param loaderOptions The event listener options for the loader.
    *
    * @return The <code>URLLoader</code> being used to perform the API call.
    *
    * @see ApiSupport#createRequest()
    * @see ApiSupport#createLoader()
    * @see #processNumberWithConfidenceResponse()
    */
    public function getNumberWithConfidence(name:String, parameters:Object, loaderOptions:Object):URLLoader {
      var request:URLRequest = createRequest('get_' + name, parameters);
      var loader:URLLoader = createLoader(loaderOptions, processNumberWithConfidenceResponse, name);
      loader.load(request);
      return loader;
    }

    /**
    * Processes the response from the <code>get_metadata</code> API method.
    *
    * @param response The response to process.
    *
    * @return The result of processing the response.
    *
    * @see #getMetadata()
    */
    public function processMetadataResponse(response:XML):Object {
      var analysis:XMLList = response.analysis.copy();

      var result:Object = {};
      // add documented numeric values
      for each(var name:String in ['duration', 'samplerate', 'bitrate']) {
        result[name] = Number(analysis[name]);
        delete analysis[name];
      }

      // add all remaining values as strings
      for each (var item:XML in analysis.children()) {
        result[item.name()] = String(item);
      }
      return result;
    }

    /**
    * Processes the response from the <code>get_sections</code> API method.
    *
    * @param response The response to process.
    *
    * @return The result of processing the response.
    *
    * @see #getSections()
    */
    public function processSectionsResponse(response:XML):Array {
      var result:Array = [];

      for each (var section:XML in response.analysis.section) {
        result.push([Number(section.@start), Number(section.@duration)]);
      }

      return result;
    }

    /**
    * Processes the response from the <code>get_segments</code> API method.
    *
    * @param response The response to process.
    *
    * @return The result of processing the response.
    *
    * @see #getSegments()
    */
    public function processSegmentsResponse(response:XML):Array {
      var result:Array = [];

      for each (var segment:XML in response.analysis.segment) {
        var loudness:Array = [];
        for each (var db:XML in segment.loudness.dB) {
          loudness.push([Number(db.@time), Number(db)]);
        }

        var pitches:Array = [];
        for each (var pitch:XML in segment.pitches.pitch) {
          pitches.push(Number(pitch));
        }

        var timbre:Array = [];
        for each (var coeff:XML in segment.timbre.coeff) {
          timbre.push(Number(coeff));
        }

        result.push([
          Number(segment.@start),
          Number(segment.@duration),
          loudness,
          pitches,
          timbre
        ]);
      }

      return result;
    }

    /**
    * Invokes the Echo Nest <code>get_bars</code> API method.
    *
    * @param parameters The parameters to include in the API request.
    * @param loaderOptions The event listener options for the loader.
    *
    * @return The <code>URLLoader</code> being used to perform the API call.
    *
    * @see #getSimpleAnalysisList()
    * @see http://developer.echonest.com/docs/method/get_bars/
    */
    public function getBars(parameters:Object, loaderOptions:Object):URLLoader {
      return getSimpleAnalysisList('bar', parameters, loaderOptions);
    }

    /**
    * Invokes the Echo Nest <code>get_beats</code> API method.
    *
    * @param parameters The parameters to include in the API request.
    * @param loaderOptions The event listener options for the loader.
    *
    * @return The <code>URLLoader</code> being used to perform the API call.
    *
    * @see #getSimpleAnalysisList()
    * @see http://developer.echonest.com/docs/method/get_beats/
    */
    public function getBeats(parameters:Object, loaderOptions:Object):URLLoader {
      return getSimpleAnalysisList('beat', parameters, loaderOptions);
    }

    /**
    * Invokes the Echo Nest <code>get_duration</code> API method.
    *
    * @param parameters The parameters to include in the API request.
    * @param loaderOptions The event listener options for the loader.
    *
    * @return The <code>URLLoader</code> being used to perform the API call.
    *
    * @see #getNumber()
    * @see http://developer.echonest.com/docs/method/get_duration/
    */
    public function getDuration(parameters:Object, loaderOptions:Object):URLLoader {
      return getNumber('duration', parameters, loaderOptions);
    }

    /**
    * Invokes the Echo Nest <code>get_end_of_fade_in</code> API method.
    *
    * @param parameters The parameters to include in the API request.
    * @param loaderOptions The event listener options for the loader.
    *
    * @return The <code>URLLoader</code> being used to perform the API call.
    *
    * @see #getNumber()
    * @see http://developer.echonest.com/docs/method/get_end_of_fade_in/
    */
    public function getEndOfFadeIn(parameters:Object, loaderOptions:Object):URLLoader {
      return getNumber('end_of_fade_in', parameters, loaderOptions);
    }

    /**
    * Invokes the Echo Nest <code>get_key</code> API method.
    *
    * @param parameters The parameters to include in the API request.
    * @param loaderOptions The event listener options for the loader.
    *
    * @return The <code>URLLoader</code> being used to perform the API call.
    *
    * @see #getNumberWithConfidence()
    * @see http://developer.echonest.com/docs/method/get_key/
    */
    public function getKey(parameters:Object, loaderOptions:Object):URLLoader {
      return getNumberWithConfidence('key', parameters, loaderOptions);
    }

    /**
    * Invokes the Echo Nest <code>get_loudness</code> API method.
    *
    * @param parameters The parameters to include in the API request.
    * @param loaderOptions The event listener options for the loader.
    *
    * @return The <code>URLLoader</code> being used to perform the API call.
    *
    * @see #getNumber()
    * @see http://developer.echonest.com/docs/method/get_loudness/
    */
    public function getLoudness(parameters:Object, loaderOptions:Object):URLLoader {
      return getNumber('loudness', parameters, loaderOptions);
    }

    /**
    * Invokes the Echo Nest <code>get_metadata</code> API method.
    *
    * @param parameters The parameters to include in the API request.
    * @param loaderOptions The event listener options for the loader.
    *
    * @return The <code>URLLoader</code> being used to perform the API call.
    *
    * @see #processMetadataResponse()
    * @see http://developer.echonest.com/docs/method/get_metadata/
    */
    public function getMetadata(parameters:Object, loaderOptions:Object):URLLoader {
      var request:URLRequest = createRequest('get_metadata', parameters);
      var loader:URLLoader = createLoader(loaderOptions, processMetadataResponse);
      loader.load(request);
      return loader;
    }

    /**
    * Invokes the Echo Nest <code>get_mode</code> API method.
    *
    * @param parameters The parameters to include in the API request.
    * @param loaderOptions The event listener options for the loader.
    *
    * @return The <code>URLLoader</code> being used to perform the API call.
    *
    * @see #getNumberWithConfidence()
    * @see http://developer.echonest.com/docs/method/get_mode/
    */
    public function getMode(parameters:Object, loaderOptions:Object):URLLoader {
      return getNumberWithConfidence('mode', parameters, loaderOptions);
    }

    /**
    * Invokes the Echo Nest <code>get_sections</code> API method.
    *
    * @param parameters The parameters to include in the API request.
    * @param loaderOptions The event listener options for the loader.
    *
    * @return The <code>URLLoader</code> being used to perform the API call.
    *
    * @see #processSectionsResponse()
    * @see http://developer.echonest.com/docs/method/get_sections/
    */
    public function getSections(parameters:Object, loaderOptions:Object):URLLoader {
      var request:URLRequest = createRequest('get_sections', parameters);
      var loader:URLLoader = createLoader(loaderOptions, processSectionsResponse);
      loader.load(request);
      return loader;
    }

    /**
    * Invokes the Echo Nest <code>get_segments</code> API method.
    *
    * @param parameters The parameters to include in the API request.
    * @param loaderOptions The event listener options for the loader.
    *
    * @return The <code>URLLoader</code> being used to perform the API call.
    *
    * @see #processSegmentsResponse()
    * @see http://developer.echonest.com/docs/method/get_segments/
    */
    public function getSegments(parameters:Object, loaderOptions:Object):URLLoader {
      var request:URLRequest = createRequest('get_segments', parameters);
      var loader:URLLoader = createLoader(loaderOptions, processSegmentsResponse);
      loader.load(request);
      return loader;
    }

    /**
    * Invokes the Echo Nest <code>get_start_of_fade_out</code> API method.
    *
    * @param parameters The parameters to include in the API request.
    * @param loaderOptions The event listener options for the loader.
    *
    * @return The <code>URLLoader</code> being used to perform the API call.
    *
    * @see #getNumber()
    * @see http://developer.echonest.com/docs/method/get_start_of_fade_out/
    */
    public function getStartOfFadeOut(parameters:Object, loaderOptions:Object):URLLoader {
      return getNumber('start_of_fade_out', parameters, loaderOptions);
    }

    /**
    * Invokes the Echo Nest <code>get_tatums</code> API method.
    *
    * @param parameters The parameters to include in the API request.
    * @param loaderOptions The event listener options for the loader.
    *
    * @return The <code>URLLoader</code> being used to perform the API call.
    *
    * @see #getSimpleAnalysisList()
    * @see http://developer.echonest.com/docs/method/get_tatums/
    */
    public function getTatums(parameters:Object, loaderOptions:Object):URLLoader {
      return getSimpleAnalysisList('tatum', parameters, loaderOptions);
    }

    /**
    * Invokes the Echo Nest <code>get_tempo</code> API method.
    *
    * @param parameters The parameters to include in the API request.
    * @param loaderOptions The event listener options for the loader.
    *
    * @return The <code>URLLoader</code> being used to perform the API call.
    *
    * @see #getNumberWithConfidence()
    * @see http://developer.echonest.com/docs/method/get_tempo/
    */
    public function getTempo(parameters:Object, loaderOptions:Object):URLLoader {
      return getNumberWithConfidence('tempo', parameters, loaderOptions);
    }

    /**
    * Invokes the Echo Nest <code>get_time_signature</code> API method.
    *
    * @param parameters The parameters to include in the API request.
    * @param loaderOptions The event listener options for the loader.
    *
    * @return The <code>URLLoader</code> being used to perform the API call.
    *
    * @see #getNumberWithConfidence()
    * @see http://developer.echonest.com/docs/method/get_time_signature/
    */
    public function getTimeSignature(parameters:Object, loaderOptions:Object):URLLoader {
      return getNumberWithConfidence('time_signature', parameters, loaderOptions);
    }

    /**
    * Invokes the Echo Nest <code>upload</code> API method with file data.
    *
    * <p>Becuase of security restrictions in Flash Player 10, this method must
    * be called as the direct result of a user event. Additionally, because the
    * data is uploaded using a <code>URLLoader</code>, no progress events are
    * dispatched during the upload process. See
    * <a href="http://bugs.adobe.com/jira/browse/FP-1959">Flash Player bug 1959</a>.</p>
    *
    * @param fileData The file data to upload. Passed as the value of the
    *        <code>file</code> parameter.
    * @param loaderOptions The event listener options for the loader.
    *
    * @return The <code>URLLoader</code> being used to perform the API call.
    *
    * @see #createUploadFileDataRequest()
    * @see ApiSupport#createLoader
    * @see #processUploadResponse()
    * @see http://developer.echonest.com/docs/method/upload/
    */
    public function uploadFileData(fileData:ByteArray, loaderOptions:Object):URLLoader {
      var request:URLRequest = createUploadFileDataRequest(fileData);
      var loader:URLLoader = createLoader(loaderOptions, processUploadResponse);
      loader.load(request);
      return loader;
    }

    /**
    * Invokes the Echo Nest <code>upload</code> API method.
    *
    * @param parameters The parameters to include in the API request.
    * @param loaderOptions The event listener options for the loader.
    *
    * @return The <code>URLLoader</code> being used to perform the API call.
    *
    * @see ApiSupport#createRequest()
    * @see ApiSupport#createLoader()
    * @see #processUploadResponse()
    * @see http://developer.echonest.com/docs/method/upload/
    */
    public function upload(parameters:Object, loaderOptions:Object):URLLoader {
      var request:URLRequest = createRequest('upload', parameters);
      request.method = URLRequestMethod.POST;
      var loader:URLLoader = createLoader(loaderOptions, processUploadResponse);
      loader.load(request);
      return loader;
    }
  }
}
