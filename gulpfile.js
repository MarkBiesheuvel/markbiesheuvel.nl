
const { src, dest, parallel, watch } = require('gulp')
const csso = require('gulp-csso')
const htmlmin = require('gulp-htmlmin')
const inline = require('gulp-inline')
const livereload = require('gulp-livereload')
const posthtml = require('gulp-posthtml')
const sass = require('gulp-sass')
const svgmin = require('gulp-svgmin')
const uncss = require('gulp-uncss')
const minifyClassnames = require('posthtml-minify-classnames')
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
  `${source}/*.*`,
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
    () => uncss({html: [htmlSource]}),
    () => csso({comments: false})
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
