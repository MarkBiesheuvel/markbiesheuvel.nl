((document) => {
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

  // Templating
  const template = (original, things, callback) => {
    things.forEach((thing) => {
      const clone = original.cloneNode(true)
      callback(clone, thing)
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
  const section = (element, content) => {
    element.style.display = 'block'
    text($(element, 'title'), content.title)

    // Render the items
    template($(element, 'item'), content.items, item)
  }

  // Renders the page
  const page = (element, content) => {
    // Renders the sections
    template($(element, 'section'), content, section)
  }

  // Lazy load images
  window.addEventListener('load', () => {
    const images = $(document, 'img')
    images.forEach((image) => {
      image.src = image.dataset.src
    })
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
})(document)
