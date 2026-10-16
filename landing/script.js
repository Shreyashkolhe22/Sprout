// Tiny progressive enhancements. The page works fine without JavaScript.
(function () {
  'use strict';

  // 1. Copy buttons -----------------------------------------------------
  function copyText(text) {
    if (navigator.clipboard && window.isSecureContext) {
      return navigator.clipboard.writeText(text);
    }
    // Fallback for older browsers / non-https previews.
    return new Promise(function (resolve, reject) {
      var area = document.createElement('textarea');
      area.value = text;
      area.setAttribute('readonly', '');
      area.style.position = 'fixed';
      area.style.opacity = '0';
      document.body.appendChild(area);
      area.select();
      try {
        document.execCommand('copy') ? resolve() : reject(new Error('copy failed'));
      } catch (error) {
        reject(error);
      } finally {
        document.body.removeChild(area);
      }
    });
  }

  function flash(button, message) {
    var original = button.getAttribute('data-label') || button.textContent;
    button.setAttribute('data-label', original);
    button.textContent = message;
    window.setTimeout(function () {
      button.textContent = original;
    }, 1800);
  }

  document.addEventListener('click', function (event) {
    var button = event.target.closest('[data-copy-target], [data-copy-page]');
    if (!button) return;

    var text;
    if (button.hasAttribute('data-copy-page')) {
      text = window.location.origin + window.location.pathname;
    } else {
      var target = document.getElementById(button.getAttribute('data-copy-target'));
      text = target ? target.textContent.trim() : '';
    }
    if (!text) return;

    copyText(text).then(
      function () { flash(button, 'Copied!'); },
      function () { flash(button, 'Press and hold to copy'); }
    );
  });

  // 2. Hint for visitors who are not on an Android phone ----------------
  var hint = document.getElementById('desktop-hint');
  if (hint && !/Android/i.test(navigator.userAgent)) {
    hint.classList.add('is-visible');
  }
})();
