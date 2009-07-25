function AudioQuantum() {
    this.setEnd = function(end) {
        this.end = end;
        this.duration = this.end - this.start;
    };
    this.children = function() {
        var downers = this.container.analysis[AudioQuantum.childrenAttributes[this.container.kind]];
        return downers.that(selection.areContainedBy(this));
    };
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
    }
};
