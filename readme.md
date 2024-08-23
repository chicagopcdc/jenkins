![gsoc](https://user-images.githubusercontent.com/129569933/267078707-df0e5058-eec5-4740-996b-085f56ae0f5a.png)

![D4CG](https://commons.cri.uchicago.edu/wp-content/uploads/2023/01/Color-D4CG-Standard-Logo-copy-680x154.png)



**GSoC Author**: Wenbo Qian

**Email:** qian.wen@northeastern.edu

**Github profile**: https://github.com/wfckl789

**LinkedIn**: https://www.linkedin.com/in/wenbo-qian/

**Mentor:** Nicholas Ferraz

## Project Goal

✅ An operational Jenkins pipeline that can

- ​	✅ Connects to D4CG cloud service cluster(portal-dev)

- ​	✅ Automate running unit tests for required services, including

  - fence	

  - arborist

  - peregrine

  - sheepdog

  - pcdcanalysistools

  - amanuensis

  - guppy

  - data-portal

  - pelican


D4CG Unit tests notes: https://docs.google.com/document/d/1jzE2blGkrQ1Rj2rkOfBZ7Pk2jNqaiY1SuOittlbHT94/edit

- ​	✅ Enable Jenkins to update service pod with a specified version

- ​	✅ Support github CI/CD pipeline in Jenkins

- ​	✅ Implement a out-of-box webhook for outer platform to trigger building Jenkins pipeline

- ​	✅ Provide email notification including 

  - Unit test running output, such as test cases coverage 

  - Visualization of Jenkins pipeline

    ![img](https://lh7-rt.googleusercontent.com/docsz/AD_4nXcUsd1w1vZ2MGTCh3hkTX1RLz-zHn4l8EGpw1r44Ex0YZTsU6lQgrSHnZmOkHsq2MAxCUxXFmlaTkoWh2pzjyolaIX6EDCcdINU9KEF1EZUKdLVO4CH_eTiWghkGhHCD3GxK8pOZ9eAYSqJz9iQ6E_KAnVy?key=xwJYBXB4pC_YGnDwfJIXkw)


## Architecture

###### <img src="/Users/qwb/Library/Application Support/typora-user-images/image-20240822183244612.png" alt="image-20240822183244612" style="zoom: 67%;" />

## Workflow

<img src="/Users/qwb/Library/Application Support/typora-user-images/image-20240822185944559.png" alt="image-20240822185944559" style="zoom: 67%;" />

## How to stand it up / run

### Build Jenkins from zero

#### 1. Add inbound rules in server for Jenkins master node

- ##### Inbound Rules:

  - 8080 TCP 0.0.0.0/0 Jenkins port
  - 3306 TCP 0.0.0.0/0 Mysql port
  - 3389 TCP 0.0.0.0/0 Jenkins GUI port
  - 80 TCP 0.0.0.0/0 For Jenkins install its plugin
  - 465 TCP 0.0.0.0/0 Jenkins email notification port
  - 22 TCP 0.0.0.0/0 ssh connection
  - All ICMP 0.0.0.0/0 For Jenkins master node to connect with slave node
  - 5900 TCP 0.0.0.0/0 vnc port

- ##### Outbound Rules:

  - All All 0.0.0.0/0

#### 2. Setting up Jenkins using Docker

```shell
# Build the Jenkins BlueOcean Docker Image
	# Use Dockerfile in this git repo
docker build -t myjenkins-blueocean:2.414.2 .

# Create the network 'jenkins'
docker network create jenkins

# Run the Container
	# MacOS / Linux
docker run --name jenkins-blueocean --restart=on-failure --detach \
  --network jenkins --env DOCKER_HOST=tcp://docker:2376 \
  --env DOCKER_CERT_PATH=/certs/client --env DOCKER_TLS_VERIFY=1 \
  --publish 8080:8080 --publish 50000:50000 \
  --volume jenkins-data:/var/jenkins_home \
  --volume jenkins-docker-certs:/certs/client:ro \
  myjenkins-blueocean:2.414.2

# Enter into Jenkins Web UI
Open a browser and visit hostname:8080
```

#### 3. Install necessary Jenkins plugins

- [Blue Ocean Pipeline EditorVersion1.27.11](https://plugins.jenkins.io/blueocean-pipeline-editor)
- [Blue Ocean](https://plugins.jenkins.io/blueocean)
- [Docker pluginVersion1.5](https://plugins.jenkins.io/docker-plugin)
- [Email Extension PluginVersion2.105](https://plugins.jenkins.io/email-ext)
- [GitHub pluginVersion1.37.3.1](https://plugins.jenkins.io/github)
- [Kubernetes pluginVersion4054.v2da_8e2794884](https://plugins.jenkins.io/kubernetes)
- [Kubernetes Credentials PluginVersion174.va_36e093562d9](https://plugins.jenkins.io/kubernetes-credentials)
- [Kubernetes Client API PluginVersion6.10.0-240.v57880ce8b_0b_2](https://plugins.jenkins.io/kubernetes-client-api)
- [Pipeline Graph View PluginVersion205.vb_8e3a_b_51f12e](https://plugins.jenkins.io/pipeline-graph-view)
- [Pipeline SCM API for Blue OceanVersion1.27.11](https://plugins.jenkins.io/blueocean-pipeline-scm-api)
- [Authentication Tokens API PluginVersion1.119.v50285141b_7e1](https://plugins.jenkins.io/authentication-tokens)

#### 4. Setting up a Jenkins Slave node

Use portal-dev([ubuntu@ec2-52-21-235-1.compute-1.amazonaws.com](mailto:ubuntu@ec2-52-21-235-1.compute-1.amazonaws.com)) server as the slave node for example

```shell
Click Dashboard -> Manage Jenkins -> Nodes -> New Node
Node configurations list below:
Node Name: up to you
Type: Permanent Agent
Remote root directory: /home/ubuntu/jenkins
Labels: D4CG-agent-dev (this label will be used in Jenkinsfile to define pipeline)
Usage: Only build jobs with label expressions matching this node
Launch method: Launch agents via SSH
	Host: aws hostname
	Credentials: use the PRIVATE KEY(id_rsa), not the PUBLIC KEY!
	Host Key Verification Strategy: Non verifying Verification Strategy
Availability: Keep this agent online as much as possible
```

Wait for a minute, and the node is successfully connected if you see info below in **Log**.

<img src="/Users/qwb/Library/Application Support/typora-user-images/image-20240822192653412.png" alt="image-20240822192653412" style="zoom:50%;" />

**Important** **Note:** To enable Jenkins use `kubectl ` command in the portal-dev, make sure kubeconfig file exists in path `~/.kube/config`.

------

### How to run a Jenkin pipeline

- #### Manually trigger

​	Click **Dashboard** -> **pipelinename** -> **Build Now**

<img src="/Users/qwb/Library/Application Support/typora-user-images/image-20240822194717875.png" alt="image-20240822194717875" style="zoom:50%;" />

- #### Trigger by webhook

​	 Send POST request like: `http://jenkins_user_name:secret_pwd@hostname:8080/job/pipeline_name/buildWithParameters?token=pipeline_token&serviceName=amanuensis&imageName=quay.io/pcdc/latest`

------

### How change Jenkins pipeline job

Click Dashboard -> pipeline_name -> Configuration. Groovy script defining jenkins Pipeline, you can 

- Add/remove stage
- Change script content under stage/steps

**Note**: scripts are all stored in slave node, Jenkins just invokes them.

<img src="/Users/qwb/Library/Application Support/typora-user-images/image-20240822195533604.png" alt="image-20240822195533604" style="zoom:50%;" />

------

### Important Jenkins configurations

- #### Github CI/CD configuration

  1. Click `Pipeline Syntax`

​	<img src="/Users/qwb/Library/Application Support/typora-user-images/image-20240822231923203.png" alt="image-20240822231923203" style="zoom:50%;" />

​	2. Configure github URL, credential, and branch

<img src="/Users/qwb/Library/Application Support/typora-user-images/image-20240822232307286.png" alt="image-20240822232307286" style="zoom:50%;" />

​	3. Generate script

<img src="/Users/qwb/Library/Application Support/typora-user-images/image-20240822232525421.png" alt="image-20240822232525421" style="zoom:50%;" />

​	4. Copy step 3 script into pipeline and enable triggering

<img src="/Users/qwb/Library/Application Support/typora-user-images/image-20240822233108370.png" alt="image-20240822233108370" style="zoom:50%;" />

- #### Email notification

- How to add an email recipient and change content

  <img src="/Users/qwb/Library/Application Support/typora-user-images/image-20240822235937496.png" alt="image-20240822235937496" style="zoom:50%;" />

  <img src="/Users/qwb/Library/Application Support/typora-user-images/image-20240823000022256.png" alt="image-20240823000022256" style="zoom:50%;" />

  <img src="/Users/qwb/Library/Application Support/typora-user-images/image-20240822235749576.png" alt="image-20240822235749576" style="zoom:67%;" />

- #### Jenkins remote trigger

​	1. Enable building remotely trigger and set URL token

<img src="/Users/qwb/Library/Application Support/typora-user-images/image-20240822233524213.png" alt="image-20240822233524213" style="zoom:50%;" />

​	2. Add parameter for URL

​	<img src="/Users/qwb/Library/Application Support/typora-user-images/image-20240822233817303.png" alt="image-20240822233817303" style="zoom:50%;" />

 3. Generate Jenkins user token

    <img src="/Users/qwb/Library/Application Support/typora-user-images/image-20240822234209816.png" alt="image-20240822234209816" style="zoom: 67%;" />

​	<img src="/Users/qwb/Library/Application Support/typora-user-images/image-20240822234240932.png" alt="image-20240822234240932" style="zoom:50%;" />

4. Use this token in URL like

    http://jenkins_username:`**your_token**`@hostname:8080/job/pcdc-amanuensis-test/buildWithParameters?token=amanuensis-pipeline&serviceName=amanuensis

