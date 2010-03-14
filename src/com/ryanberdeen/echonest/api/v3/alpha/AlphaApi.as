/*
 * Copyright 2010 Ryan Berdeen. All rights reserved.
 * Distributed under the terms of the MIT License.
 * See accompanying file LICENSE.txt
 */

package com.ryanberdeen.echonest.api.v3.alpha {
    import com.adobe.serialization.json.JSON;
    import com.ryanberdeen.echonest.api.v3.ApiSupport;
    import com.ryanberdeen.echonest.api.v3.EchoNestError;

    import flash.net.URLLoader;
    import flash.net.URLRequest;

    public class AlphaApi extends ApiSupport {
        override protected function parseRawResponse(data:String):Object {
            // the alpha api returns xml on some errors, yay.
            if (data.charAt(0) != '{') {
                return super.parseRawResponse(data);
            }
            var response:Object = JSON.decode(data);
            checkStatus(response);
            return response;
        }

        override public function checkStatus(response:Object):void {
            if (response.status != 'ok') {
                // the messages don't have error codes, just messages
                throw new EchoNestError(-1, response.message);
            }
        }

        override public function createRequest(method:String, parameters:Object):URLRequest {
            return super.createRequest('alpha_' + method, parameters);
        }

        public function searchTracks(parameters:Object, loaderOptions:Object):URLLoader {
            var request:URLRequest = createRequest('search_tracks', parameters);
            var loader:URLLoader = createLoader(loaderOptions, processSearchTracksResponse);
            loader.load(request);
            return loader;
        }

        public function processSearchTracksResponse(response:Object):Object {
            return response.results;
        }

        public function getAnalysis(parameters:Object, loaderOptions:Object):URLLoader {
            var loader:URLLoader = createLoader(loaderOptions, processGetAnalysisResponse);
            // TODO
            return null;
        }

        public function processGetAnalysisResponse(response:Object):void {

        }
    }
}
