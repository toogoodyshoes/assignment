## Description
DevOps assignment files.

## Steps

### Prerequisites
1. Nodejs and npm installed.

### Source Control
Step 1. Clone the repository 'https://github.com/MaheshRautrao/React-Todo-list' to local.
Step 2. Switch to 'React-Todo-list' directory and install required packages:
```sh
cd ~/React-Todo-list
npm install
```
Step 3. Build artifacts with following command:
```sh
npm run build
```
This will generate a 'build' folder with the production code for the app.

### Build Docker Image
Step 1. Use 'alpine:3.16' as base image. Install nodejs and npm on the docker image. The '--no-cache' flags ensures the package index is not stored locally, reducing the size of image. Install the 'serve' package required to run the todo-app.
```Dockerfile
FROM alpine:3.16

RUN <<EOF
apk update
apk add --no-cache nodejs npm
npm install -g serve
EOF
```

Step 2.  copy the 'build' folder generated in the [Source Control](#source-control) section to image. Use the 'serve' command to run the app. Make sure to use ENTRYPOINT instruction to run the container as executable. Expose the port on the container where the todo-app will be running.
```Dockerfile
FROM alpine:3.16

RUN <<EOF
apk update
apk add --no-cache nodejs npm
npm install -g serve
EOF

COPY .build build/

ENTRYPOINT serve -s build

EXPOSE 3000
```

Step 3. Run the following command to build image. Make sure the Dockerfile is present in the same directory.
```sh
docker build -t todo-app:v1 .
```

Step 4. Push the image to personal repository on Docker Hub. I am pushing it to my repository(toogoodyshoes). Make sure to login to docker via 'docker login' command.
```sh
# Login > Enter Credentials
docker login

# Tag and push image
docker tag todo-app:v1 toogoodyshoes/todo-app:v1
docker push toogoodyshoes/todo-app:v1
```

### Deploy on Kubernetes
Step 1. In the 'deployment.yaml' manifest, use the 'toogoodyshoes/todo-app:v1' image and specify the container port exposed in the Dockerfile while creating image.
```yaml
.
.
.
    spec:
      containers:
        - name: todo-container
          image: toogoodyshoes/todo-app:v1
          ports:
            - containerPort: 3000
```

Step 2. Create a NodePort service to expose the application outside cluster. Make sure to specify the selector same as in the 'deployment.yaml' file. Specify the same containerPort listed in 'deployment.yaml' against the field in 'targetPort' in the service manifest. Select a nodeport in the range of 30000-32767.
```yaml
apiVersion: v1
kind: Service
metadata:
  name: todo-app-node-port
spec:
  selector:
    app: todo-app
  type: NodePort
  ports:
  - port: 80
    targetPort: 3000
    nodePort: 30007
```

Step 3. Open a browser and navigate to 'http://localhost:30007' or 'http://127.0.0.1:30007'. You should see the todo-app served.