# Part 1 Docker file Creation, GitHub and Docker Hub Integration
## Step 1 Identify a Sample Application

Following code defines a simple FastAPI application with a single root endpoint that returns a greeting message `Hello from assignment1-part1!`.

We are going to dockerize it so it can run consistently in a containerized environment, making deployment and scaling easier.

```
import uvicorn
from fastapi import FastAPI

app = FastAPI()


@app.get("/")
def read_root():
    return "Hello from assignment1-part1!"

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8080)
```

## Step 2 Identify the Dependencies

For dockerizing this FastAPI app, the essential dependencies are quite minimal:

- **Python base image** (e.g., `python:3.10-slim`) → provides the runtime environment.
- **FastAPI** → the web framework used in your code.
- **Uvicorn** → the ASGI server that runs the FastAPI app.

## Step 3 Create a Docker file

```
FROM python:3.12-slim

# 1. Install uv by copying it from the official image
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# 2. Set the working directory
WORKDIR /app

# 3. Copy configuration files first (helps leverage Docker layer caching)
COPY pyproject.toml uv.lock ./

# 4. Explicitly tell uv to install the declared dependencies
RUN uv sync --frozen --no-cache

# 5. Copy the rest of your application code
COPY . /app

# 6. Run the FastAPI application using the installed environment
CMD ["uv", "run", "main.py", "--port", "8080", "--host", "0.0.0.0"]
```

Docker file is present in the same folder containing your code

```
ubuntu@ubuntu:~/assignments/assignment1-part1$ ls
Dockerfile  README.md  main.py  pyproject.toml  uv.lock
ubuntu@ubuntu:~/assignments/assignment1-part1$
```

## Step 4 Build the Docker Image

`docker build -t assign1_part1:1.0 .` command will create docker image with name *assign1_part1* having *tag 1.0*. This command tells Docker to:
- **Build an image** using the Dockerfile in the current directory (`.`)
- **Tag the image** with the name `assign1_part1` and version `1.0`.

```
ubuntu@ubuntu:~/assignments/assignment1-part1$ docker build -t assign1_part1:1.0 .
[+] Building 10.5s (13/13) FINISHED                                                                                                          docker:default
 => [internal] load build definition from Dockerfile                                                                                                   0.0s
 => => transferring dockerfile: 607B                                                                                                                   0.0s
 => [internal] load metadata for ghcr.io/astral-sh/uv:latest                                                                                           1.5s
 => [internal] load metadata for docker.io/library/python:3.12-slim                                                                                    1.9s
 => [internal] load .dockerignore                                                                                                                      0.0s
 => => transferring context: 2B                                                                                                                        0.0s
 => FROM ghcr.io/astral-sh/uv:latest@sha256:cdc6093146eb3ff6a40107b38f008b789e050e77ad87865e381d9917da55a168                                           0.1s
 => => resolve ghcr.io/astral-sh/uv:latest@sha256:cdc6093146eb3ff6a40107b38f008b789e050e77ad87865e381d9917da55a168                                     0.1s
 => [internal] load build context                                                                                                                      0.1s
 => => transferring context: 83.35kB                                                                                                                   0.1s
 => [stage-0 1/6] FROM docker.io/library/python:3.12-slim@sha256:a6e34c598f2467ed0e9a8d349809fcd8b5c603269512df273a0bb1784edc11b1                      0.1s
 => => resolve docker.io/library/python:3.12-slim@sha256:a6e34c598f2467ed0e9a8d349809fcd8b5c603269512df273a0bb1784edc11b1                              0.1s
 => CACHED [stage-0 2/6] COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/                                                                        0.0s
 => CACHED [stage-0 3/6] WORKDIR /app                                                                                                                  0.0s
 => CACHED [stage-0 4/6] COPY pyproject.toml uv.lock ./                                                                                                0.0s
 => CACHED [stage-0 5/6] RUN uv sync --frozen --no-cache                                                                                               0.0s
 => [stage-0 6/6] COPY . /app                                                                                                                          0.3s
 => exporting to image                                                                                                                                 8.1s
 => => exporting layers                                                                                                                                3.1s
 => => exporting manifest sha256:1770bc68f7f0ca3478d6e66e545784eb56c62136e6d248804af670c4a73b4ccf                                                      0.0s
 => => exporting config sha256:9b6fe96768447cbb681ca6d07f02bb9f307afb941fac3aff45ede36237bba997                                                        0.0s
 => => exporting attestation manifest sha256:10693e88f142358eb14cf5ac6801ef311ef57f970cfe422c87799b95ad6dfa3b                                          0.0s
 => => exporting manifest list sha256:b466f1bc7614737aba3d0a6e4202d369df9755a48d9417a1521c9cdb0ab44985                                                 0.0s
 => => naming to docker.io/library/assign1_part1:1.0                                                                                                   0.0s
 => => unpacking to docker.io/library/assign1_part1:1.0                                                                                                4.9s
ubuntu@ubuntu:~/assignments/assignment1-part1$
```

`docker images` command can be used to confirm the newly created docker image

```
ubuntu@ubuntu:~/assignments/assignment1-part1$ docker images
                                                                                                                                        i Info →   U  In Use
IMAGE                ID             DISK USAGE   CONTENT SIZE   EXTRA
assign1_part1:1.0    b466f1bc7614        585MB          142MB
first-app:1.0        b6a47e1a7409        328MB         80.5MB
hello-world:latest   5e2309035332       25.9kB         9.49kB
mysql:latest         9d48c42f8341        1.3GB          290MB
ubuntu@ubuntu:~/assignments/assignment1-part1$
```

Use `docker run -d -p 80:8080 assign1_part1:1.0` command to run a sample container for testing.

This command runs the container in detached mode, mapping host port 80 to container port 8080. It launches the `assign1_part1:1.0` image so your FastAPI app is accessible via `http://localhost:80`.

```
ubuntu@ubuntu:~/assignments/assignment1-part1$ docker run -d -p 80:8080 assign1_part1:1.0
1809e4033d87835015ee07f2ae2353773e4a50247aec08292a09a8b541b06539
```

Use `docker ps` command to check if container is running

```
ubuntu@ubuntu:~/assignments/assignment1-part1$ docker ps
CONTAINER ID   IMAGE               COMMAND                  CREATED         STATUS         PORTS                                     NAMES
1809e4033d87   assign1_part1:1.0   "uv run main.py --po…"   3 seconds ago   Up 2 seconds   0.0.0.0:80->8080/tcp, [::]:80->8080/tcp   serene_mcclintock
ubuntu@ubuntu:~/assignments/assignment1-part1$
```

Use `curl localhost` to see if you get the response as shown below

```
ubuntu@ubuntu:~/dice-live16-docker$ curl localhost
["Hello from assignment1-part1!"]
ubuntu@ubuntu:~/dice-live16-docker$
ubuntu@ubuntu:~/dice-live16-docker$
```

## Step 5 Push the Docker Image to Docker Hub

Login to *Docker Hub* using `docker login` command. After authentication, you should see **Login Succeeded** message as shown below

```
ubuntu@ubuntu:~/dice-live16-docker$
ubuntu@ubuntu:~/dice-live16-docker$ docker login
.
.
.
Login Succeeded
ubuntu@ubuntu:~/dice-live16-docker$
ubuntu@ubuntu:~/dice-live16-docker$
```

Tag your image using `docker tag` command. This command creates a new tag for your existing image. 

In my case `docker tag assign1_part1:1.0 highspeedali/dicebootcamp26:assign1` renames `assign1_part1:1.0` to `highspeedali/dicebootcamp26:assign1`, preparing it for push to Docker Hub under your repository.

```
ubuntu@ubuntu:~/assignments/assignment1-part1$ docker images
                                                                                                                                        i Info →   U  In Use
IMAGE                ID             DISK USAGE   CONTENT SIZE   EXTRA
assign1_part1:1.0    b466f1bc7614        585MB          142MB    U
first-app:1.0        b6a47e1a7409        328MB         80.5MB
hello-world:latest   5e2309035332       25.9kB         9.49kB
mysql:latest         9d48c42f8341        1.3GB          290MB
ubuntu@ubuntu:~/assignments/assignment1-part1$
ubuntu@ubuntu:~/assignments/assignment1-part1$
ubuntu@ubuntu:~/assignments/assignment1-part1$ docker tag assign1_part1:1.0 highspeedali/dicebootcamp26:assign1
ubuntu@ubuntu:~/assignments/assignment1-part1$
ubuntu@ubuntu:~/assignments/assignment1-part1$
```

Finally use `docker push` command with image tag to push it to docker hub

```
ubuntu@ubuntu:~/assignments/assignment1-part1$ docker push highspeedali/dicebootcamp26:assign1
The push refers to repository [docker.io/highspeedali/dicebootcamp26]
44136fa355b3: Pushed
75b6a36c64a1: Pushed
ecc510c1e359: Pushed
72b3023ef6e3: Pushed
6912e23eb445: Pushed
bbc5a1223747: Pushed
3f9b7c49588c: Pushed
4f33f1505b05: Pushed
2afde8c6dbc3: Pushed
fc222269c5cf: Pushed
8dae1be95700: Pushed
assign1: digest: sha256:b466f1bc7614737aba3d0a6e4202d369df9755a48d9417a1521c9cdb0ab44985 size: 856
ubuntu@ubuntu:~/assignments/assignment1-part1$
ubuntu@ubuntu:~/assignments/assignment1-part1$
```

To verify if we can pull image from docker hub, delete the same image using `docker image rm` command and then use `docker pull`command to download it from docker hub as shown below:

```
ubuntu@ubuntu:~/assignments/assignment1-part1$ docker images
                                                                                                                                        i Info →   U  In Use
IMAGE                                 ID             DISK USAGE   CONTENT SIZE   EXTRA
assign1_part1:1.0                     b466f1bc7614        585MB          142MB    U
first-app:1.0                         b6a47e1a7409        328MB         80.5MB
hello-world:latest                    5e2309035332       25.9kB         9.49kB
highspeedali/dicebootcamp26:assign1   b466f1bc7614        585MB          142MB    U
mysql:latest                          9d48c42f8341        1.3GB          290MB
ubuntu@ubuntu:~/assignments/assignment1-part1$
ubuntu@ubuntu:~/assignments/assignment1-part1$
ubuntu@ubuntu:~/assignments/assignment1-part1$ docker image rm highspeedali/dicebootcamp26:assign1
Untagged: highspeedali/dicebootcamp26:assign1
ubuntu@ubuntu:~/assignments/assignment1-part1$
ubuntu@ubuntu:~/assignments/assignment1-part1$
ubuntu@ubuntu:~/assignments/assignment1-part1$ docker pull highspeedali/dicebootcamp26:assign1
assign1: Pulling from highspeedali/dicebootcamp26
Digest: sha256:b466f1bc7614737aba3d0a6e4202d369df9755a48d9417a1521c9cdb0ab44985
Status: Downloaded newer image for highspeedali/dicebootcamp26:assign1
docker.io/highspeedali/dicebootcamp26:assign1
ubuntu@ubuntu:~/assignments/assignment1-part1$ docker images
                                                                                                                                        i Info →   U  In Use
IMAGE                                 ID             DISK USAGE   CONTENT SIZE   EXTRA
assign1_part1:1.0                     b466f1bc7614        585MB          142MB    U
first-app:1.0                         b6a47e1a7409        328MB         80.5MB
hello-world:latest                    5e2309035332       25.9kB         9.49kB
highspeedali/dicebootcamp26:assign1   b466f1bc7614        585MB          142MB    U
mysql:latest                          9d48c42f8341        1.3GB          290MB
ubuntu@ubuntu:~/assignments/assignment1-part1$
```
