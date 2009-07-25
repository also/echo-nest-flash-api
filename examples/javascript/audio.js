function AudioQuantum() {

}

AudioQuantum.prototype = {
    setDuration: function(duration) {
        this.duration = duration;
        this.end = this.start + duration;
    },

    setEnd: function(end) {
        this.end = end;
        this.duration = this.end - this.start;
    },

    children:  function() {
        var downers = this.container.analysis[AudioQuantum.childrenAttributes[this.container.kind]];
        return downers.that(selection.areContainedBy(this));
    }
}

AudioQuantum.childrenAttributes = {
    section: 'bars',
    bar: 'beats',
    beat: 'tatums'
};

var AudioQuantumList = {
    extendArray: function(array) {
        array.that = function(filter) {
            var result = AudioQuantumList.extendArray([]);
            result.kind = this.kind;

            for (var i = 0; i < this.length; i++) {
                var aq = this[i];
                if (filter(aq)) {
                    result.push(aq);
                }
            }
            return result;
        };
        return array;
    },

    fromEvents: function(kind, events, duration) {
        var aqs = AudioQuantumList.extendArray([]);
        aqs.kind = kind;

        var previousAq = new AudioQuantum();
        previousAq.start = 0;
        for (var i = 0; i < events.length; i++) {
            var event = events[i];
            var aq = new AudioQuantum();

            aq.start = aq.value = event.value;
            aq.confidence = event.confidence;
            aq.container = aqs;
            aqs.push(aq);

            previousAq.setEnd(aq.start);
            previousAq = aq;
        }
        previousAq.setEnd(duration);
        return aqs;
    },

    fromSegments: function(segments) {
        var aqs = AudioQuantumList.extendArray([]);
        aqs.kind = 'segment';
        for (var i = 0; i < segments.length; i++) {
            var segment = segments[i];
            var aq = new AudioQuantum();

            aq.start = aq.value = segment.start;
            aq.setDuration(segment.duration);
            aq.pitches = segment.pitches;
            aq.timbre = segment.timbre;
            aq.loudnessBegin = segment.startLoudness;
            aq.loudnessMax = segment.maxLoudness;
            aq.timeLoudnessMax = segment.maxLoudnessTimeOffset;
            aq.loudnessEnd = segment.endLoudness;
            aq.container = aqs;
            aqs.push(aq);
        }
        return aqs;
    }
};


endLoudness: 0
maxLoudness: -54.548
maxLoudnessTimeOffset: 0.1219
pitches: Array
start: 0
startLoudness: -60
timbre: Array
