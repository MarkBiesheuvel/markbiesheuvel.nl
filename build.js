const fs = require('fs')
const sass = require('sass')
const ejs = require('ejs')
const htmlMinifier = require('html-minifier')
const posthtml = require('posthtml')
const minifyClassnames = require('posthtml-minify-classnames')
const { PurgeCSS } = require('purgecss')
const purgecss = new PurgeCSS()

const encoding = 'utf8'

// Directories
const source = 'src'
const destination = 'dist'

const extractFile = async (path) => {
  return new Promise((resolve, reject) => {
    fs.readFile(path, encoding, (error, result) => {
      if (error) {
        reject(error)
      } else {
        resolve(result)
      }
    })
  })
}

const writeFile = async (path, content) => {
  return new Promise((resolve, reject) => {
    fs.writeFile(path, content, (error) => {
      if (error) {
        reject(error)
      } else {
        resolve()
      }
    })
  })
}

const removeFiles = async (path) => {
  return new Promise((resolve, reject) => {
    fs.rm(path, { recursive: true, force: true }, (error) => {
      if (error) {
        reject(error)
      } else {
        resolve()
      }
    })
  })
}

const createDirectory = async (path) => {
  return new Promise((resolve, reject) => {
    fs.mkdir(path, { recursive: true }, (error) => {
      if (error) {
        reject(error)
      } else {
        resolve()
      }
    })
  })
}

const copyFile = async (sourcePath, destinationPath) => {
  return new Promise((resolve, reject) => {
    fs.copyFile(sourcePath, destinationPath, (error) => {
      if (error) {
        reject(error)
      } else {
        resolve()
      }
    })
  })
}

const compileSass = async (css) => {
  return new Promise((resolve, reject) => {
    // For options, see https://www.npmjs.com/package/node-sass
    sass.render({
      data: css,
      includePaths: ['node_modules/bootstrap/scss']
    }, (error, result) => {
      if (error) {
        reject(error)
      } else {
        resolve(result.css.toString())
      }
    })
  })
}

const removeUnusedCss = async (css, html) => {
  return new Promise((resolve, reject) => {
    // For options, see https://purgecss.com/api.html
    purgecss.purge({
      content: [
        { raw: html, extension: 'html' }
      ],
      css: [
        { raw: css }
      ]
    }).then(([result]) => {
      resolve(result.css)
    })
  })
}

const templateHtml = async (html, css) => {
  // For options, see https://github.com/mde/ejs
  return ejs.render(html, {
    css
  }, {
    openDelimiter: '{',
    closeDelimiter: '}',
    delimiter: '%',
    async: true
  })
}

const minifyHtml = async (html) => {
  return new Promise((resolve, reject) => {
    // For options, see https://github.com/kangax/html-minifier
    html = htmlMinifier.minify(html, {
      minifyCSS: true,
      collapseWhitespace: true,
      conservativeCollapse: false,
      removeComments: true,
      removeAttributeQuotes: true,
      removeEmptyAttributes: true,
      removeOptionalTags: true,
      removeRedundantAttributes: true,
      sortAttributes: true,
      sortClassName: true
    })

    // For option, see https://github.com/posthtml/posthtml-minify-classnames
    posthtml()
      .use(minifyClassnames({
        genNameClass: 'genName',
        genNameId: false
      }))
      .process(html)
      .then((result) => {
        resolve(result.html)
      })
  })
}

// Remove old build
const initTask = removeFiles(destination)
  .then(() => {
    // Recreate some directories
    // TODO: get directories dynamically
    return Promise.all([
      'favicon',
      'images'
    ].map(path => createDirectory(`${destination}/${path}`)))
  }).then(() => {

    // Compile SASS, remove unused CSS, include into HTML and minify
    const htmlTask = Promise.all([
      extractFile(`${source}/style.scss`),
      extractFile(`${source}/index.html`)
    ]).then(([css, html]) => {
      return compileSass(css)
        .then(css => removeUnusedCss(css, html))
        .then(css => templateHtml(html, css))
        .then(html => minifyHtml(html))
        .then(html => writeFile(`${destination}/index.html`, html))
        .then(() => {
          console.log('Created index.html')
        })
    })

    // Copy over files
    // TODO: get file names dynamically
    // TODO: minify SVG
    const copyTask = Promise.all([
      'favicon.ico',
      'robots.txt',
      'sitemap.xml',
      'images/aws_certified.svg',
      'images/aws.svg',
      'images/deskbookers.svg',
      'images/oblcc.svg',
      'images/optimizely.svg',
      'images/qforma.svg',
      'images/tue.svg',
      'favicon/android-chrome-192x192.png',
      'favicon/android-chrome-512x512.png',
      'favicon/apple-touch-icon.png',
      'favicon/favicon-16x16.png',
      'favicon/favicon-32x32.png',
      'favicon/site.webmanifest'
    ].map(file => {
      return copyFile(`${source}/${file}`, `${destination}/${file}`)
       .then(() => {
         console.log(`Copied ${file}`)
       })
    }))

    // Wait until everything is done
    Promise.all([htmlTask, copyTask])
      .then(() => {
        console.log('Done')
      })
})
