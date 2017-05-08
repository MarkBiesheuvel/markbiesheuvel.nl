
const gulp = require('gulp')
const babel = require('gulp-babel')
const csso = require('gulp-csso')
const htmlmin = require('gulp-htmlmin')
const resize = require('gulp-image-resize')
const inline = require('gulp-inline')
const jsonminify = require('gulp-jsonminify')
const less = require('gulp-less')
const livereload = require('gulp-livereload')
const uncss = require('gulp-uncss')
const uglify = require('gulp-uglify')
const pump = require('pump')

// Directories
const source = 'src'
const destination = 'dist'

// Globs
const cssSource = `${source}/*.less`
const htmlSource = `${source}/*.html`
const imgSource = `${source}/*.jpg`
const jsonSource = `${source}/*.json`
const jsSource = `${source}/*.js`
const othersSource = [
  `${source}/*.*`,
  `!${cssSource}`,
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

const html = (includeUncss = true) => {
  // Settings
  const collapseWhitespace = true
  const base = source
  const js = [
    () => babel({ presets: ['es2015'] }),
    () => uglify()
  ]
  const img = [
    () => resize({ width: 64, height: 64, quality: 0, format: 'gif' })
  ]
  const css = [
    () => less({ paths: 'node_modules/bootstrap/less' }),
    () => csso()
  ]

  // Add uncss to the list
  if (includeUncss) {
    css.push(
      () => uncss({ html: [htmlSource] }),
      css.pop()
    )
  }

  // Task
  return (callback) => {
    pump([
      gulp.src(htmlSource),
      inline({ base, js, css, img }),
      htmlmin({ collapseWhitespace }),
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
    gulp.watch([htmlSource, jsSource, cssSource, imgSource], ['html.fast'])
  }
}

gulp.task('copy', copy())
gulp.task('json', json())
gulp.task('html.slow', html(true))
gulp.task('html.fast', html(false))
gulp.task('watch', watch())
gulp.task('build', [ 'copy', 'json', 'html.slow' ])
