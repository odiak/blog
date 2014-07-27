(function () {
  $(function () {
    var postForm, submitFlag, $title, $body, title, body;

    postForm = $('.post-form');
    submitFlag = false

    postForm.find('.preview-button').on('click', function () {
      var action = postForm.attr('action') || '';
      var target = postForm.attr('target') || '';
      postForm.attr('action', '/posts/preview');
      postForm.attr('target', '_blank');
      postForm.submit();
      postForm.attr('action', action);
      postForm.attr('target', target);
    });

    postForm.on("submit", function () {
      submitFlag = true;
    });

    $('.delete-form').on('submit', function () {
      submitFlag = true;
      var res = confirm('Are you sure?');
      return !!res;
    });

    if (postForm.length > 0) {
      $title = postForm.find("[name=title]");
      $body = postForm.find("[name=body]");
      title = $title.val();
      body = $body.val();
      $(window).on("beforeunload", function (event) {
        if (!submitFlag && ($title.val() !== title || $body.val() !== body)) {
          event.returnValue = "This post is not saved yet.";
        }
      });
    }
  });
})();
