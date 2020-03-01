# pmflib-build
Utilities for testing and building of the [PMFLib](https://github.com/kulhanek/pmflib) package.

## Building and Installation

### Testing Mode
```bash
$ git clone --recursive https://github.com/kulhanek/pmflib-build.git
$ cd pmflib-build
$ ./build-utils/00.init-links.sh
$ ./01.pull-code.sh
$ ./04.build-inline.sh   # build the code inline in src/
```

### Production Build into the Infinity software repository
```bash
$ git clone --recursive https://github.com/kulhanek/pmflib-build.git
$ cd pmflib-build
$ ./build-utils/00.init-links.sh
$ ./01.pull-code.sh
$ ./10.build-final.sh  # standard build
```

### Production Build into Custom Directory
```bash
$ git clone --recursive https://github.com/kulhanek/pmflib-build.git
$ cd pmflib-build
$ ./build-utils/00.init-links.sh
$ ./01.pull-code.sh
$ cmake -DCMAKE_INSTALL_PREFIX=/path/to/pmflib/installation/directory
$ make
$ make install
```

