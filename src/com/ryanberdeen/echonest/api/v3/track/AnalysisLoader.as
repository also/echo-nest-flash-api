package com.ryanberdeen.echonest.api.v3.track {
  import com.ryanberdeen.echonest.api.v3.EchoNestError;
  import com.ryanberdeen.echonest.api.v3.EchoNestErrorEvent;

  import flash.events.Event;
  import flash.events.EventDispatcher;
  import flash.net.URLLoader;
  import flash.utils.Timer;

  public class AnalysisLoader extends EventDispatcher {
    private var trackApi:TrackApi;
    private var timer:Timer;

    private var parameters:Object;

    private var _analysis:Object;

    public function AnalysisLoader(trackApi:TrackApi):void {
      this.trackApi = trackApi;
      _analysis = {};
    }

    public function get analysis():Object {
      return _analysis;
    }

    public function load(parameters:Object):void {
      this.parameters = parameters;
      getMetadata();
    }

    private function waitForAnalysis(delay:int):void {
      timer = new Timer(delay, 1);
      timer.addEventListener('timer', function(e:Event):void {
        timer = null;
        getMetadata();
      });
      timer.start();
    }

    private function getMetadata():void {
      trackApi.getMetadata(parameters, {
        onResponse: metadataResponseHandler,
        onEchoNestError: metadataEchoNestErrorHandler,
        onError: errorHandler
      });
    }

    private function metadataResponseHandler(metadata:Object):void {
      if (metadata.status == 'PENDING') {
        // try again in 5 seconds
        dispatchEvent(new AnalysisEvent(AnalysisEvent.PENDING));
        waitForAnalysis(5000);
        return;
      }
      else if (metadata.status == 'COMPLETE') {
        dispatchEvent(new AnalysisEvent(AnalysisEvent.COMPLETE));
        loadAnalysis();
      }
      else if (metadata.status == 'UNKNOWN') {
        dispatchEvent(new AnalysisEvent(AnalysisEvent.UNKNOWN));
      }
      else {
        dispatchEvent(new AnalysisEvent(AnalysisEvent.ERROR));
      }
      analysis.metadata = metadata;
    }

    private function metadataEchoNestErrorHandler(e:EchoNestError):void {
      if (e.code == 11) { // Analysis not ready (please try again in a few minutes)
        dispatchEvent(new AnalysisEvent(AnalysisEvent.NOT_READY));
        // try again in 15 seconds
        waitForAnalysis(15000);
      }
      else {
        echoNestErrorHandler(e);
      }
    }

    private function loadAnalysis():void {
      var beatsLoader:URLLoader = trackApi.getBeats(parameters, {
        onResponse: beatsLoadedHandler,
        onEchoNestError: echoNestErrorHandler,
        onError: errorHandler
      });

      var barsLoader:URLLoader = trackApi.getBars(parameters, {
        onResponse: barsLoadedHandler,
        onEchoNestError: echoNestErrorHandler,
        onError: errorHandler
      });
    }

    private function errorHandler(event:Event):void {
      dispatchEvent(event);
    }

    private function echoNestErrorHandler(error:EchoNestError):void {
      dispatchEvent(new EchoNestErrorEvent(EchoNestErrorEvent.ECHO_NEST_ERROR, error.code, error.description));
    }

    private function beatsLoadedHandler(beats:Array):void {
      _analysis.beats = beats;
      if (_analysis.bars) {
        analysisLoadedHandler();
      }
    }

    private function barsLoadedHandler(bars:Array):void {
      _analysis.bars = bars;
      if (_analysis.beats) {
        analysisLoadedHandler();
      }
    }

    private function analysisLoadedHandler():void {
      dispatchEvent(new Event(Event.COMPLETE));
    }
  }
}
