function remix (analysis) {
    var tonic = analysis.key.value;
    var chunks = analysis.tatums;
    var segs = analysis.segments.that(selection.havePitchMax(tonic)).that(selection.overlapStartsOf(chunks));
    return chunks.that(selection.overlapEndsOf(segs));
}
