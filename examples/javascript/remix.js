var Remix = {
  init: function() {
    swfobject.embedSWF('player.swf', 'swf', '400', '120', '9.0.0');
    this._remixJsElt = document.getElementById('remixJs');
    this._progressElt = document.getElementById('progress');
    if (location.hash) {
      Remix._loadScript();
    }
    initCanvas();

    // add selection and sorting functions to global scope
    extend(window, selection);
    extend(window, sorting);
  },

  __init: function() {
    this._swf = document.getElementById('swf');
  },

  __setAnalysis: function(analysis) {
    this.analysis = new AudioAnalysis(analysis);
  },

  __remix: function() {
    var i;
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

      if (!sampleRanges) {
        alert('remix must return an array of positions');
        return;
      }

      if (sampleRanges.length == 0) {
        alert('remix must return at least one range');
        return;
      }

      if (sampleRanges[0].start) {  // does this look like an array of AudioQuantums?
        this.sampleRanges = [];
        for (i = 0; i < sampleRanges.length; i++) {
          var aq = sampleRanges[i];
          this.sampleRanges.push(aq.start, aq.end);
        }
      }
      else {
        this.sampleRanges = sampleRanges;
      }

      if (this.sampleRanges.length % 2 != 0) {
        alert('remix must return an even number of positions');
        return;
      }

      remixDuration = 0;
      for (i = 0; i < this.sampleRanges.length - 2; i += 2) {
        var start = this.sampleRanges[i];
        var end = this.sampleRanges[i + 1];
        if (end <= start) {
          alert('end position ' + (i / 2 + 1) + ' is not after start position');
          return;
        }
        remixDuration += end - start;
      }
      draw();
      this._swf.setRemixString(this.sampleRanges.join(','))
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
      this._remixJsElt.value = remix;
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

var canvas;
var ctx;

function initCanvas() {
  canvas = document.getElementById('canvas');
  canvas.width = window.innerWidth;
  canvas.addEventListener('click', canvasClickHandler);
  ctx = canvas.getContext('2d');
  window.addEventListener('resize', function() {
    canvas.width = window.innerWidth;
    if (Remix.sampleRanges) {
      draw();
    }
  });
}

function canvasClickHandler() {
  if (draw == drawCurves) {
    draw = drawGraph;
  }
  else {
    draw = drawCurves;
  }
  if (Remix.sampleRanges) {
    draw();
  }
}

var remixDuration;
function drawCurves() {
  var segments = Remix.sampleRanges;
  ctx.clearRect(0, 0, canvas.width, canvas.height);
  ctx.globalCompositeOperation = "darker";

  var maxOriginalPosition = 0;

  var scale = canvas.width / Math.max(remixDuration, Remix.analysis.metadata.duration);

  var remixPosition = 0;
  for (var i = 0; i < segments.length; i += 2) {
    var start = segments[i];
    var end = segments[i + 1];
    var duration = end - start;
    var top = start + duration / 2;
    var bottom = remixPosition + duration / 2;
    ctx.beginPath();
    ctx.strokeStyle = '#00aeef';
    ctx.lineWidth = duration * scale ;
    ctx.moveTo(top * scale, 0);
    ctx.bezierCurveTo(top * scale, 200, bottom * scale, canvas.height - 200, bottom * scale, canvas.height);
    ctx.stroke();
    remixPosition += duration;
  }
}

function drawGraph() {
  var segments = Remix.sampleRanges;
  ctx.fillStyle = '#222222';
  ctx.globalCompositeOperation = "source-over";
  ctx.fillRect(0, 0, canvas.width, canvas.height);

  var maxOriginalPosition = 0;

  var xScale = canvas.width / Remix.analysis.metadata.duration;
  var yScale = canvas.height / remixDuration;

  var remixPosition = 0;
  for (var i = 0; i < segments.length - 1; i += 2) {
    var start = segments[i];
    var end = segments[i + 1];
    var duration = end - start;
    ctx.beginPath();
    ctx.strokeStyle = '#00aeef';
    ctx.lineWidth = 1;
    ctx.moveTo(start * xScale, canvas.height - (remixPosition * yScale));
    remixPosition += duration;
    ctx.lineTo(end * xScale, canvas.height - (remixPosition * yScale));
    ctx.stroke();
  }
}

var draw = drawCurves;
