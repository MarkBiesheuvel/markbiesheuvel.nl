$(function () {

    $.ajax({
        type: 'GET',
        url: 'https://api.github.com/repos/MarkBiesheuvel/markbiesheuvel.nl/commits?page=1&per_page=10',
        headers: {
            'Accept': 'application/vnd.github.v3+json'
        },
        success: function(commits){

            var html = '<ul>';

            $.each(commits, function(i, commit){
                html += '<li>'+commit.commit.message+'</li>';
            });

            html += '</ul>';

            $('#panel-github').html(html);
        }
    });
});

