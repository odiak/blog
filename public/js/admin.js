(function ($) {
  $(function () {
    var e = $('<div class="admin"><div class="new">+new</div><div class="edit">edit</div></div>');
    e.find('.new').on('click', function () {
      location.href = '/posts/new';
    });
    e.find('.edit').on('click', function () {
      location.href = location.pathname + '/edit';
    });
    if (!location.pathname.match(/^\/posts\/\d+/)) {
      e.find('.edit').remove();
    }
    $('body').append(e);
  });
})(jQuery);