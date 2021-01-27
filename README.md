# document-server
## Summary
This project is a simple dockerized Nginx web server that serves the Documents folder of the Pi user as a web page. This is useful for projects where files need to be shared in a manner that's easy to access from other devices. The primary purpose of this is to serve documentation, manuals, forms, etc. for off grid ham radio servers.

## Running the project
Once [Docker](https://docs.docker.com/engine/install/debian/) and [Docker Compose](https://dev.to/rohansawant/installing-docker-and-docker-compose-on-the-raspberry-pi-in-5-simple-steps-3mgl) are installed simply run `docker-compose up -d --build` in the project folder.


## Security warning
This server is HTTP only. It does not provide any transport level security of documents by design. This project should only be used to serve non-sensitive documents on trusted networks.