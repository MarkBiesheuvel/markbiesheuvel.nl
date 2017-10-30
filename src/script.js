((document, window) => {
  // Calculate delta between a and b assuming b is smaller
  const delta = (a, b) => (b < a) ? (a - b) : 0

  // Get an element by its role
  const $ = (parent, role) => parent.querySelector(`[role=${role}]`)

  // Sets the text content of an element
  const text = (element, text) => {
    element.textContent = text
  }

  // Sets the href of an element
  const href = (element, href) => {
    element.href = href
  }

  // Set the src of an element
  const src = (element, src) => {
    element.src = src
  }

  // Removes an element from the DOM
  const remove = (element) => {
    element.parentElement.removeChild(element)
  }

  // Append after
  const append = (existing, element) => {
    existing.parentElement.appendChild(element)
  }

  // Fade in
  const fadeIn = (element, i) => {
    // Store style in variable for easy access
    const style = element.style

    // Let each element fade in over 300ms
    const duration = 300
    // Get time since the page started to load
    const now = window.performance.now()
    // Stager the elements over the same duration and let the first element
    //  start after the same duration since the page started to loaded
    const delay = (i * duration) + delta(duration, now)
    // Calculate start in advance
    const start = now + delay

    // Starting with zero opacity and slowly incrementing to one
    let opacity = 0
    // Inner loop to slowly increment opacity
    const inner = (timestamp) => {
      const progress = delta(timestamp, start)
      // Check if we are done or we need to request another frame
      if (progress < duration) {
        style.opacity = progress / duration
        window.requestAnimationFrame(inner)
      } else {
        style.opacity = 1
      }
    }

    // Start with basic styling
    style.display = 'block'
    style.opacity = opacity
    // Set the delay
    setTimeout(() => {
      window.requestAnimationFrame(inner)
    }, delay)
  }

  // Templating
  const template = (original, things, callback) => {
    things.forEach((thing, index) => {
      const clone = original.cloneNode(true)
      callback(clone, thing, index)
      append(original, clone)
    })
    remove(original)
  }

  // Renders a line of text
  const line = (element, content) => {
    text(element, content)
  }

  // Renders a list of lines
  const list = (element, content) => {
    text($(element, 'title'), content.title)

    // Renders the lines
    template($(element, 'line'), content.lines, line)
  }

  // Renders an item containing multiple lists
  const item = (element, content) => {

    if (content.location) {
      text($(element, 'title'), content.title)
      text($(element, 'link'), content.location)
    } else {
      remove($(element, 'title'))
      remove($(element, 'at'))
      text($(element, 'link'), content.title)
    }
    href($(element, 'link'), content.href)
    src($(element, 'img'), `images/${content.img}`)

    if (content.period) {
      text($(element, 'period'), content.period)
    }

    // Render the lists
    template($(element, 'list'), content.lists, list)
  }

  // Renders a section
  const section = (element, content, index) => {
    text($(element, 'title'), content.title)

    // Render the items
    template($(element, 'item'), content.items, item)

    // Fade in
    fadeIn(element, index)
  }

  // Renders the page
  const page = (element, content) => {
    // Renders the sections
    template($(element, 'section'), content, section)
  }

  // Get data with AJAX request
  const request = new window.XMLHttpRequest()
  request.open('GET', 'sections.json')
  request.send(null)
  request.onreadystatechange = () => {
    if (request.readyState === 4) {
      // Parse the response
      const response = JSON.parse(request.responseText)
      // Render the page
      page(document, response)
    }
  }
})(document, window)
