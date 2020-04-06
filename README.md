# FortifySSC-Docker [WIP!]
This project is intended to start from a Centos 7 image from the Docker registry
and produce an image with Fortify SSC installed and ready to be deployed to ECS EC2.
This container will NOT run on Fargate on AWS because it needs to mount host dirs.
## Installation
Clone this repo to a local directory with [SSH](git@git.aoc-pathfinder.cloud:jjimenez/fortifyssc-docker-wip.git) or [HTTPS](https://git.aoc-pathfinder.cloud/jjimenez/fortifyssc-docker-wip.git).
## Usage
### Dependencies
1. The Fortify SSC distribution zip file.
2. A Fortify SSC license file.
3. MySQL and a previously installed and configured database.
### Build
`docker build . -t fortifyssc-centos:latest` or use the provided `./build` script
### Run
`docker run --name ssc -it -d -p 80:8080 fortifyssc-centos:latest` or use the provided `./run` script
### Shell into the container
`docker exec -it ssc /bin/bash` or use the provided `./shell` script
### Clean everything in Docker
`./clean` (Use with care if you are working on other Docker related projects)
## Contributing
1. Fork it!
2. Do NOT push to master branch. Create your own feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request
## History
4/6/20 - Initial commit.
## Credits
### Original author
Juan Jimenez (flybd5@gmail.com)
### Contributors
TBD
## License
GPL-3.0-or-later
