function remix (analysis) {
  var bars = analysis.beats;
  var samples = [];

  for (var i = 0; i < bars.length; i++) {
    samples.push(bars[i].children()[0]);
  }

  return samples;
}
