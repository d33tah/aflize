afl-sid
=======

Prepares a directory with Debian packages compiled in a form ready for
fuzzing with american fuzzy lop.


USAGE
=====

Run the following commands:

```
sudo docker build -t "d33tah/afl-sid" .
sudo docker run --name="afl-sid-container" d33tah/afl-sid | tee log.txt
sudo docker pull afl-sid-container:/root/pkgs .
sudo chown -R $USER pkgs
sudo docker rm afl-sid-container
```

After that, you will see a "pkgs" directory with the packages built.

By default, the base packages will be built. If you're only interested in
building specific packages, create a "packages.list" file with one package
list per line and no additional information and edit Dockerfile according
to the instructions added there.
