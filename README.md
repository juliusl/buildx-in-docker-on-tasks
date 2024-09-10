# Using buildx in docker on tasks

## Scenario
In the current build of ACR Tasks, the `--attest` flag is not currently available and requires an updated version of buildx.

This example demonstrates how to use the latest version of `buildx` to build a registry image to take advantage of the latest
build options available.

## Part 1 - Create a new builder

The files `Dockerfile.builder` and `build_entrypoint.sh` show how to create a new buildkit builder and then use that builder to
run the image build. This is built as an "intermediate" build image within the provided example `tasks.yaml` file:

```yaml
- build: -t build-image:latest -f Dockerfile.builder .
```

The build entrypoint looks for two env variables, `$TAG` and `$DOCKERFILE`.

- `$TAG` - The tag you wish to use for the output image
- `$DOCKERFILE` - A path to the dockerfile that you wish to build

## Part 2 - Use the builder

The files `Dockerfile.helloworld` is an example image to build with the builder created in Part 1.

Example usage from the `tasks.yaml` file looks like this,

```yaml
- cmd: build-image
  env:
  - TAG={{.Run.Registry}}/hello-world:latest
  - DOCKERFILE=Dockerfile.helloworld
```

Since, we created the `build-image` in Part 1, we can simply invoke it w/ the `cmd` step provided by Tasks. The working directory
is automatically configured like a normal `build` step would be and so we can simply pass in `Dockerfile.helloworld` as the path, since
that is the path relative to the build context. The `TAG` env variable uses the `{{.Run.Registry}}` alias which means you can use the same
tagging you would in a normal tasks `build` step.

## How to run this example

To run this example you must have `az-cli` installed. Clone this repository, change directories, and run:

```sh
az acr run -f .\tasks.yaml . --registry <your-registry-name>
```

If successful you should see output along the lines of,

```log
Sending context (2.034 KiB) to registry: <your-registry>...
Queued a run with ID: ds2d
Waiting for an agent...
2024/09/10 00:49:44 Downloading source code...
2024/09/10 00:49:45 Finished downloading source code
2024/09/10 00:49:45 Alias support enabled for version >= 1.1.0, please see https://aka.ms/acr/tasks/task-aliases for more information.
2024/09/10 00:49:45 Creating Docker network: acb_default_network, driver: 'bridge'
2024/09/10 00:49:45 Successfully set up Docker network: acb_default_network
2024/09/10 00:49:45 Setting up Docker configuration...
2024/09/10 00:49:46 Successfully set up Docker configuration
2024/09/10 00:49:46 Logging in to registry: <your-registry>.azurecr.io
2024/09/10 00:49:46 Successfully logged into <your-registry>.azurecr.io
2024/09/10 00:49:46 Executing step ID: acb_step_0. Timeout(sec): 600, Working directory: '', Network: 'acb_default_network'
2024/09/10 00:49:46 Scanning for dependencies...
2024/09/10 00:49:47 Successfully scanned dependencies
2024/09/10 00:49:47 Launching container with name: acb_step_0
Sending build context to Docker daemon  9.216kB
Step 1/5 : FROM docker
 ---> 324eb822cb49
Step 2/5 : COPY --from=docker/buildx-bin /buildx /usr/libexec/docker/cli-plugins/docker-buildx
latest: Pulling from docker/buildx-bin
705e645f5fb1: Pulling fs layer
705e645f5fb1: Verifying Checksum
705e645f5fb1: Download complete
705e645f5fb1: Pull complete
Digest: sha256:8ebd56fb294661fd083dd4f130f56232f04413c3b70d88f6276bfe87f0ebb5e2
Status: Downloaded newer image for docker/buildx-bin:latest
 ---> d8cd6ef552e5
Step 3/5 : COPY build_entrypoint.sh build_entrypoint.sh
 ---> f4e193c69665
Step 4/5 : RUN chmod +x ./build_entrypoint.sh
 ---> Running in 55f307968899
Removing intermediate container 55f307968899
 ---> 54b7b40daeb1
Step 5/5 : ENTRYPOINT ["/build_entrypoint.sh"]
 ---> Running in ec300fc335c3
Removing intermediate container ec300fc335c3
 ---> d2d4af77d9fa
Successfully built d2d4af77d9fa
Successfully tagged build-image:latest
2024/09/10 00:49:54 Successfully executed container: acb_step_0
2024/09/10 00:49:54 Executing step ID: acb_step_1. Timeout(sec): 600, Working directory: '', Network: 'acb_default_network'
2024/09/10 00:49:54 Launching container with name: acb_step_1
#1 [internal] booting buildkit
#1 pulling image moby/buildkit:buildx-stable-1
#1 pulling image moby/buildkit:buildx-stable-1 5.5s done
#1 creating container buildx_buildkit_container0
#1 creating container buildx_buildkit_container0 0.4s done
#1 DONE 5.9s
container
#0 building with "container" instance using docker-container driver

#1 [internal] load build definition from Dockerfile.helloworld
#1 transferring dockerfile: 137B done
#1 DONE 0.0s

#2 resolve image config for docker-image://docker.io/docker/buildkit-syft-scanner:stable-1
#2 DONE 1.0s

#3 [internal] load metadata for mcr.microsoft.com/cbl-mariner/base/core:2.0
#3 DONE 0.3s

#4 [internal] load .dockerignore
#4 transferring context: 2B done
#4 DONE 0.0s

#5 [1/1] FROM mcr.microsoft.com/cbl-mariner/base/core:2.0@sha256:8d3b825888200e5c1e1ba058f4af7a6ba311b42d57016e6aa20e2ddfe7fd5e3e
#5 resolve mcr.microsoft.com/cbl-mariner/base/core:2.0@sha256:8d3b825888200e5c1e1ba058f4af7a6ba311b42d57016e6aa20e2ddfe7fd5e3e 0.0s done
#5 sha256:6c0706c7fd54fc41b413f8afc8fc0a16ef3533304662d8c76dde77550daa6ce5 4.47kB / 4.47kB 0.0s done
#5 sha256:b330ae2d2adaa388d4550a8eefd9c2ed0408e71fbe88d1024923c07e4d159534 2.10MB / 28.62MB 0.2s
#5 sha256:b330ae2d2adaa388d4550a8eefd9c2ed0408e71fbe88d1024923c07e4d159534 18.64MB / 28.62MB 0.3s
#5 sha256:b330ae2d2adaa388d4550a8eefd9c2ed0408e71fbe88d1024923c07e4d159534 28.62MB / 28.62MB 0.4s done
#5 extracting sha256:b330ae2d2adaa388d4550a8eefd9c2ed0408e71fbe88d1024923c07e4d159534
#5 ...

#6 docker-image://docker.io/docker/buildkit-syft-scanner:stable-1
#6 resolve docker.io/docker/buildkit-syft-scanner:stable-1 0.1s done
#6 sha256:8f55b7fda2c88820456a8687c5a0032f59bc1247451cfdbc968d773124f5da01 24.35MB / 24.35MB 0.5s done
#6 extracting sha256:8f55b7fda2c88820456a8687c5a0032f59bc1247451cfdbc968d773124f5da01 0.7s done
#6 DONE 1.3s

#5 [1/1] FROM mcr.microsoft.com/cbl-mariner/base/core:2.0@sha256:8d3b825888200e5c1e1ba058f4af7a6ba311b42d57016e6aa20e2ddfe7fd5e3e
#5 extracting sha256:b330ae2d2adaa388d4550a8eefd9c2ed0408e71fbe88d1024923c07e4d159534 1.1s done
#5 DONE 1.6s

#5 [1/1] FROM mcr.microsoft.com/cbl-mariner/base/core:2.0@sha256:8d3b825888200e5c1e1ba058f4af7a6ba311b42d57016e6aa20e2ddfe7fd5e3e
#5 extracting sha256:6c0706c7fd54fc41b413f8afc8fc0a16ef3533304662d8c76dde77550daa6ce5 done
#5 DONE 1.6s

#7 [linux/amd64] generating sbom using docker.io/docker/buildkit-syft-scanner:stable-1
#7 0.088 time="2024-09-10T00:50:03Z" level=info msg="starting syft scanner for buildkit v1.4.0"
#7 DONE 0.8s

#8 exporting to image
#8 exporting layers done
#8 exporting manifest sha256:0669e48baee1a732f0697ffffeb215f3f299667dfe13ee3dad9bdb50a3369c30 0.0s done
#8 exporting config sha256:f148cfc6aa67847822b98c8580bfe65a11453571d42e18568fe53f8edf9f3699 done
#8 exporting attestation manifest sha256:525df4f7425699b6e231f3fdf6ca46ba3fe07d57951f17073d1a5409e907a112
#8 ...

#9 [auth] hello-world:pull,push token for <your-registry>.azurecr.io
#9 DONE 0.0s

#8 exporting to image
#8 exporting attestation manifest sha256:525df4f7425699b6e231f3fdf6ca46ba3fe07d57951f17073d1a5409e907a112 0.0s done
#8 exporting manifest list sha256:227b2a3f5044e0c652418e1a789148ca10e4b6c4a2edb2f595e92fe26f59cf16 done
#8 pushing layers
#8 pushing layers 1.7s done
#8 pushing manifest for <your-registry>.azurecr.io/hello-world:latest@sha256:227b2a3f5044e0c652418e1a789148ca10e4b6c4a2edb2f595e92fe26f59cf16
#8 pushing manifest for <your-registry>.azurecr.io/hello-world:latest@sha256:227b2a3f5044e0c652418e1a789148ca10e4b6c4a2edb2f595e92fe26f59cf16 0.7s done
#8 DONE 3.0s
2024/09/10 00:50:07 Successfully executed container: acb_step_1
2024/09/10 00:50:07 Step ID: acb_step_0 marked as successful (elapsed time in seconds: 7.552186)
2024/09/10 00:50:07 Populating digests for step ID: acb_step_0...
2024/09/10 00:50:08 Successfully populated digests for step ID: acb_step_0
2024/09/10 00:50:08 Step ID: acb_step_1 marked as successful (elapsed time in seconds: 13.518033)
2024/09/10 00:50:08 The following dependencies were found:
2024/09/10 00:50:08
- image:
    registry: registry.hub.docker.com
    repository: library/build-image
    tag: latest
  runtime-dependency:
    registry: registry.hub.docker.com
    repository: library/docker
    tag: latest
  git: {}

Run ID: ds2d was successful after 25s
```