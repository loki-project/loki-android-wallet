# Building external libs in Docker

Builds Loki libs for all Android architectures from the [android](https://github.com/loki-project/loki/tree/android) branch.

Build image from `external-libs/docker` directory:

```Shell
docker build -t loki-android-image .
```

Create container to copy libs:
```Shell
docker create --name loki-android loki-android-image
```
 
Launch collecting script from `external-libs` directory:
```Shell
./collect.sh loki-android 
```
