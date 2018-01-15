
const gulp = require('gulp')
const babel = require('gulp-babel')
const csso = require('gulp-csso')
const htmlmin = require('gulp-htmlmin')
const inline = require('gulp-inline')
const jsonminify = require('gulp-jsonminify')
const livereload = require('gulp-livereload')
const sass = require('gulp-sass')
const svgmin = require('gulp-svgmin')
const uglify = require('gulp-uglify')
const uncss = require('gulp-uncss')
const pump = require('pump')

// Directories
const source = 'src'
const destination = 'dist'
const imagesDestination = `${destination}/images`

// Globs
const cssSource = `${source}/*.scss`
const htmlSource = `${source}/*.html`
const jsonSource = `${source}/*.json`
const jsSource = `${source}/*.js`
const svgSource = `${source}/images/*.svg`
const othersSource = [
  `${source}/*.*`,
  `!${cssSource}`,
  `!${htmlSource}`,
  `!${jsonSource}`,
  `!${jsSource}`,
  `!${svgSource}`,
]

const copy = () => {
  // Task
  return (callback) => {
    pump([
      gulp.src(othersSource),
      gulp.dest(destination),
      livereload()
    ], callback)
  }
}

const json = () => {
  // Task
  return (callback) => {
    pump([
      gulp.src(jsonSource),
      jsonminify(),
      gulp.dest(destination),
      livereload()
    ], callback)
  }
}

const html = ({includeUncss}) => {
  // Settings
  const js = [
    () => babel({ presets: ['es2015'] }),
    () => uglify()
  ]
  const css = [
    () => sass({includePaths: ['node_modules/bootstrap/scss']}),
    () => csso({comments: false})
  ]
  const disabledTypes = ['img', 'svg']

  // Add uncss to the list
  if (includeUncss) {
    css.push(
      () => uncss({html: [htmlSource]}),
      css.pop()
    )
  }

  // Task
  return (callback) => {
    pump([
      gulp.src(htmlSource),
      inline({
        base: source,
        css,
        js,
        disabledTypes
      }),
      htmlmin({
        collapseWhitespace: true,
        removeAttributeQuotes: true,
        removeOptionalTags: true,
        removeRedundantAttributes: true,
        sortAttributes: true,
        sortClassName: true
      }),
      gulp.dest(destination),
      livereload()
    ], callback)
  }
}

const svg = () => {
  // Task
  return (callback) => {
    pump([
      gulp.src(svgSource),
      svgmin({}),
      gulp.dest(imagesDestination),
      livereload()
    ], callback)
  }
}

const watch = () => {
  // Task
  return () => {
    livereload.listen()
    gulp.watch(othersSource, ['copy'])
    gulp.watch(jsonSource, ['json'])
    gulp.watch(svgSource, ['svg'])
    gulp.watch([htmlSource, jsSource, cssSource], ['html.fast'])
  }
}

const imageSize = 262
const retinaImageSize = imageSize * 2
const thumbnailImageSize = Math.ceil(imageSize / 4)
gulp.task('copy', copy())
gulp.task('json', json())
gulp.task('html.slow', html({includeUncss: true}))
gulp.task('html.fast', html({includeUncss: false}))
gulp.task('svg', svg())
gulp.task('watch', watch())

// Everything together
gulp.task('build', ['copy', 'json', 'html.slow', 'svg'])
