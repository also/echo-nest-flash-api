function remix (analysis) {
  var chunks = analysis.beats;
  var result = [];
  for (var i = chunks.length - 1; i >= 0; i--) {
    result.push(chunks[i]);
  }
  return result;
}
