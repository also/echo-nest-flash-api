package com.ryanberdeen.echonest.api.v3 {
  import com.ryanberdeen.net.MultipartFormDataEncoder;

  import flash.net.URLLoader;
  import flash.net.URLRequest;
  import flash.net.URLRequestMethod;
  import flash.utils.ByteArray;

  /**
  * Methods to interact with the Echo Nest track API.
  */
  public class TrackApi extends ApiSupport {
    public function createUploadFileDataRequest(fileData:ByteArray):URLRequest {
      var encoder:MultipartFormDataEncoder = new MultipartFormDataEncoder();
      encoder.addParameters({
        version: 3,
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


    public function processUploadResponse(response:XML):Object {
      var track:XMLList = response.track;
      return {
        id: track.@id.toString(),
        md5: track.@md5.toString(),
        ready: track.@ready == 'true'
      }
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
    * @param options The event listener options.
    *
    * @return The <code>URLLoader</code> being used to perform the API call.
    *
    * @see #createUploadFileDataRequest()
    * @see #processUploadResponse()
    */
    public function uploadFileData(fileData:ByteArray, options:Object):URLLoader {
      var request:URLRequest = createUploadFileDataRequest(fileData);
      var loader:URLLoader = createLoader(options, processUploadResponse);
      loader.load(request);
      return loader;
    }
  }
}
