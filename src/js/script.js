window.addEventListener('load', function () {
    document.getElementById('photo').src = 'img/photo.jpg';
    var star = document.getElementById('star');
    var tooltip = document.getElementById('tooltip');
    star.onmouseover = function () {
        var rect = star.getBoundingClientRect();
        var left = rect.left + (window.pageXOffset || document.documentElement.scrollLeft);
        var top = rect.top + (window.pageYOffset || document.documentElement.scrollTop);
        left -= 141;
        top -= 62;
        tooltip.style = 'top:' + top + 'px;left:' + left + 'px;display:block';
    };
    star.onmouseout = function () {
        tooltip.style = 'display:none';
    };
}, false);