function AudioQuantum() {

}

var AudioQuantumList = {
    fromEvents: function(kind, events, duration) {
        var aqs = [];
        aqs.kind = kind;

        var previousAq = {start: 0};
        for (var i = 0; i < events.length; i++) {
            var event = events[i];
            var aq = new AudioQuantum();

            aq.start = aq.value = event.value;
            aq.confidence = event.confidence;
            aqs.push(aq);

            previousAq.duration = aq.start - previousAq.start;
            previousAq = aq;
        }
        previousAq.duration = duration - previousAq.start;
        return aqs;
    }
};
