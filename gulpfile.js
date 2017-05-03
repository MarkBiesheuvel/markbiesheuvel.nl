
const gulp = require('gulp')
const csso = require('gulp-csso')
const htmlmin = require('gulp-htmlmin')
const resize = require('gulp-image-resize')
const inline = require('gulp-inline')
const less = require('gulp-less')
const uncss = require('gulp-uncss')
const uglify = require('gulp-uglify')
const pump = require('pump')

// Directories
const source = 'src'
const destination = 'dist'

// Globs
const imgSource = `${source}/*.jpg`
const htmlSource = `${source}/*.html`
const jsSource = `${source}/*.js`
const cssSource = `${source}/*.less`
const othersSource = [`${source}/*.*`, `!${htmlSource}`, `!${jsSource}`, `!${cssSource}`]

const copy = () => {
  // Task
  return (callback) => {
    pump([
      gulp.src(othersSource),
      gulp.dest(destination)
    ], callback)
  }
}

const html = (includeUncss = true) => {
  // Settings
  const collapseWhitespace = true
  const base = source
  const js = [
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
      gulp.dest(destination)
    ], callback)
  }
}

const watch = () => {
  // Task
  return () => {
    gulp.watch(othersSource, ['copy'])
    gulp.watch([htmlSource, jsSource, cssSource, imgSource], ['html.fast'])
  }
}

gulp.task('copy', copy())
gulp.task('html.slow', html(true))
gulp.task('html.fast', html(false))
gulp.task('watch', watch())
gulp.task('build', [ 'copy', 'html.slow' ])
