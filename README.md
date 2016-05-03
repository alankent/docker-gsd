Getting Stuff Done with Magento 2 Book Series Docker File
=========================================================

This is the Dockerfile behind the alankent/gsd Docker image.
This images has the Magento Luma demo store preloaded, and so
is a convenient way to try out Magento 2.

If `SAMBA_START=1` is set as an environment variable when the
container is started, a Samba server is launched to give remote
access to the files in the container.

The following is a convenient `docker-composer.yml` file for
use with this image that specifies all the port numbers to open
up by default. Note this mounts your ~/.composer directory inside
the container, so it can access your ~/.composer/auth.json file
for credentials to the Magento composer repository.

    gsd:
      image: alankent/gsd
      ports:
        - "80:80"
        - "3000:3000"
        - "3001:3001"
        - "135:135"
        - "139:139"
        - "445:445"
        - "2222:22"
      environment:
        - SAMBA_START=1
      volumes:
        - ~/.composer:/home/magento/.composer

This can be done by command line switches instead.

    docker run -d -i -t -p 80:80 -p 3000:3000 -p 3001:3001 -p 2222:22 -p 445:445 -p 139:139 -p 135:135 -e SAMBA_START=1 --name gsd alankent/gsd

See http://alankent.me/gsd for more details.

To build use the following command (with your Magento composer repository
keys inserted as appropriate).

    docker build \
        --build-arg MAGENTO_REPO_USERNAME=57db7777777777777777777771be707b \
        --build-arg MAGENTO_REPO_PASSWORD=9d74777777777777777777777a09ecad \
        -t gsd .
    docker tag -f gsd alankent/gsd:0.4
    docker tag -f gsd alankent/gsd:latest
    docker push alankent/gsd:0.4
    docker push alankent/gsd:latest
