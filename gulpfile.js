
// Gulp dependencies
const { src, dest, parallel, watch } = require('gulp')
const htmlmin = require('gulp-htmlmin')
const inline = require('gulp-inline')
const livereload = require('gulp-livereload')
const postcss = require('gulp-postcss')
const posthtml = require('gulp-posthtml')
const sass = require('gulp-sass')(require('sass'))
const svgmin = require('gulp-svgmin')

// postcss and posthtml dependencies
const cssnano = require('cssnano')
const minifyClassnames = require('posthtml-minify-classnames')
const uncss = require('postcss-uncss')

// other dependencies
const pump = require('pump')

// Directories
const source = 'src'
const destination = 'dist'
const imagesDestination = `${destination}/images`

// Globs
const cssSource = `${source}/*.scss`
const htmlSource = `${source}/*.html`
const svgSource = `${source}/images/*.svg`
const othersSource = [
  `${source}/**/*`,
  `!${cssSource}`,
  `!${htmlSource}`,
  `!${svgSource}`
]

const copyTask = (callback) => {
  return pump([
    src(othersSource),
    dest(destination),
    livereload()
  ], callback)
}

const htmlTask = (callback) => {
  const css = [
    () => sass({includePaths: ['node_modules/bootstrap/scss']}),
    () => postcss([
      uncss({html: [htmlSource]}),
      cssnano()
    ]),
  ]
  const disabledTypes = ['img', 'svg']

  pump([
    src(htmlSource),
    inline({
      base: source,
      css,
      disabledTypes
    }),
    htmlmin({
      collapseWhitespace: true,
      conservativeCollapse: false,
      removeComments: true,
      removeAttributeQuotes: true,
      removeEmptyAttributes: true,
      removeOptionalTags: true,
      removeRedundantAttributes: true,
      sortAttributes: true,
      sortClassName: true
    }),
    posthtml([
      minifyClassnames()
    ]),
    dest(destination),
    livereload()
  ], callback)
}

const svgTask = (callback) => {
  pump([
    src(svgSource),
    svgmin({}),
    dest(imagesDestination),
    livereload()
  ], callback)
}

const watchTask = (callback) => {
  livereload.listen()
  watch(othersSource, copyTask)
  watch(svgSource, svgTask)
  watch([htmlSource, cssSource], htmlTask)
  callback()
}

const buildTask = parallel(copyTask, htmlTask, svgTask)

// Everything together
exports.watch = watchTask
exports.build = buildTask
