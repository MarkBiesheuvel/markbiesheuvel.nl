((document) => {
  // Get an element by its role
  const $ = (parent, role) => parent.querySelector(`[role=${role}]`)

  // Apply settings to an element
  const apply = (element, settings = {}) => {
    for (let property in settings) {
      element[property] = settings[property]
    }
  }

  // Removes an element from the DOM
  const remove = (element) => {
    element.parentElement.removeChild(element)
  }

  // Append after
  const append = (existing, element) => {
    existing.parentElement.appendChild(element)
  }

  // Lazy load images
  window.addEventListener('load', () => {
    const images = document.querySelectorAll('img')
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
      const sections = JSON.parse(request.responseText)

      // Template stuff
      // TODO: develop function for common pattern of seleting an (template) element, looping over something, cloning it, appending it and finally removing it
      const $section = $(document, 'section')
      sections.forEach((section) => {
        const $clone = $section.cloneNode(true)
        $clone.style.display = 'block'
        apply($($clone, 'title'), {
          textContent: section.title
        })

        const $item = $($clone, 'item')
        section.items.forEach((item) => {
          const $clone2 = $item.cloneNode(true)
          apply($($clone2, 'period'), {
            textContent: item.period
          })
          if (item.location) {
            apply($($clone2, 'link'), {
              textContent: item.location,
              href: item.href
            })
            apply($($clone2, 'title'), {
              textContent: item.title
            })
          } else {
            apply($($clone2, 'link'), {
              textContent: item.title,
              href: item.href
            })
            remove($($clone2, 'title'))
            remove($($clone2, 'at'))
          }
          append($item, $clone2)

          const $list = $($clone2, 'list')
          item.lists.forEach((list) => {
            const $clone3 = $list.cloneNode(true)
            apply($($clone3, 'title'), {
              textContent: list.title
            })
            const $line = $($clone3, 'line')
            list.lines.forEach((line) => {
              const $clone4 = $line.cloneNode(true)
              console.log(line)
              apply($clone4, {
                textContent: line
              })
              append($line, $clone4)
            })
            remove($line)
            append($list, $clone3)
          })
          remove($list)
        })
        remove($item)

        append($section, document.createElement('hr'))
        append($section, $clone)
      })
      remove($section)
    }
  }
})(document)
