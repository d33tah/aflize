afl-sid
=======

afl-sid makes [fuzz testing](htts://en.wikipedia.org/wiki/fuzz_testing) easier
by automating the process of rebuilding software with a custom compiler. The
tool downloads all the required build dependencies and then instruments the
binary for [american fuzzy lop](http://lcamtuf.coredump.cx/afl/) support. This
is as easy as running two commands:

    docker run -ti d33tah/afl-sid bash
    aflize bison

In the example above, afl-sid would automatically download build dependencies
and the source code for [GNU Bison](https://gnu.org/software/bison/) program.
After that, it would compile it with `afl-gcc` with address sanitization
([ASAN](https://en.wikipedia.org/wiki/AddressSanitizer)) enabled. You will
even get a Debian package that you can use later to easily reproduce any bugs
you find during the fuzzing!

afl-sid requires [Docker](https://www.docker.com/) to be installed in order to
work. Once you have it, you will be able to experiment with your newly built
binary in isolation from your host operating system. afl-fuzz is already
installed, so you can jump from idea to fuzzing in just a few minutes. In the
video linked below you can see how simple it can become:

[![Video](https://i.imgur.com/DAtoRPt.png)](https://asciinema.org/a/26623)
