afl-sid
=======

afl-sid (also referred to as "aflize") makes it easier to perform
[fuzz testing](htts://en.wikipedia.org/wiki/fuzz_testing) by automating the
process of rebuilding software with a custom compiler. The tool downloads all
the required build dependencies and then instruments the binary for
[american fuzzy lop](http://lcamtuf.coredump.cx/afl/) support. This is as easy
as running two commands:

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

[![Video](https://i.imgur.com/SJ9S66e.png)](https://asciinema.org/a/26623?autoplay=1)

Call for support
================

Probably the biggest problem with aflize right now is that hardly anyone knows
it. This is why if you're in touch with any open source developers, **tell them
about it**! I will really be grateful if you spread the word mailing lists, IRC
channels, forums and so on.

That doesn't mean that other forms of help aren't welcome. I'll be happy to hear
any feedback from you. If you know how to make this program better, [create a
Github issue](https://github.com/d33tah/afl-sid-repo/issues). Thanks in advance!

Notes
=====

Below are a couple of random notes that were collected from afl-sid users.
I have not tested all of them yet but you may nevertheless find them quite
helpful.

1. After having generated a package by `aflize`, you need to install it. You
   can run `dpkg -i ~/pkgs/*.deb` for that. If dpkg complains about missing
   dependencies, you can fetch them quickly by calling `apt-get -f install -y`.
2. Some software is represented by metapackages that point to specific versions
   of a program. For example, if you want to build Python", you should rather
   aflize python3.5 ("python3" might not be specific enough either).
3. If you're running out of disk space or plan to build a big package, keep
   in mind that by default Docker allocates 10 GiB per container. Read up on
   how to increase this value if you plan to build, say, libreoffice.
4. Some packages won't build and this can often be a bug that should be
   reported to the Debian package maintainers. If the "aflize" failed while
   performing post-build tests, you can still use the resulting binary. Look
   for it in /root/pkg directory. You can also apply patches at this stage and
   try just running "make". Sometimes it's that easy.
5. If you built a big package, consider submitting it to afl-sid-repo:
   https://github.com/d33tah/afl-sid-repo. If you're about to build a big
   package but don't feel like waiting for the process to complete, check this
   repository out.

Building
========

If you prefer to build the project manually, just call:

    docker build -t d33tah/afl-sid .

After that, you can use the `docker run` command as described above.

Bugs, problems, discussion
==========================

If you're looking for more information, take a look at the issue tracker here:

https://github.com/d33tah/afl-sid-repo/issues

Feel invited to create issues for anything related to your project that comes
to your mind.
