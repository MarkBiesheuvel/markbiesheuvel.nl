const unzip = require('unzip')
const stream = require('stream')
const AWS = require('aws-sdk')
const s3 = new AWS.S3({
  signatureVersion: 'v4'
})
const cloudfront = new AWS.CloudFront()
const codepipeline = new AWS.CodePipeline()

exports.handler = (event, context, callback) => {
  const { destinationBucket } = process.env
  const { id, data } = event['CodePipeline.job']
  const [ inputArtifact ] = data.inputArtifacts
  const { bucketName, objectKey } = inputArtifact.location.s3Location

  s3.getObject({
    Bucket: bucketName,
    Key: objectKey
  }, (err, response) => {
    if (err) {
      callback(err)
    }

    const promises = []
    const readStream = new stream.PassThrough()

    readStream.end(response.Body)
    readStream.pipe(unzip.Parse())
    .on('entry', (entry) => {
      if (entry.type === 'File') {
        let contentType = 'binary/octet-stream'
        if (entry.path.match(/\.txt$/)) {
          contentType = 'text/plain'
        } else if (entry.path.match(/\.html$/)) {
          contentType = 'text/html'
        } else if (entry.path.match(/\.ico$/)) {
          contentType = 'image/x-icon'
        } else if (entry.path.match(/\.jpg$/)) {
          contentType = 'image/jpeg'
        }

        const promise = new Promise((resolve, reject) => {
          const chunks = []
          entry.on('data', (chunk) => {
            chunks.push(chunk)
          })
          entry.on('end', () => {
            s3.putObject({
              ACL: 'private',
              ContentType: contentType,
              Body: Buffer.concat(chunks),
              Bucket: destinationBucket,
              Key: entry.path
            }, (err, response) => {
              if (err) {
                reject(err)
              }
              resolve(response)
            })
          })
        })
        promises.push(promise)
      } else {
        entry.autodrain()
      }
    })
    .on('close', () => {
      Promise.all(promises).then(responses => {
        cloudfront.createInvalidation({
          DistributionId: 'E1SAIJBW9JIAHH',
          InvalidationBatch: {
            CallerReference: `${Date.now()}`,
            Paths: {
              Quantity: 1,
              Items: ['/*']
            }
          }
        }, (err, response) => {
          codepipeline.putJobSuccessResult({
            jobId: id
          }, callback)
        })
      }).catch(err => {
        callback(err)
      })
    })
  })
}
