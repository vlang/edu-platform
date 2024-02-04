# Educational Materials for V

This repo will house lessons and other materials to help learn and use the
[V](https://vlang.io) Programming Language.

## Usage

Besides simply reading or viewing the available materials, this repo also
includes a small web server written in V in the `main.v` file at the root
of the project.

You can use this server to view the files in your browser if you have the
V language installed locally, by running this command:
```sh
v run main.v
```
When the server is intialized, it will print the URL to open in your browser to look through
these materials.

## Usage with Docker

For convenience, there is also a [Dockerfile](Dockerfile) in this repository.
Here is how to use it, to build yourself a local image, with a
precompiled application, using latest V:
```sh
docker build -t edu_platform_app .
```

After you have build the local image, you can start a container with it:
```sh
docker run -p 127.0.0.1:8082:8082 edu_platform_app:latest
```

Note, that the executable /app/edu-platform inside that image, is
compiled statically on Alpine, and so can run unchanged even on very old
host distributions.
