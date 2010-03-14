/*
 * Copyright 2010 Ryan Berdeen. All rights reserved.
 * Distributed under the terms of the MIT License.
 * See accompanying file LICENSE.txt
 */

package com.ryanberdeen.echonest.api.v3.alpha {
    import com.adobe.serialization.json.JSON;
    import com.ryanberdeen.echonest.api.v3.ApiSupport;
    import com.ryanberdeen.echonest.api.v3.EchoNestError;
    import com.ryanberdeen.echonest.api.v3.track.NumberWithConfidence;
    import com.ryanberdeen.echonest.api.v3.track.Section;
    import com.ryanberdeen.echonest.api.v3.track.Segment;

    import flash.external.ExternalInterface;

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
            var request:URLRequest = createRequest('get_analysis', parameters);
            var loader:URLLoader = createLoader(loaderOptions, processGetAnalysisResponse);
            loader.load(request);
            return loader;
        }

        public function processGetAnalysisResponse(response:Object):Object {
            var analysis:Object = response.analysis;
            var result:Object = {};
            result.sections = processSections(analysis.sections);
            result.bars = processSimpleAnalysisList(analysis.bars);
            result.beats = processSimpleAnalysisList(analysis.beats);
            result.tatums = processSimpleAnalysisList(analysis.tatums);
            result.segments = processSegments(analysis.segments);
            // FIXME
            result.metadata = {};
            result.duration = analysis.track.duration;
            result.endOfFadeIn = analysis.track.end_of_fade_in;
            result.startOfFadeOut = analysis.track.start_of_fade_out;
            result.key = new NumberWithConfidence(analysis.track.key, analysis.track.key_confidence);
            result.loudness = analysis.track.loudness;
            result.mode = new NumberWithConfidence(analysis.track.mode, analysis.track.mode_confidence);
            result.tempo = new NumberWithConfidence(analysis.track.tempo, analysis.track.tempo_confidence);
            result.timeSignature = new NumberWithConfidence(analysis.track.time_signature, analysis.track.time_signature_confidence);
            return result;
        }

        private function processSimpleAnalysisList(list:Array):Array {
            var result:Array = [];
            for each (var item:Object in list) {
                result.push(new NumberWithConfidence(item.start, item.confidence));
            }
            return result;
        }

        private function processSections(sections:Array):Array {
            var result:Array = [];
            for each (var sectionData:Object in sections) {
                var section:Section = new Section();
                section.start = sectionData.start;
                section.duration = sectionData.duration;
                result.push(section);
            }
            return result;
        }

        private function processSegments(segments:Array):Array {
            var result:Array = [];
            var previousSegment:Segment = new Segment();  // this is never used, but eliminates an if in the loop
            for each (var segmentData:Object in segments) {
                var segment:Segment = new Segment();
                segment.start = segmentData.start;
                segment.duration = segmentData.duration;
                segment.startLoudness = segmentData.loudness_start;
                previousSegment.endLoudness = segment.startLoudness;
                segment.maxLoudness = segmentData.loudness_max;
                segment.maxLoudnessTimeOffset = segmentData.loudness_max_time;
                segment.pitches = segmentData.pitches;
                segment.timbre = segmentData.timbre;
                result.push(segment);
                previousSegment = segment;
            }
            previousSegment.endLoudness = segmentData.loudness_end;
            return result;
        }
    }
}
