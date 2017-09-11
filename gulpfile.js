
const gulp = require('gulp')
const babel = require('gulp-babel')
const csso = require('gulp-csso')
const htmlmin = require('gulp-htmlmin')
const resize = require('gulp-image-resize')
const inline = require('gulp-inline')
const jsonminify = require('gulp-jsonminify')
const livereload = require('gulp-livereload')
const rename = require('gulp-rename')
const sass = require('gulp-sass')
const uglify = require('gulp-uglify')
const uncss = require('gulp-uncss')
const pump = require('pump')

// Directories
const source = 'src'
const destination = 'dist'

// Globs
const cssSource = `${source}/*.scss`
const htmlSource = `${source}/*.html`
const imgSource = `${source}/*.jpg`
const jsonSource = `${source}/*.json`
const jsSource = `${source}/*.js`
const othersSource = [
  `${source}/*.*`,
  `!${cssSource}`,
  `!${imgSource}`,
  `!${htmlSource}`,
  `!${jsonSource}`,
  `!${jsSource}`
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

const img = ({width, height, suffix = ''}) => {
  // Task
  return (callback) => {
    pump([
      gulp.src(imgSource),
      resize({width, height, quality: 1, format: 'jpg'}),
      rename({suffix}),
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

const html = ({includeUncss, width, height}) => {
  // Settings
  const js = [
    () => babel({ presets: ['es2015'] }),
    () => uglify()
  ]
  const img = [
    () => resize({width, height, quality: 0, format: 'gif'})
  ]
  const css = [
    () => sass({includePaths: ['node_modules/bootstrap/scss']}),
    () => csso({comments: false})
  ]

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
      inline({base: source, css, img, js}),
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

const watch = () => {
  // Task
  return () => {
    livereload.listen()
    gulp.watch(othersSource, ['copy'])
    gulp.watch(jsonSource, ['json'])
    gulp.watch(imgSource, ['img'])
    gulp.watch([htmlSource, jsSource, cssSource, imgSource], ['html.fast'])
  }
}

const imageSize = 262
const retinaImageSize = imageSize * 2
const thumbnailImageSize = Math.ceil(imageSize / 4)
gulp.task('copy', copy())
gulp.task('json', json())
gulp.task('img.normal', img({width: imageSize, height: imageSize}))
gulp.task('img.retina', img({width: retinaImageSize, height: retinaImageSize, suffix: '-2x'}))
gulp.task('img', ['img.normal', 'img.retina'])
gulp.task('html.slow', html({includeUncss: true, width: thumbnailImageSize, height: thumbnailImageSize}))
gulp.task('html.fast', html({includeUncss: false, width: thumbnailImageSize, height: thumbnailImageSize}))
gulp.task('watch', watch())
gulp.task('build', ['copy', 'img', 'json', 'html.slow'])
