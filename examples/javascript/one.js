function remix (analysis) {
  var bars = analysis.beats;
  var result = [];

  for (var i = 0; i < bars.length; i++) {
    result.push(bars[i].children()[0]);
  }

  return result;
}
