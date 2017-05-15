((document, window) => {
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
    const duration = 600
    let start = null
    let opacity = 0

    const inner = (timestamp) => {
      if (start === null) {
        start = timestamp
      }
      const progress = timestamp - start

      if (progress < duration) {
        element.style.opacity = progress / duration
        window.requestAnimationFrame(inner)
      } else {
        element.style.opacity = 1
      }
    }

    element.style.display = 'block'
    element.style.opacity = opacity
    setTimeout(() => {
      window.requestAnimationFrame(inner)
    }, i * duration)
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
    text($(element, 'period'), content.period)

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

  // Lazy load images
  window.addEventListener('load', () => {
    const image = $(document, 'img')
    image.src = image.dataset.src
  })

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
