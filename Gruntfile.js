module.exports = function (grunt) {

    var githubHeaders = {
        'Accept': 'application/vnd.github.v3+json',
        'User-Agent': 'development@markbiesheuvel.nl',
        'Time-Zone': 'Europe/Amsterdam'
    };

    var photoSize = 262; // 262px square
    var badgeSize = 90;

    // Project configuration.
    grunt.initConfig({

        // Get package information
        pkg: grunt.file.readJSON('package.json'),

        clean: {
            dist: {
                src: ['dist']
            },
            tmp: {
                src: ['tmp']
            }
        },

        jshint: {
            gruntfile: {
                src: ['Gruntfile.js']
            },
            dist: {
                src: ['src/js/*.js']
            }
        },

        copy: {
            dist: {
                cwd: 'src',
                src: ['**', '.htaccess', '!index.html.tpl', '!img/**', '!css/**', '!js/**'],
                dest: 'dist',
                expand: true
            }
        },

        uglify: {
            dist: {
                src: ['src/js/**/*.js'],
                dest: 'tmp/script.min.js',
                options: {
                    preserveComments: false
                }
            }
        },

        // Compass compile for css
        less: {
            dist: {
                options: {
                    strictMath: true
                },
                files: {
                    'tmp/compiled.css': 'src/css/style.less'
                }
            }
        },

        uncss: {
            dist: {
                files: {
                    'tmp/tidy.css': ['tmp/index1.html']
                }
            }
        },

        cssmin: {
            dist: {
                files: {
                    'tmp/minified.css': ['tmp/tidy.css']
                }
            }
        },

        image_resize: {
            lossless: {
                options: {
                    width: photoSize,
                    height: photoSize,
                    quality: 1.0
                },
                files: {
                    'dist/img/photo.jpg': 'src/img/photo.jpg'
                }
            },
            compressed: {
                options: {
                    width: photoSize * 0.25,
                    height: photoSize * 0.25,
                    quality: 0.0
                },
                files: {
                    'tmp/photo.jpg': 'src/img/photo.jpg'
                }
            },
            badges: {
                options: {
                    width: badgeSize,
                    height: badgeSize,
                    quality: 1.0
                },
                src: 'tmp/backpack/images/*.*',
                dest: 'dist/img/badge/'
            }
        },

        base64: {
            dist: {
                files: {
                    'tmp/photo.b64': 'tmp/photo.jpg'
                }
            }
        },

        // Fetch data from APIs
        curl: {
            githubRepos: {
                src: {
                    url: 'https://api.github.com/users/MarkBiesheuvel/repos?sort=pushed&page=1&per_page=3',
                    method: 'GET',
                    headers: githubHeaders
                },
                dest: 'tmp/github/repos.json'
            },
            backpackGroups: {
                src: {
                    url: 'https://backpack.openbadges.org/displayer/274141/groups.json',
                    method: 'GET'
                },
                dest: 'tmp/backpack/groups.json'
            }
        },

        template: {
            dist: {
                options: {
                    data: function () {

                        var data = {
                            photo: grunt.file.read('tmp/photo.b64'),
                            repos: grunt.file.readJSON('tmp/github/repos.json'),
                            photoSize: photoSize
                        };

                        data.repos.map(function (repo) {
                            repo.commits = grunt.file.readJSON('tmp/github/repos/' + repo.id + '.json');

                            return repo;
                        });

                        return data;
                    }
                },
                files: {
                    'tmp/index1.html': ['src/index.html.tpl']
                }
            }
        },

        processhtml: {
            dist: {
                files: {
                    'tmp/index2.html': ['tmp/index1.html']
                }
            }
        },

        // Compress HTML
        htmlmin: {
            dist: {
                options: {
                    removeComments: true,
                    collapseWhitespace: true
                },
                files: {
                    'dist/index.html': 'tmp/index2.html'
                }
            }
        },

        // Watch tasks
        watch: {

            // If this file changes we need to reloaded
            // Furthermore it might be necessary to rebuild files that are generated by settings in here
            gruntfile: {
                files: ['Gruntfile.js'],
                tasks: ['jshint:gruntfile'],
                options: {
                    reload: true
                }
            },

            // Validate and compress Javascript on change
            js: {
                files: ['src/js/**/*.js'],
                tasks: ['build:js', 'build:html'],
                options: {
                    interrupt: true,
                    livereload: true
                }
            },

            // Compile CSS on change
            css: {
                files: 'src/css/**/*.less',
                tasks: ['build:css', 'build:html'],
                options: {
                    interrupt: true,
                    livereload: true
                }
            },

            // Compile and compress HTML on change
            html: {
                files: 'src/index.html.tpl',
                tasks: ['build:html'],
                options: {
                    interrupt: true,
                    livereload: true
                }
            },

            other: {
                files: ['src/**', 'src/.htaccess', '!src/index.html.tpl', '!src/js/**', '!src/css/**', '!src/img/**'],
                tasks: ['copy'],
                options: {
                    interrupt: true,
                    livereload: true
                }
            }
        }

    });

    // Load the plugins
    require('load-grunt-tasks')(grunt);

    grunt.registerTask('curl:githubCommits',
        'Download commits for each repository',
        function () {

            var repos = grunt.file.readJSON('tmp/github/repos.json');

            var config = {
                curl: {}
            };
            var tasks = [];

            repos.forEach(function (repo, i) {

                var taskName = 'githubCommits' + repo.id;
                var url = repo.commits_url;

                url = url.replace('{/sha}', '');
                url += '?page=1&per_page=3';

                config.curl[taskName] = {
                    src: {
                        url: url,
                        method: 'GET',
                        headers: githubHeaders
                    },
                    dest: 'tmp/github/repos/' + repo.id + '.json'
                };

                tasks.push('curl:' + taskName);
            });

            grunt.config.merge(config);
            grunt.task.run(tasks);

        }
    );

    grunt.registerTask('curl:backpackBadges',
        'Download badges for each collection',
        function () {

            var groups = grunt.file.readJSON('tmp/backpack/groups.json').groups;

            var config = {
                curl: {}
            };
            var tasks = [];

            groups.forEach(function (group, i) {

                var id = group.groupId;
                var taskName = 'backpackBadges' + id;
                var url = 'https://backpack.openbadges.org/displayer/274141/group/' + id + '.json';

                config.curl[taskName] = {
                    src: {
                        url: url,
                        method: 'GET',
                    },
                    dest: 'tmp/backpack/groups/' + id + '.json'
                };

                tasks.push('curl:' + taskName);
            });

            grunt.config.merge(config);
            grunt.task.run(tasks);
        }
    );

    grunt.registerTask('curl:backpackImages',
        '', function () {

            var path = require('path');
            var fs = require('fs');

            var groups = fs.readdirSync('tmp/backpack/groups');

            var config = {
                curl: {}
            };
            var tasks = [];

            groups.forEach(function (group, i) {

                var badges = grunt.file.readJSON('tmp/backpack/groups/' + group).badges;

                badges.forEach(function (badge, j) {

                    var taskName = 'backpackImages' + i + '-' + j;
                    var url = badge.imageUrl;
                    var file = path.basename(url);

                    config.curl[taskName] = {
                        src: {
                            url: url,
                            method: 'GET',
                        },
                        dest: 'tmp/backpack/images/' + file
                    };

                    tasks.push('curl:' + taskName);
                });
            });

            grunt.config.merge(config);
            grunt.task.run(tasks);
        }
    );

    grunt.registerTask(
        'build:html+css+js',
        'Compile template to HTML and compress',
        function () {

            if (!grunt.file.exists('tmp/github/repos.json')) {
                grunt.task.run('curl:githubRepos');
            }

            if (!grunt.file.exists('tmp/github/repos/')) {
                grunt.task.run('curl:githubCommits');
            }

            grunt.task.run([
                'template:dist',

                'less:dist',
                'uncss:dist',
                'cssmin:dist',

                'uglify:dist',

                'processhtml:dist',
                'htmlmin:dist'
            ]);
        }
    );

    grunt.registerTask(
        'build:badges',
        'Download and resize badges',
        function () {

            if (!grunt.file.exists('tmp/github/groups.json')) {
                grunt.task.run('curl:backpackGroups');
            }

            if (!grunt.file.exists('tmp/backpack/groups/')) {
                grunt.task.run('curl:backpackBadges');
            }

            if (!grunt.file.exists('tmp/backpack/images/')) {
                grunt.task.run('curl:backpackImages');
            }

            grunt.task.run('image_resize:badges');
        }
    )

    grunt.registerTask(
        'build:img',
        'Resize and compress images',
        ['image_resize:lossless', 'image_resize:compressed', 'base64:dist']
    );

    grunt.registerTask(
        'build',
        'Make a clean build',
        ['clean:dist', 'clean:tmp', 'build:img', 'build:html+css+js', 'copy:dist']
    );

};
