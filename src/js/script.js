(function (document, window) {

    // Lazy load image\
    window.addEventListener('load', function () {
        document.getElementById('photo').src = 'photo.jpg';
    });

    // Lazy load badges

    var badges = {
        "aws": {
            "icon-solutions-architect-associate": "Solutions Architext, Associate",
            "icon-websites-and-web-apps": "Websites & Web Apps",
            "icon-digital-media": "Digital Media",
            "icon-compute-and-netwerking": "Compute & Networking",
            "icon-big-data-on-aws": "Big Data on AWS"
        },
        "javascript": {
            "icon-javascript-road-trip-part-1": "JavaScript Road Trip Part 1",
            "icon-javascript-road-trip-part-2": "JavaScript Road Trip Part 2",
            "icon-javascript-road-trip-part-3": "JavaScript Road Trip Part 3",
            "icon-javascript-best-practices": "JavaScript Best Practices",
            "icon-es2015-the-shape-of-javascript-to-come": "ES2015: The Shape of JavaScript to Come",
            "icon-real-time-web-with-nodejs": "Real-time Web with Node.js",
            "icon-anatomy-of-backbonejs": "Anatomy of Backbone.js",
            "icon-anatomy-of-backbonejs-part-2": "Anatomy of Backbone.js Part 2",
            "icon-try-jquery": "Try jQuery",
            "icon-jquery-the-return-flight": "jQuery: The Return Flight",
            "icon-jquery-air-first-flight": "jQuery Air: First Flight",
            "icon-jquery-air-captains-log": "jQuery Air: Captains Log"
        },
        "databases": {
            "icon-try-sql": "Try SQL",
            "icon-the-sequel-to-sql": "The Sequel to SQL",
            "icon-the-magical-marvels-of-mongodb": "The Magical Marvels of MongoDB"
        },
        "git": {
            "icon-try-git": "Try Git",
            "icon-git-real": "Git Real",
            "icon-git-real-2": "Git Real 2",
            "icon-mastering-github": "Mastering GitHub"
        },
        "css": {
            "icon-css-cross-country": "CSS Cross-Country",
            "icon-assembling-sass": "Assembling Sass",
            "icon-assembling-sass-part-2": "Assembling Sass Part 2",
            "icon-functional-html5-and-css3": "Functional HTML5 & CSS3",
            "icon-front-end-formations": "Front-end Formations"
        }
    };

    window.addEventListener('load', function () {
        for (var id in badges) {
            var element = document.getElementById(id);
            var html = '';
            var title;
            for (var icon in badges[id]) {
                title = badges[id][icon];
                html += '<div class="' + icon + '" title="' + title + '"></div>';
            }
            element.innerHTML = html;
        }
    }, false);

    // Timing statistics
    var timing = window.performance.timing;

    var bigBang = timing.navigationStart;

    var timingStats = [];

    var loaded = false;

    var addTimingStats = function (names) {

        var html = '';

        names.forEach(function (name) {

            var start, end;

            if (name in timing) {
                start = timing[name];
            } else if ((name + 'Start') in timing) {
                start = timing[name + 'Start'];

                if ((name + 'End') in timing) {
                    end = timing[name + 'End'];
                }
            }

            if (!start) {
                return;
            }
            if (!end) {
                end = start;
            }

            timingStats.push({
                name: name,
                start: start,
                end: end
            });
        });
    };

    addTimingStats(['domainLookup', 'connect', 'secureConnection', 'request', 'response', 'domLoading']);

    document.addEventListener("DOMContentLoaded", function (event) {
        addTimingStats(['domInteractive', 'domContentLoadedEvent']);
    });

    window.addEventListener('load', function () {
        addTimingStats(['domComplete', 'loadEvent']);
        loaded = true;
    }, false);

    var canvas = document.getElementById('canvas');
    var ctx = canvas.getContext('2d');
    ctx.imageSmoothingEnabled = false;

    var width = parseInt(canvas.clientWidth, 10);
    var height = parseInt(canvas.clientHeight, 10);
    var margin = 40;

    canvas.width = width;
    canvas.height = height;

    width -= margin * 2;
    height -= margin * 2;

    ctx.font = '12px arial';
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';

    var scaler = function (from, to) {
        var factor = to - from;
        return function (value) {
            return width * value / factor;
        };
    };

    var draw = function () {

        ctx.clearRect(0, 0, width, height);

        ctx.translate(margin, margin);

        ctx.strokeStyle = '#333';
        ctx.strokeRect(0, 0, width, height);

        var now = Math.max(bigBang + 1000, +(new Date));

        var scale = scaler(bigBang, now);

        ctx.fillStyle = '#333';

        for (var t = 0; t < (now - bigBang); t += 150) {
            ctx.fillText(t + 'ms', scale(t), height + 7);
        }

        timingStats.forEach(function (stat, i) {

            var x = scale(stat.start - bigBang);
            var y = i * 14;
            var text = stat.name;

            ctx.fillStyle = '#337ab7';

            if (stat.start != stat.end) {
                var diff = stat.end - stat.start;

                text += ' (' + diff + 'ms)';

                ctx.fillRect(x, y, Math.ceil(scale(diff)), 12);

            } else {
                ctx.fillRect(x, 0, 1, height);
            }

            ctx.fillStyle = '#333';
            ctx.fillText(text, x, y + 5);
        });

        if (!loaded) {
            window.requestAnimationFrame(draw);
        }
    };

    window.requestAnimationFrame(draw);

    window.onresize = function () {
        // TODO: redraw canvas
    };

})(document, window);



