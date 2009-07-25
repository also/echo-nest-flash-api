/**
* Sorting key functions.
*
* All of the functions in this module can be used as a sorting key for
* `AudioQuantumList.orderedBy`, as in::
*
*     analysis.segments.orderedBy(duration)
*
* Some of the functions in this module return *another* function that takes
* one argument, an `AudioQuantum`, and returns a value (typically a `float`)
* that can then be used as a sorting value.
*
* By convention, all of these functions are named to be noun phrases that
* follow `sortedBy`, as seen above.
*/

var sorting = {
    /**
    * Returns the `AudioQuantum`\'s `confidence` as a sorting value.
    */
    confidence: function(x) {
        return x.confidence;
    },

    /**
    * Returns the `AudioQuantum`\'s `duration` as a sorting value.
    */
    duration: function(x) {
        return x.duration;
    },

    /**
    * Returns a function that returns the value of `timbre`\[*index*]
    * of its input `AudioQuantum`. Sorts by the values of the *index*-th
    * value in the timbre vector.
    */
    timbreValue: function(index) {
        return function(x) {x.timbre[index];};
    },

    /**
    * Returns a function that returns the value of `pitch`\[*index*]
    * of its input `AudioQuantum`. Sorts by the values of the *index*-th
    * value in the pitch vector.
    */
    pitchValue: function(index) {
        return function(x) {x.pitches[index];};
    },

    /**
    * Returns a function that returns the sum of the squared differences
    * between the `pitch` vector of its input `AudioQuantum` and the `pitch`
    * vector of the reference parameter *seg*. Sorts by the pitch distance
    * from the reference `AudioSegment`.
    */
    pitchDistanceFrom: function(seg) {
        return function(x) {sum(map(_diffSquared, seg.pitches, x.pitches));};
    },

    /**
    * Returns a function that returns the sum of the squared differences
    * between the `pitch` vector of its input `AudioQuantum` and the `pitch`
    * vector of the reference parameter *seg*. Sorts by the pitch distance
    * from the reference `AudioSegment`.
    */
    timbreDistanceFrom: function(seg) {
        return function(x) {sum(map(_diffSquared, seg.timbre, x.timbre));};
    },

    /**
    * Returns the sum of the twelve pitch vectors' elements. This is a very
    * fast way of judging the relative noisiness of a segment.
    */
    noisiness: function(x) {
        return sum(x.pitches);
    },

    /* local helper functions: */

    /**
    * Local helper function. The square of the difference between a and b.
    */
    _diffSquared: function(a, b) {
        return pow(a-b, 2);
    }
};
