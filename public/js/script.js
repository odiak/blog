(function ($) {
  $(function () {
    var postForm = $('.post-form');
    postForm.find('.preview-button').on('click', function () {
      var action = postForm.attr('action') || '';
      var target = postForm.attr('target') || '';
      postForm.attr('action', '/posts/preview');
      postForm.attr('target', '_blank');
      postForm.submit();
      postForm.attr('action', action);
      postForm.attr('target', target);
    });
    
    $('.delete-form').on('submit', function () {
      var res = confirm('Are you sure?');
      return !!res;
    });
  });
})(jQuery);