# document-server
## Summary
This project is a simple dockerized Nginx web server that serves the Documents folder of the Pi user as a web page. This is useful for projects where files need to be shared in a manner that's easy to access from other devices. The primary purpose of this is to serve documentation, manuals, forms, etc. for off grid ham radio servers.

## Running the project
Install and configure [Docker](https://docs.docker.com/engine/install/debian/) and [Docker Compose](https://dev.to/rohansawant/installing-docker-and-docker-compose-on-the-raspberry-pi-in-5-simple-steps-3mgl).
Clone the project in the `pi` user's folder:
```
cd /home/pi
git clone https://github.com/ThreeSixes/document-server.git
```

Once the project's repository has been cloned run `docker-compose up -d --build` in the project folder.
The document server will now serve the entire contents of the `pi` user's Documents folder. It can be accessed using a web browser and the Pi's hostname or IP address. If the pi's hostname is `winlink` you'd use http://winlink to get a list of documents.


## Security warning
This server is HTTP only. It does not provide any transport level security of documents by design. This project should only be used to serve non-sensitive documents on trusted networks.
