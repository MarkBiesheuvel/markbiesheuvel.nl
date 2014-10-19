
$(function(){

    var $github_details = $('#github-details');

    $('#github-commits').find('a').each(function(){

        var $this = $(this);
        var html_url = $this.attr('href');
        var sha = /\/([a-f0-9]+)$/.exec(html_url)[1];

        $this.on('mouseenter', function(){
            $github_details.html(sha);
        });

        $this.on('mouseleave', function(){
            $github_details.html('&nbsp;');
        });
    });
});
