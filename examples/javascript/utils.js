function extend(destination, source) {
    for (var property in source) {
        destination[property] = source[property];
    }
    return destination;
}

Array.prototype.sum = function() {
    var result = 0;
    for (var i = 0; i < this.length; i++) {
        result += this[i];
    }
};