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
      submitFlag = true;
      var res = confirm('Are you sure?');
      return !!res;
    });
    
    var submitFlag = false;
    postForm.on("submit", function () {
      submitFlag = true;
    });
    
    var $title, $body, title, body;
    if (postForm.length > 0) {
      $title = postForm.find("[name=title]");
      $body = postForm.find("[name=body]");
      title = $title.val();
      body = $body.val();
      $(window).on("beforeunload", function () {
        if (!submitFlag && ($title.val() !== title || $body.val() !== body)) {
          return "This post is not saved yet."
        }
      });
    }
  });
})(jQuery);
