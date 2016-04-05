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
            <h1>Mark Biesheuvel</h1>

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
        </div>
    </header>

    <hr>

    <section class="row">

        <div class="col-md-1">
            <h2 class="section-title">Statistics</h2>
        </div>
        <div class="col-md-3">
            <h3>Time metrics of current request</h3>

            <table class="table">
                <thead>
                <tr>
                    <th>Metric</th>
                    <th>Time since previous metric</th>
                    <th>Time since start of request</th>
                </tr>
                </thead>
                <tbody id="timing-stats">
                <tr>
                    <td>fetch</td>
                    <td>0 ms</td>
                    <td>0 ms</td>
                </tr>
                </tbody>
            </table>

        </div>
    </section>

    <section class="row">
        <div class="col-md-1">
            <h2 class="section-title">BADGES</h2>
        </div>
        <div class="col-md-3">

            <h3><strong><a href="https://qwiklabs.com/">Qwiklabs</a></strong></h3>

            <h4>AWS</h4>
            <div id="aws" class="icons">
                <div><!-- The reason this div is here is so that uncss won't remove the styling on .icons>* --></div>
            </div>

            <h3><strong><a href="https://www.codeschool.com/" target="_blank">Codeschool</a></strong></h3>

            <h4>JavaScript</h4>
            <div id="javascript" class="icons">
            </div>

            <h4>Databases</h4>
            <div id="databases" class="icons">
            </div>

            <h4>Git</h4>
            <div id="git" class="icons">
            </div>

            <h4>CSS and Sass</h4>
            <div id="css" class="icons">
            </div>

        </div>
    </section>

</div>

<link rel="stylesheet" href="spritesheet.css">
<!-- build:js inline script.min.js -->
<!-- /build -->
</body>
</html>
