function init() {
  swfobject.embedSWF('player.swf', 'swf', '400', '120', '9.0.0');
  if (location.hash) {
    Remix._loadScript();
  }
}

var Remix = {
  __init: function() {
    this._swf = document.getElementById('swf');
    this._remixJsElt = document.getElementById('remixJs');
    this._progressElt = document.getElementById('progress');
  },

  __setAnalysis: function(analysis) {
    this.analysis = analysis;
  },

  __remix: function() {
    try {
      eval(this._remixJsElt.value);
    }
    catch(e) {
      alert(e);
      return;
    }
    if (remix == null) {
      alert('remix function not found!');
      return;
    }
    try {
      var sampleRanges = remix(this.analysis);
      this._swf.setRemixString(sampleRanges.join(','))
    }
    catch (e) {
      alert(e);
    }
  },

  __setProgress: function(progress) {
    this._progressElt.style.width = 100 * progress + '%';
  },

  _scriptLoaded: function() {
    if (remix) {
      this._remixJsElt = remix;
    }
    else {
      alert('Remix function not found in script.');
    }
  },

  _loadScript: function() {
    remix = null;
    document.write('<script src="' + location.hash.substring(1) + '" onload="Remix._scriptLoaded();"><' + '/script>');
  }
};
