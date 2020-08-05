# xerox
Login, Pull, Tag, and Push into same registries at the same time with infinite number of accounts!

## How to use

Simple, but handy:

```bash
pullimage.sh -u foo -p *********** -l registry.gitlab.com -r registry.foo.com/foo/sourceimage:srctag -t registry.bar.cloud/bar/destimage:dsttag
```

* `-u` username
* `-p` password
* `-l` source registry login url.
* `-r` source image repository, name, and tag
* `-t` new tag value

and:

```
1. loging in...
        logged in successfully!

2. pulling image...
        pulled successfully!

3. tagging image...
        image tagged successfully!

3. pushing image...
        image pushed successfully!

5. loging out...
        logged out in successfully!
```


Running this script creates a folder under the working directory for each login, handle the jobs simultaneously, and remove the folder at the end.

### Exit codes

* `0` for exit successfully.
* `1` for unsuccessful login to registry with given credential.
* `2` failed on pulling image.
* `3` failed on tagging image.
* `4` push to the target registry failed.
* `5` failed on cleaning up the directory and local image caches.
