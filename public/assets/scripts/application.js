(function() {
  $(function() {
    var app, apps, bezierCurve, contacts, easeOutFunction, element, j, k, len, len1, link, navigation_links, ref, scrollTo, scroll_links;
    apps = ['automatic', 'mapquest', 'stanley', 'mapquest-travel-blogs', 'erudio', 'growlvoice'];
    contacts = ['email', 'dribbble', 'github', 'twitter', 'medium'];
    window.swipes = (function() {
      var j, len, results;
      results = [];
      for (j = 0, len = apps.length; j < len; j++) {
        app = apps[j];
        results.push(Swipe(document.getElementById(app + "-slider")));
      }
      return results;
    })();
    navigation_links = [
      {
        link: 'apps',
        sublinks: apps.slice(0)
      }, {
        link: 'libraries',
        sublinks: []
      }, {
        link: 'contact',
        sublinks: contacts.slice(0)
      }
    ];
    bezierCurve = function(x1, y1, x2, y2) {
      var cache, cachingInterval, closestCachedT, curveX, curveY, derivativeCurveX, findCachedValueAround, i, invertCachingInterval, t;
      curveX = function(t) {
        var v;
        v = 1 - t;
        return 3 * v * v * t * x1 + 3 * v * t * t * x2 + t * t * t;
      };
      curveY = function(t) {
        var v;
        v = 1 - t;
        return 3 * v * v * t * y1 + 3 * v * t * t * y2 + t * t * t;
      };
      derivativeCurveX = function(t) {
        var v;
        v = 1 - t;
        return 3 * (2 * (t - 1) * t + v * v) * x1 + 3 * (-t * t * t + 2 * v * t) * x2;
      };
      cache = {};
      cachingInterval = 0.001;
      invertCachingInterval = 1 / cachingInterval;
      i = 0;
      while (i <= invertCachingInterval) {
        t = curveX(i * cachingInterval);
        closestCachedT = Math.round(t / cachingInterval);
        cache[closestCachedT] = curveY(i * cachingInterval);
        i += 1;
      }
      findCachedValueAround = function(t, precision) {
        var incr, originalT, y;
        t = Math.round(t / cachingInterval);
        precision = precision * invertCachingInterval;
        originalT = t;
        y = cache[t];
        incr = 1;
        while (!y) {
          t = originalT + incr;
          if (Math.abs(t - originalT) > precision) {
            break;
          }
          if (incr > 0) {
            incr = -incr;
          } else {
            incr = -2 * incr;
          }
          y = cache[t];
        }
        return y;
      };
      return function(t, precision) {
        var t0, t1, t2, y;
        y = findCachedValueAround(t, precision);
        if (!y) {
          t0 = 0;
          t1 = 1;
          t2 = t;
          x2 = void 0;
          while (t0 < t1) {
            x2 = curveX(t2);
            if (Math.abs(x2 - t) < precision) {
              y = curveY(t2);
              break;
            }
            if (t > x2) {
              t0 = t2;
            } else {
              t1 = t2;
            }
            t2 = (t1 - t0) * .5 + t0;
          }
          cache[Math.round(t / cachingInterval)] = y;
        }
        return y;
      };
    };
    easeOutFunction = bezierCurve(.645, .045, .355, 1);
    scrollTo = function(to, duration, easingFunction, completion) {
      var documentHeight, from, precision, root, scroll, startDate, windowHeight;
      scroll = function(timestamp) {
        var currentTime, easedT, t;
        currentTime = Date.now();
        t = Math.min(1, (currentTime - startDate) / duration);
        easedT = easingFunction(t, precision);
        root.scrollTop = easedT * (to - from) + from;
        if (t < 1) {
          requestAnimationFrame(scroll);
        }
        if (t === 1) {
          return completion();
        }
      };
      documentHeight = document.height;
      windowHeight = window.innerHeight;
      if (to > documentHeight - windowHeight) {
        to = documentHeight - windowHeight;
      }
      root = (document.documentElement.scrollTop ? document.documentElement : document.body);
      from = root.scrollTop;
      startDate = Date.now();
      precision = 1 / 240 / (duration / 1000);
      if (from !== to) {
        return requestAnimationFrame(scroll);
      } else {
        return requestAnimationFrame(completion);
      }
    };
    (function() {
      var requestAnimationFrame;
      requestAnimationFrame = window.requestAnimationFrame || window.mozRequestAnimationFrame || window.webkitRequestAnimationFrame || window.msRequestAnimationFrame;
      return window.requestAnimationFrame = requestAnimationFrame;
    })();
    scroll_links = apps.concat(['libraries']);
    for (j = 0, len = scroll_links.length; j < len; j++) {
      link = scroll_links[j];
      ref = document.querySelectorAll("[href='#" + link + "']");
      for (k = 0, len1 = ref.length; k < len1; k++) {
        element = ref[k];
        element.addEventListener("click", function(e) {
          e.preventDefault();
          scrollTo(document.querySelector(this.getAttribute("href")).offsetTop, 1000, easeOutFunction);
          return true;
        });
      }
    }
    document.querySelector('.nav-apps-link').addEventListener("click", function(e) {
      return scrollTo(0, 1000, easeOutFunction, function() {
        return $("#nav-apps").parent().addClass("open");
      });
    });
    return document.querySelector('.nav-contact-link').addEventListener("click", function(e) {
      return scrollTo(0, 1000, easeOutFunction, function() {
        return $("#nav-contact").parent().addClass("open");
      });
    });
  });

}).call(this);
