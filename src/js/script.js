(function (document, window) {
    document.getElementById('photo').src = 'photo.jpg';

    var timing = window.performance.timing;

    var bigBang = timing.navigationStart;
    var previous = bigBang;
    var tbody = document.getElementById('timing-stats');

    var addTimingStats = function (names) {

        var html = '';

        names.forEach(function (name) {

            var time = 0;

            if (name in timing) {
                time = timing[name];
            } else if ((name + 'Start') in timing) {
                time = timing[name + 'Start'];
            }

            if (!time) {
                return;
            }

            html += '<tr><td>' + name + '</td><td>' + (time - previous) + ' ms</td><td>' + (time - bigBang) + ' ms</td></tr>';
            previous = time;
        });

        tbody.innerHTML += html;
    };

    addTimingStats(['domainLookup', 'connect', 'secureConnection', 'request', 'response', 'domLoading']);

    document.addEventListener("DOMContentLoaded", function(event) {
        addTimingStats(['domInteractive', 'domContentLoadedEvent']);
    });

    window.addEventListener('load', function () {
        addTimingStats(['domComplete', 'loadEvent']);
    }, false);

})(document, window);



