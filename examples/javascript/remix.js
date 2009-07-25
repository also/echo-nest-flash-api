function init() {
  swfobject.embedSWF('player.swf', 'swf', '400', '120', '9.0.0');
  if (location.hash) {
    Remix._loadScript();
  }
}

var Remix = {
  __init: function() {
    this._swf = document.getElementById('swf');
  },

  __setAnalysis: function(analysis) {
    this.analysis = analysis;
  },

  __remix: function() {
    try {
      eval($('remixJs').value);
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
      this._swf.setRemixJson(Object.toJSON(sampleRanges))
    }
    catch (e) {
      alert(e);
    }
  },

  __setProgress: function(progress) {
    $('progress').style.width = 100 * progress + '%';
  },

  _scriptLoaded: function() {
    if (remix) {
      $('remixJs').value = remix;
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
