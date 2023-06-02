# SDRplay Linux API 3.07

This repository contains the same SDRplay Linux drivers/API available on the [SDRplay website](https://www.sdrplay.com/downloads/). The packaged script from the website (`SDRplay_RSP_API-Linux-3.07.1.run`) has several features that make it undesirable for installing and running inside a Docker container with a minimal Linux system and no user interaction. The original installer was run with the `--keep` flag to obtain the files in this repository, and only the `install_lib.sh` script was altered to produce `install_lib_DOCKER.sh` with the following changes:

* remove the requirement to interactively view the license agreement with `more`
* remove the installation confirmation prompt
* remove the local USB ID database confirmation prompt
* prevent installation of the SDRplay API service through `init.d` or `systemd`

## Installation in a Docker Container

During the Docker `build` process:

```Docker
RUN git clone https://github.com/ziflabs/sdrplay-api-linux-docker
RUN cd sdrplay-api-linux-docker && ./install_lib_DOCKER.sh
```

Because we do not install the SDRplay `systemd` service when building the image (as it's generally not recommended to have `systemd` in Docker containers), the SDRplay API service must be manually started after launching the container. If something like [SoapySDR](https://github.com/pothosware/SoapySDR/wiki) is installed as well, you can scan for an attached SDR to check that the API service is functioning:

```
dev@34c615cd3324:~/foss$ ./sdrplay-api-linux-docker/x86_64/sdrplay_apiService &
[1] 12
dev@34c615cd3324:~/foss$ SoapySDRUtil --find="driver=sdrplay"
######################################################
##     Soapy SDR -- the SDR abstraction library     ##
######################################################

Found device 0
  driver = sdrplay
  label = SDRplay Dev0 RSPduo 22340C4734 - Single Tuner
  mode = ST
  serial = 22340C4734

[...]
```

## Installation on a Host Machine

```bash
$ ./install_libs.sh
```
