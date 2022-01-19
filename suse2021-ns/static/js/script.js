/*
JavaScript for SUSE documentation

Authors:
   Stefan Knorr, Thomas Schraitle, Adam Spiers

License: GPL 2+

(c) 2012-2019 SUSE LLC
*/

var bugtrackerUrl = $( 'meta[name="tracker-url"]' ).attr('content');
var bugtrackerType = $( 'meta[name="tracker-type"]' ).attr('content');

// we handle Github (= gh) and bugzilla.suse.com (= bsc), default to bsc
if ((bugtrackerType != 'gh') && (bugtrackerType != 'bsc')) {
  bugtrackerType = 'bsc';
}

// For Bugzilla
var bscComponent = $( 'meta[name="tracker-bsc-component"]' ).attr('content');
if (!bscComponent) {
  bscComponent = 'Documentation'; // default component
}
var bscProduct = $( 'meta[name="tracker-bsc-product"]' ).attr('content');
var bscAssignee = $( 'meta[name="tracker-bsc-assignee"]' ).attr('content');
var bscVersion = $( 'meta[name="tracker-bsc-version"]' ).attr('content');
var bscTemplate = $( 'meta[name="tracker-bsc-template"]' ).attr('content');
// For GitHub
var ghAssignee = $( 'meta[name="tracker-gh-assignee"]' ).attr('content');
var ghLabels = $( 'meta[name="tracker-gh-labels"]' ).attr('content');
var ghMilestone = $( 'meta[name="tracker-gh-milestone"]' ).attr('content');
var ghTemplate = $( 'meta[name="tracker-gh-template"]' ).attr('content');


$(function() {

  $('body').removeClass('js-off');
  $('body').addClass('js-on');

  /* http://css-tricks.com/snippets/jquery/smooth-scrolling/ */
  var speed = 400;
  $('a.top-button[href=#]').click(function() {
    $('html,body').animate({ scrollTop: 0 }, speed,
      function() { location = location.pathname + '#'; });
    return false;
  });

  hashActivator();
  window.onhashchange = hashActivator;

  $('._share-print').show();

  if (location.protocol.match(/^http/)) {
    $('body').removeClass('offline');
  }

  $('._share-fb').click(function(){share('fb');});
  $('._share-in').click(function(){share('in');});
  $('._share-tw').click(function(){share('tw');});
  $('._share-mail').click(function(){share('mail');});
  $('._print-button').click(function(){print();});


  $('#_side-toc-overall li > a.has-children').click(function(e){ $(this).parent('li').toggleClass('active'); e.preventDefault(); e.preventDefault(); return false; });

  $('.question').click(function(){ $(this).parent('dl').toggleClass('active'); });
  $('.table tr').has('td[rowspan]').addClass('contains-rowspan');
  $('.informaltable tr').has('td[rowspan]').addClass('contains-rowspan');

  if ( !( $('#_nav-area div').length ) ) {
    $('#_toolbar').addClass('only-toc');
  }
  else if ( !( $('#_toc-area div').length && $('#_nav-area div').length ) ) {
    $('#_toolbar').addClass('only-nav');
  }

  addBugLinks();
  // hljs likes to unset click handlers, so run after it
  var hljsInterval = window.setInterval(function() {
    if (typeof(hljs) !== 'undefined') {
      addClipboardButtons();
      window.clearInterval(hljsInterval);
    };
  }, 500);
});


function addBugLinks() {
  // do not create links if there is no URL
  if ( typeof(bugtrackerUrl) == 'string') {
    $('.permalink:not([href^=#idm])').each(function () {
      var permalink = this.href;
      var sectionNumber = "";
      var sectionName = "";
      var url = "";
      if ( $(this).prevAll('span.number')[0] ) {
        sectionNumber = $(this).prevAll('span.number')[0].innerHTML;
      }
      if ( $(this).prevAll('span.number')[0] ) {
        sectionName = $(this).prevAll('span.name')[0].innerHTML;
      }

      if (bugtrackerType == 'bsc') {
        url = bugzillaUrl(sectionNumber, sectionName, permalink);
      }
      else {
        url = githubUrl(sectionNumber, sectionName, permalink);
      }

      $(this).before("<a class=\"report-bug\" rel=\"nofollow\" target=\"_blank\" href=\""
        + url
        + "\" title=\"Report a bug against this section of the documentation\">Report Documentation Bug</a> ");
      return true;
    });
  }
  else {
    return false;
  }
}

function githubUrl(sectionNumber, sectionName, permalink) {
  var body = sectionNumber + " " + sectionName + ":\n\n" + permalink;
  if (ghTemplate) {
    if (ghTemplate.indexOf('@@source@@') !== -1) {
      body = ghTemplate.replace(/@@source@@/i, body);
    } else {
      body = body + '\n' + ghTemplate;
    };
  };
  var url = bugtrackerUrl
     + "?title=" + encodeURIComponent('[doc] ' + sectionNumber + ' ' + sectionName)
     + "&amp;body=" + encodeURIComponent(body);
  if (ghAssignee) {
    url += "&amp;assignee=" + encodeURIComponent(ghAssignee);
  }
  if (ghMilestone) {
    url += "&amp;milestone=" + encodeURIComponent(ghMilestone);
  }
  if (ghLabels) {
    url += "&amp;labels=" + encodeURIComponent(ghLabels);
  }
  return url;
}

function bugzillaUrl(sectionNumber, sectionName, permalink) {
  var body = sectionNumber + " " + sectionName + ":\n\n" + permalink;
  if (bscTemplate) {
    if (bscTemplate.indexOf('@@source@@') !== -1) {
      body = bscTemplate.replace(/@@source@@/i, body);
    } else {
      body = body + '\n' + bscTemplate;
    };
  };
  var url = bugtrackerUrl + "?&amp;product=" + encodeURIComponent(bscProduct)
    + '&amp;component=' + encodeURIComponent(bscComponent)
    + "&amp;short_desc=" + encodeURIComponent('[doc] ' + sectionNumber + ' ' + sectionName)
    + "&amp;comment=" + encodeURIComponent(body);
  if (bscAssignee) {
    url += "&amp;assigned_to=" + encodeURIComponent(bscAssignee);
  }
  if (bscVersion) {
    url += "&amp;version=" + encodeURIComponent(bscVersion);
  }
  return url;
}

function addClipboardButtons() {
  $( ".verbatim-wrap > pre" ).each(function () {
      var clipButton = $('<button/>', {
          class: 'clip-button',
          text: 'Copy',
          click: function () {
            var elm = this.previousSibling;
            copyToClipboard(elm);
            elm.parentElement.classList.add("copy-success");
            setTimeout(function() {
              elm.parentElement.classList.remove("copy-success");
            }, 1000);
          }
        }
      );
      $(this).after(clipButton);
      return true;
    }
  );
}

function copyToClipboard(elm) {
  // use temporary hidden form element for selection and copy action
  var targetId = "__hiddenCopyText__";
  target = document.getElementById(targetId);
  if (!target) {
    var target = document.createElement("textarea");
    target.style.position = "fixed";
    target.style.left = "-9999px";
    target.style.top = "0";
    target.id = targetId;
    document.body.appendChild(target);
  } else {
    // empty out old content
    target.textContent = "";
  };
  $(elm).contents().each(function () {
      try {
        // we only want user-selectable elements, but not prompts.
        // (notably, if we have deeper nesting of inline elements, this
        // detection will fail but it should be good enough for common cases)
        if (getComputedStyle(this)['user-select'] != 'none') {
          target.textContent += this.textContent;
        };
      } catch(e) {
        // it's not an element node but a text node, so we always want it
        target.textContent += this.textContent;
      };
    }
  );
  // select the content
  var currentFocus = document.activeElement;
  target.focus();
  target.setSelectionRange(0, target.value.length);

  // copy the selection
  var succeed;
  try {
    succeed = document.execCommand("copy");
  } catch(e) {
    succeed = false;
  }
  // restore original focus
  if (currentFocus && typeof currentFocus.focus === "function") {
    currentFocus.focus();
  }

  return succeed;
}


function hashActivator() {
  if ( location.hash.length ) {
    var locationhash = location.hash.replace( /(:|\.|\[|\])/g, "\\$1" );
    if ( $( locationhash ).is(".free-id") ) {
      $( locationhash ).next(".qandaentry").addClass('active');
    };
    if ( $( locationhash ).is(".question") ) {
      location.hash = $( locationhash ).parent(".qandaentry").prev('.free-id').attr('id');
    };
  };
}

function share( service ) {
  // helpful: https://github.com/bradvin/social-share-urls
  u = encodeURIComponent( document.URL );
  t = encodeURIComponent( document.title );
  shareSettings = 'menubar=0,toolbar=1,status=0,width=600,height=650';
  if ( service == 'fb' ) {
    shareURL = 'https://www.facebook.com/sharer.php?u=' + u + '&amp;t=' + t;
    window.open(shareURL,'sharer', shareSettings);
  }
    else if ( service == 'tw' ) {
    shareURL = 'https://twitter.com/share?text=' + t + '&amp;url=' + u + '&amp;hashtags=suse,docs';
    window.open(shareURL, 'sharer', shareSettings);
  }
    else if ( service == 'in' ) {
    shareURL = 'https://www.linkedin.com/shareArticle?mini=true&' + u + '&amp;title=' + t;
    window.open(shareURL, 'sharer', shareSettings);
  }
    else if ( service == 'mail' ) {
    shareURL = 'mailto:?subject=Check%20out%20the%20SUSE%20Documentation%2C%20%22' + t + '%22&body=' + u;
    window.location.assign(shareURL);
  };
}
