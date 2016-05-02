<!DOCTYPE html>
<html class="no-js">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
    <title>Mark Biesheuvel | Web application developer</title>
    <meta name="author" content="Mark Biesheuvel">
    <meta name="description" content="Resume of Mark Biesheuvel, web application developer">
    <meta name="keywords" content="developer,mark,biesheuvel,web,application,api,performance,grunt">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="theme-color" content="#333">
    <meta property="og:title" content="Mark Biesheuvel">
    <meta property="og:url" content="https://markbiesheuvel.nl">
    <meta property="og:type" content="profile">
    <meta property="og:image" content="https://markbiesheuvel.nl/img/photo.jpg">
    <meta property="og:description" content="Resume of Mark Biesheuvel, web application developer">
    <link rel="canonical" href="https://markbiesheuvel.nl"/>

    <!-- build:css inline minified.css -->
    <link rel="stylesheet" href="compiled.css">
    <!-- /build -->
</head>
<body>

<div class="container">

    <header class="row">
        <div class="col-md-1">
            <img src="data:image/png;base64,<%= photo %>"
                 width="<%= photoSize %>"
                 height="<%= photoSize %>"
                 id="photo"
                 class="img-responsive img-rounded"
                 alt="Mark Biesheuvel">
        </div>
        <div class="col-md-3">
            <h1>
                Mark Biesheuvel
                <small class="visible-xs-block visible-sm-inline-block visible-md-inline-block visible-lg-inline-block">
                    Web application developer
                </small>
            </h1>

            <dl class="dl-horizontal">
                <dt>E-mail</dt>
                <dd>
                    <a href="mailto:mail@markbiesheuvel">
                        mail@markbiesheuvel.nl
                    </a>
                </dd>
                <dt>Facebook</dt>
                <dd>
                    <a href="https://www.facebook.com/mark.biesheuvel" target="_blank">
                        https://www.facebook.com/mark.biesheuvel
                    </a>
                </dd>
                <dt>LinkedIn</dt>
                <dd>
                    <a href="https://nl.linkedin.com/in/markbiesheuvel" target="_blank">
                        https://nl.linkedin.com/in/markbiesheuvel
                    </a>
                </dd>
                <dt>GitHub</dt>
                <dd>
                    <a href="https://github.com/MarkBiesheuvel" target="_blank">
                        https://github.com/MarkBiesheuvel
                    </a>
                </dd>
            </dl>

            <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas leo ligula, pretium consequat semper
                at, venenatis non lorem. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per
                inceptos himenaeos. Pellentesque lectus eros, sodales et lorem ut, convallis congue ipsum. Proin dui
                nunc, finibus id turpis nec, convallis congue diam. Vestibulum ante ipsum primis in faucibus orci luctus
                et ultrices posuere cubilia Curae; Aenean sagittis metus eget tellus fermentum condimentum. Donec id
                augue eget felis convallis porttitor. Mauris a imperdiet eros. Proin tincidunt ipsum in egestas finibus.
                Vestibulum vel lectus vulputate, aliquam ipsum eu, viverra mi.</p>
            <p>Ut sed euismod nibh, ut sodales dui. Duis nec enim dapibus, egestas nunc quis, pretium metus. Quisque
                efficitur, sem lobortis elementum laoreet, tellus diam accumsan risus, a dignissim sapien mi eu nisi.
                Suspendisse cursus augue et magna commodo iaculis. Fusce maximus interdum urna, non ultrices nunc
                convallis ac. Nulla consectetur semper massa nec vehicula. Duis facilisis semper malesuada. Sed ipsum
                turpis, hendrerit ut blandit et, tempus non sapien. Quisque fermentum semper nibh eu commodo.</p>
        </div>
    </header>

    <hr>

    <section class="row">
        <div class="col-md-1">
            <h2 class="section-title">Technical skills</h2>
        </div>
        <div class="col-md-3">
            <div class="row">
                <div class="col-sm-2">
                    <h3>Languages</h3>
                    <ul>
                        <li>PHP</li>
                        <li>JavaScript, ECMAScript 2015</li>
                        <li>SQL</li>
                        <li>Less, Sass, CSS</li>
                    </ul>
                </div>
                <div class="col-sm-2">
                    <h3>Frameworks / CMS / Libraries</h3>
                    <ul>
                        <li>Zend Framework</li>
                        <li>pimcore</li>
                        <li>Expression Engine</li>
                        <li>jQuery</li>
                        <li>Bootstrap</li>
                    </ul>
                </div>
                <div class="col-sm-2">
                    <h3>
                        Cloud services
                        <small>AWS</small>
                    </h3>
                    <ul>
                        <li>CloudFront (edge location caching)</li>
                        <li>Lambda (event based computing)</li>
                        <li>OpsWorks (server configuration management)</li>
                        <li>other core services like EC2, S3, RDS, Route53</li>
                    </ul>
                </div>
                <div class="col-sm-2">
                    <h3>Development tools</h3>
                    <ul>
                        <li>Regular Expressions</li>
                        <li>Git</li>
                        <li>Grunt</li>
                        <li>Travis CI</li>
                        <li>Yeoman</li>
                    </ul>
                </div>
            </div>
        </div>
    </section>
    <hr>

    <section class="row">
        <div class="col-md-1">
            <h2 class="section-title">Work Experience</h2>
        </div>
        <div class="col-md-3">

            <h3>
                <strong><a href="http://qforma.nl" target="_blank">QForma</a></strong>
                <small>2012 - present</small>
            </h3>

            <strong>Responsibilities</strong>
            <ul>
                <li>Designing database structure and optimizing queries</li>
                <li>Developing custom add-ons to customer requirements</li>
                <li>Integration front-end (JavaScript) with back-end (PHP)</li>
                <li>Researching new technologies and business opportunities</li>
                <li>Operating cloud infrastructure for continuous deployment</li>
            </ul>

            <strong>Achievements</strong>
            <ul>
                <li>Replaced generated code from a CMS by an optimized query to make page loads 10 times faster</li>
                <li>Restructured cache usage of ACL to reduce memory usage per request by 80%</li>
                <li>Developed a real-time integration between VoIP system and web app to relay customer information as
                    calls come in
                </li>
                <li>Migrated web applications to AWS to reduce hosting costs by approximately 50%</li>
            </ul>

        </div>
    </section>

    <hr>

    <section class="row">
        <div class="col-md-1">
            <h2 class="section-title">Education</h2>
        </div>
        <div class="col-md-3">

            <h3>
                <strong>Eindhoven University of Technology</strong>
                <small>2009 - 2012</small>
            </h3>

            <strong>Courses</strong>
            <ul>
                <li>Object Oriented Programming</li>
                <li>Data structures</li>
                <li>Algorithms</li>
                <li>Datamodeling and databases</li>
                <li>Computer networks</li>
                <li>Functional programming</li>
            </ul>

        </div>
    </section>

    <hr>

    <section class="last">
        <p class="text-center">
            <span class="hidden-xs">&mdash;</span>
            For further information about my experience please feel free to contact me at
            <a href="mailto:mail@markbiesheuvel">mail@markbiesheuvel.nl</a>
            <span class="hidden-xs">&mdash;</span>
        </p>
    </section>

</div>

<!-- build:js inline script.min.js -->
<!-- /build -->
</body>
</html>
