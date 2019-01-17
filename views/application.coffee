$ ->
  apps = ['automatic', 'mapquest', 'stanley', 'mapquest-travel-blogs', 'erudio', 'growlvoice']
  contacts = ['email', 'dribbble', 'github', 'twitter']

  window.swipes = for app in apps
    Swipe(document.getElementById("#{app}-slider"))

  navigation_links = [{
    link: 'apps',
    sublinks: apps.slice(0)
  }, {
    link: 'libraries',
    sublinks: []
  }, {
    link: 'contact',
    sublinks: contacts.slice(0)
  }]

  bezierCurve = (x1, y1, x2, y2) ->
    curveX = (t) ->
      v = 1 - t
      3 * v * v * t * x1 + 3 * v * t * t * x2 + t * t * t

    curveY = (t) ->
      v = 1 - t
      3 * v * v * t * y1 + 3 * v * t * t * y2 + t * t * t

    derivativeCurveX = (t) ->
      v = 1 - t
      3 * (2 * (t - 1) * t + v * v) * x1 + 3 * (-t * t * t + 2 * v * t) * x2

    cache = {}
    cachingInterval = 0.001
    invertCachingInterval = 1 / cachingInterval
    i = 0

    while i <= invertCachingInterval
      t = curveX(i * cachingInterval)
      closestCachedT = Math.round(t / cachingInterval)
      cache[closestCachedT] = curveY(i * cachingInterval)
      i += 1
    findCachedValueAround = (t, precision) ->
      t = Math.round(t / cachingInterval)
      precision = precision * invertCachingInterval
      originalT = t
      y = cache[t]
      incr = 1
      until y
        t = originalT + incr
        break  if Math.abs(t - originalT) > precision
        if incr > 0
          incr = -incr
        else
          incr = -2 * incr
        y = cache[t]
      y

    (t, precision) ->
      y = findCachedValueAround(t, precision)
      unless y
        t0 = 0
        t1 = 1
        t2 = t
        x2 = undefined
        while t0 < t1
          x2 = curveX(t2)
          if Math.abs(x2 - t) < precision
            y = curveY(t2)
            break
          if t > x2
            t0 = t2
          else
            t1 = t2
          t2 = (t1 - t0) * .5 + t0
        cache[Math.round(t / cachingInterval)] = y

      return y

  easeOutFunction = bezierCurve(.645, .045, .355, 1)

  scrollTo = (to, duration, easingFunction, completion) ->
    scroll = (timestamp) ->
      currentTime = Date.now()
      t = Math.min(1, ((currentTime - startDate) / duration))
      easedT = easingFunction(t, precision)
      root.scrollTop = easedT * (to - from) + from
      requestAnimationFrame scroll  if t < 1
      if t == 1
        completion()
    documentHeight = document.height
    windowHeight = window.innerHeight
    to = documentHeight - windowHeight  if to > documentHeight - windowHeight
    root = (if document.documentElement.scrollTop then document.documentElement else document.body)
    from = root.scrollTop
    startDate = Date.now()
    precision = 1 / 240 / (duration / 1000)
    if from != to
      requestAnimationFrame scroll
    else
      requestAnimationFrame completion
  (->
    requestAnimationFrame = window.requestAnimationFrame or window.mozRequestAnimationFrame or window.webkitRequestAnimationFrame or window.msRequestAnimationFrame
    window.requestAnimationFrame = requestAnimationFrame
  )()

  scroll_links = apps.concat(['libraries'])

  for link in scroll_links
    for element in document.querySelectorAll("[href='##{link}']")
      element.addEventListener "click", (e) ->
        e.preventDefault()
        scrollTo document.querySelector(this.getAttribute("href")).offsetTop, 1000, easeOutFunction
        return true

  document.querySelector('.nav-apps-link').addEventListener "click", (e) ->
    scrollTo 0, 1000, easeOutFunction, ->
      $("#nav-apps").parent().addClass "open"

  document.querySelector('.nav-contact-link').addEventListener "click", (e) ->
    scrollTo 0, 1000, easeOutFunction, ->
      $("#nav-contact").parent().addClass "open"
