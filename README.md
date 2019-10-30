The issue in previous submission is related to cached source image that has no BSON library.
You need to clean up the cache and try the submission again. The source code is not changed in this submission, it just has this extra guide.

Please clean up before trying the submission as follows:

## Remove all containers
```
docker container rm $(docker container ls -a -q)
```
## Remove CACHED image

The source image was updated to include MongoDB and BSON library. You need to remove previous version from the cache before trying the submission.

```
docker image rm seriyvolk83/swift:4.2.1
```


