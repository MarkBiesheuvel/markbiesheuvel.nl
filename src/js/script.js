(function (document, window) {

    // Lazy load image
    document.getElementById('photo').src = 'photo.jpg';

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
            for (var icon in badges[id]) {
                html += '<div class="' + icon + '"></div>';
            }
            element.innerHTML = html;
        }
    }, false);

    // Timing statistics
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

    document.addEventListener("DOMContentLoaded", function (event) {
        addTimingStats(['domInteractive', 'domContentLoadedEvent']);
    });

    window.addEventListener('load', function () {
        addTimingStats(['domComplete', 'loadEvent']);
    }, false);

})(document, window);



