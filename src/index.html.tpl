<!DOCTYPE html>
<html class="no-js">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
    <title>Mark Biesheuvel | Web application developer</title>
    <meta name="description" content="">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <style type="text/css">
        <%= css %>
    </style>
</head>
<body>

<div class="container">

    <header class="row">
        <div class="col-md-1">
            <img src="data:image/png;base64,<%= photo %>" id="photo" class="img-responsive img-rounded"
                 alt="Mark Biesheuvel">
        </div>
        <div class="col-md-3">
            <h1>Mark Biesheuvel</h1>

            <dl class="dl-horizontal">
                <dt>E-mail</dt>
                <dd><a href="mailto:mail@markbiesheuvel">mail@markbiesheuvel.nl</a></dd>
                <dt>Facebook</dt>
                <dd><a href="https://www.facebook.com/mark.biesheuvel" target="_blank">https://www.facebook.com/mark.biesheuvel</a></dd>
                <dt>LinkedIn</dt>
                <dd><a href="https://www.linkedin.com/profile/view?id=116319239" target="_blank">https://www.linkedin.com/profile/view?id=116319239</a></dd>
                <dt>GitHub</dt>
                <dd><a href="https://github.com/MarkBiesheuvel" target="_blank">https://github.com/MarkBiesheuvel</a></dd>
            </dl>
        </div>
    </header>

    <hr>

    <section class="row">
        <div class="col-md-1">
            <h2 class="section-title">Work experience</h2>
        </div>
        <div class="col-md-3">

            <h3><strong>QForma 2012 - present</strong></h3>

            <h4><a href="https://amazingcompany.eu/quecom" target="_blank">Quecom</a>
                <small>Web application with shop, sales reports, performance dashboards and more</small>
            </h4>
            <ul>
                <li>Improved release procedure to avoid system halting errors</li>
                <li>Restructured cache usage of ACL to reduce memory usage per request by 80%</li>
                <li>Added numerous new features: product relations, bundle offers, filters based on product features
                    and more
                </li>
                <li>Integration with VoIP provider via Chrome browser extension</li>
                <li>Use of Clockwork SMS API to send notifications to customers</li>
                <li>Daily imports from SAP and exports to client base</li>
            </ul>
            <h4>QAdmin
                <small>In-house web application for administration</small>
            </h4>
            <ul>
                <li>Added performance dashboard based on invoice and worked hour</li>
                <li>Improved invoice/billing module</li>
            </ul>
            <h4><a href="http://redusystems.com" target="_blank">Mardenkro</a>
                <small>Producer of removable coatings for green houses with international market</small>
            </h4>
            <ul>
                <li>Developed on top of an existing CMS</li>
                <li>Website in 14 different countries and 6 different languages</li>
                <li>Centralized content usable across all different countries/languages</li>
            </ul>
        </div>
    </section>

    <hr>

    <section class="row">
        <div class="col-md-1">
            <h2 class="section-title">GitHub</h2>
        </div>
        <div class="col-md-3">

            <h3><strong>Recent commits</strong></h3>

            <% _.each(repos, function(repo){ %>
            <h4>
                <a href="<%- repo.html_url %>" target="_blank">
                    <%- repo.name %>
                </a>
                <small>
                    <%- repo.description %>
                </small>
            </h4>
            <ul>
                <% _.each(repo.commits, function(commit){ %>
                <li>
                    <%- commit.commit.message %>
                </li>
                <% }); %>
            </ul>
            <% }); %>
        </div>
    </section>

</div>

<script type="application/javascript">
    <%= javascript %>
</script>

</body>
</html>
