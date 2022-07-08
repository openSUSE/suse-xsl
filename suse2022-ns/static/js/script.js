/*
JavaScript for SUSE documentation

Authors:
   Stefan Knorr, Thomas Schraitle, Adam Spiers

License: GPL 2+

(c) 2012-2022 SUSE LLC
*/


// GLOBALS

// Sticky headers
// must be same value as 0-style.sass $i_head_offset!
const cHeaderFixScrollStart = 65;

// we want these globally, but the DOM isn't there yet; probably doing it wrong
var eBody = null;
var eHead = null;
var eMain = null;
var eFoot = null;
var eSideTocAll = null;
var eSideTocPage = null;

var lastScrollPosition = 0;



function stickies() {
  // sticky header and nav https://stackoverflow.com/questions/23842100/
  // scroll-up header https://stackoverflow.com/questions/31223341/
  let scrollPosition = window.scrollY;
  let footTop = eFoot.getBoundingClientRect().top;
  let windowHeight = (window.innerHeight || document.documentElement.clientHeight);
  if (scrollPosition > cHeaderFixScrollStart) {
    eHead.classList.add("sticky");
    eMain.classList.add("sticky");
    if (scrollPosition < lastScrollPosition) {
      eBody.classList.add("scroll-up");
    } else {
      eBody.classList.remove("scroll-up");
    };
    lastScrollPosition = scrollPosition <= 0 ? 0 : scrollPosition;
  } else {
    eHead.classList.remove("sticky");
    eMain.classList.remove("sticky");
    eBody.classList.remove("scroll-up");
  };
  if (footTop <= windowHeight) {
    let fTocBottom = windowHeight - footTop;
    eMain.classList.add("scroll-with-footer");
  } else {
    eMain.classList.remove("scroll-with-footer");
  };
}

// Social sharing
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


// --- line of legacy jquery-based stuff ---


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


function githubUrl(sectionName, permalink) {
  var body = sectionName + ":\n\n" + permalink;
  if (ghTemplate) {
    if (ghTemplate.indexOf('@@source@@') !== -1) {
      body = ghTemplate.replace(/@@source@@/i, body);
    } else {
      body = body + '\n' + ghTemplate;
    };
  };
  var url = bugtrackerUrl
     + "?title=" + encodeURIComponent('[doc] Issue in "' + sectionName + '"')
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
};


function bugzillaUrl(sectionName, permalink) {
  var body = sectionName + ":\n\n" + permalink;
  if (bscTemplate) {
    if (bscTemplate.indexOf('@@source@@') !== -1) {
      body = bscTemplate.replace(/@@source@@/i, body);
    } else {
      body = body + '\n' + bscTemplate;
    };
  };
  var url = bugtrackerUrl + "?&amp;product=" + encodeURIComponent(bscProduct)
    + '&amp;component=' + encodeURIComponent(bscComponent)
    + "&amp;short_desc=" + encodeURIComponent('[doc] Issue in "' + sectionName + '"')
    + "&amp;comment=" + encodeURIComponent(body);
  if (bscAssignee) {
    url += "&amp;assigned_to=" + encodeURIComponent(bscAssignee);
  }
  if (bscVersion) {
    url += "&amp;version=" + encodeURIComponent(bscVersion);
  }
  return url;
};


// update the report bug url for the current section id as the user is scrolling
// minor hitch: if there is a very short section at the end of the page, it may
// not be picked up correctly by this.
function bugReportScrollSpy() {
  if (  typeof(bugtrackerUrl) == 'string' &&
        document.getElementById('_feedback-reportbug') !== null ) {
    var origin = window.location.origin;
    if (origin === 'null') {
      origin = '';
    }
    const plainBugUrl = origin + window.location.pathname;
    // Title selection fails silently, it's probably better that way
    var sectionName = '';
    var sectionBugUrl;
    if (bugtrackerType == 'bsc') {
      sectionBugUrl = bugzillaUrl(sectionName, plainBugUrl);
    }
    else {
      sectionBugUrl = githubUrl(sectionName, plainBugUrl);
    };
    document.querySelector('#_feedback-reportbug').href = sectionBugUrl;

    const observer = new IntersectionObserver(entries => {
      entries.every(entry => {
        if (entry.intersectionRatio > 0) {
          const id = entry.target.getAttribute('id');
          var origin = window.location.origin;
          if (origin === 'null') {
            origin = '';
          };
          const plainBugUrl = origin + window.location.pathname + '#' + id;
          var sectionName = '';
          if ( entry.target.getAttribute('data-id-title') !== null ) {
            sectionName = entry.target.getAttribute('data-id-title');
          };
          var sectionBugUrl;
          if (bugtrackerType == 'bsc') {
            sectionBugUrl = bugzillaUrl(sectionName, plainBugUrl);
          }
          else {
            sectionBugUrl = githubUrl(sectionName, plainBugUrl);
          };

          document.querySelector('#_feedback-reportbug').href = sectionBugUrl;
          return false;
        };
        return true;
      });
    });

    // Track all sections that have an `id` applied
    document.querySelectorAll('section[id]').forEach((section) => {
      observer.observe(section);
    });
  };
};


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
};

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
};


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
};


// INIT!

$(function() {

  eBody = document.body;
  eHead = document.getElementById('_mainnav');
  eMain = document.getElementById('_content');
  eFoot = document.getElementById('_footer');
  eSideTocAll = document.getElementById('_side-toc-overall');
  eSideTocPage = document.getElementById('_side-toc-page');

  eBody.classList.remove('js-off');
  eBody.classList.add('js-on');
  if (location.protocol.match(/^http/)) {
    eBody.classList.remove('offline');
  }

  hashActivator();
  window.onhashchange = hashActivator;


  lastScrollPosition = window.scrollY;
  stickies();
  window.addEventListener('scroll', function(){ stickies(); }, false);

  if ( document.getElementById('_share-fb') !== null ) {
    document.getElementById('_share-fb').addEventListener('click', function(e){share('fb'); e.preventDefault();}, false);
  };
  if ( document.getElementById('_share-in') !== null ) {
    document.getElementById('_share-in').addEventListener('click', function(e){share('in'); e.preventDefault();}, false);
  };
  if ( document.getElementById('_share-tw') !== null ) {
    document.getElementById('_share-tw').addEventListener('click', function(e){share('tw'); e.preventDefault();}, false);
  };
  if ( document.getElementById('_share-mail') !== null ) {
    document.getElementById('_share-mail').addEventListener('click', function(e){share('mail'); e.preventDefault();}, false);
  };
  if ( document.getElementById('_print-button') !== null ) {
    document.getElementById('_print-button').addEventListener('click', function(e){print(); e.preventDefault();}, false);
  };

  if (  document.getElementById('_utilitynav-search') !== null &&
        document.getElementById('_searchbox') !== null &&
        document.getElementById('_mainnav') !== null ) {
    document.getElementById('_utilitynav-search').addEventListener('click', function(e){
        document.getElementById('_mainnav').classList.add('show-search');
        e.preventDefault();
    }, false);
    document.getElementById('_searchbox').addEventListener('click', function(e){ e.stopPropagation(); }, false);
    document.getElementById('_utilitynav-search').addEventListener('click', function(e){ e.stopPropagation(); }, false);
 };

  if ( document.getElementById('_utilitynav-language') !== null &&
       document.getElementById('_mainnav') !== null ) {
    document.querySelector('#_utilitynav-language > .menu-item').addEventListener('click', function(e){
        document.getElementById('_utilitynav-language').classList.toggle('visible');
        e.preventDefault();
        e.stopPropagation();
    }, false);
  };

  eBody.addEventListener('click', function(e){
      if ( document.getElementById('_mainnav') !== null ) {
        document.getElementById('_mainnav').classList.remove('show-search');
      };
      if ( document.getElementById('_utilitynav-language') !== null ) {
        document.getElementById('_utilitynav-language').classList.remove('visible');
      };
  }, false);

  if (  eSideTocAll &&
        document.getElementById('_open-side-toc-overall') !== null) {
    document.getElementById('_open-side-toc-overall').addEventListener('click', function(e){
        eSideTocAll.classList.toggle('mobile-visible');
        e.preventDefault();
    }, false);
 };


  if ( eSideTocAll !== null ) {
    document.querySelectorAll('#_side-toc-overall li > a.has-children').forEach((elm) => {
        elm.addEventListener('click', function(e){
          this.parentElement.classList.toggle('active');
          e.preventDefault();
        }, false);
      });
  };

  if (  eSideTocPage !== null &&
        document.getElementById('_unfold-side-toc-page') !== null ) {
    if ( document.querySelector('#_side-toc-page .toc li') === null ) {
      document.getElementById('_unfold-side-toc-page').style.visibility = 'hidden';
    } else {
      document.getElementById('_unfold-side-toc-page').addEventListener('click', function(e){
          document.getElementById('_side-toc-page').classList.toggle('mobile-visible');
          e.preventDefault();
      }, false);
      document.getElementById('_side-toc-page').addEventListener('click', function(e){
          this.classList.remove('mobile-visible');
      }, false);
    };
  };


  if (  eSideTocAll !== null &&
        document.getElementById('_open-document-overview') !== null  ) {
    document.getElementById('_open-document-overview').addEventListener('click', function(e){
        eSideTocAll.classList.toggle('document-overview-visible');
        e.preventDefault();
    }, false);
  };


  document.querySelectorAll('.question').forEach((elm) => {
      elm.addEventListener('click', function(){
        this.parentElement.classList.toggle('active');
        e.preventDefault();
        }, false);
 });

 //  bugReportScrollSpy();
  console.log("Calling addBugLinks...")
  addBugLinks();

  // hljs likes to unset click handlers, so run after it
  // FIXME: this interval thing is a little crude
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
      console.log("this:", this.text,
                  $(this).prevAll('span.title-number')[0].innerHTML,
                  $(this).prevAll('span.title-name')[0].innerHTML
                  );
      if ( $(this).prevAll('span.title-number')[0] ) {
        sectionNumber = $(this).prevAll('span.title-number')[0].innerHTML;
      }
      if ( $(this).prevAll('span.title-number')[0] ) {
        sectionName = $(this).prevAll('span.title-name')[0].innerHTML;
      }

      if (bugtrackerType == 'bsc') {
        url = bugzillaUrl(sectionName, permalink);
      }
      else {
        url = githubUrl(sectionName, permalink);
      }

      $(this).before("<a class=\"report-bug\" target=\"_blank\" href=\""
        + url
        + "\" title=\"Report a bug against this section of the documentation\">Report Documentation Bug</a> ");
      return true;
    });
  }
  else {
    return false;
  }
}
