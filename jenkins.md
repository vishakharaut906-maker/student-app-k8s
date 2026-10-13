 Classroom Hands-On Lab: Understanding Pipeline Stages in Freestyle

## Objective
Build a simple Jenkins Freestyle job that demonstrates the **4 fundamental stages** of a CI/CD pipeline (**Checkout ➔ Build ➔ Test ➔ Package/Archive**) using clear console logs and artifact saving.

---

## Step 1: Create the Project
1. Log into the **Jenkins Dashboard**.
2. Click **New Item** in the top-left sidebar.
3. Enter the item name: `student-pipeline-demo`.
4. Select **Freestyle project** and click **OK**.

---

## Step 2: Stage 1 — Source Code Checkout
1. Scroll down to the **Source Code Management** section.
2. Select **Git**.
3. In **Repository URL**, enter any public repository URL (or a student repository).
4. In **Branch Specifier**, ensure it is set to `*/main` or `*/master`.

> **Student Key Concept:** *This stage fetches the project files from Git and downloads them into the Jenkins Workspace directory.*

---

## Step 3: Stages 2 & 3 — Build and Test
1. Scroll down to **Build Steps**.
2. Click **Add build step** and choose **Execute shell**.
3. Paste the following script:

```bash
echo "=========================================="
echo "STAGE 1: CHECKOUT"
echo "Code successfully fetched into: $WORKSPACE"
echo "=========================================="

echo "=========================================="
echo "STAGE 2: BUILD"
echo "Compiling application files..."
sleep 2
echo "Build Successful!"
echo "=========================================="

echo "=========================================="
echo "STAGE 3: TEST"
echo "Running automated unit tests..."
sleep 2
echo "Test Suite: 10 Passed, 0 Failed."
echo "=========================================="
```

> **Student Key Concept:** *Build steps execute top-to-bottom sequentially. If any command returns an error code, Jenkins stops the pipeline immediately and marks the build as Failed (Red).*

---

## Step 4: Stage 4 — Package & Archive
1. Scroll down to **Post-build Actions**.
2. Click **Add post-build action** and select **Archive the artifacts**.
3. In **Files to archive**, type:
   ```plaintext
   **/*
   ```
4. Click **Save** at the bottom of the page.

> **Student Key Concept:** *Post-build actions run after all build steps finish. Archiving saves final outputs or repository state so users can download them directly from Jenkins.*

---

## Step 5: Run & Review the Pipeline Output
1. On the left navigation panel, click **Build Now**.
2. Under **Build History**, click on **#1**.
3. Click **Console Output** to review the log output showing each stage executing sequentially.
4. Return to the **Status** page of Build #1 to view and download the archived files under **Build Artifacts**.







# Jenkins Pipeline

```groovy
pipeline {
    agent any

    stages {

        stage('Clone') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/Sourabhf4/student-app-k8s.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                dir('frontend') {
                    sh 'docker build -t frontend:latest .'
                }
            }
        }

        stage('Run Container') {
            steps {
                sh '''
                    docker run -d --name frontend -p 80:80 frontend:latest
                '''
            }
        }
    }
}




Jenkins Pipeline Prerequisites
1. Server-Level Requirements

The Jenkins server must have the following installed:

Java 17
Git
Maven
AWS CLI
Check Java
java -version
Check Git
git --version
Check Maven
mvn -version

If Maven is not installed:

sudo apt update
sudo apt install maven -y
Check AWS CLI
aws --version

If AWS CLI is not installed:

sudo apt update
sudo apt install awscli -y
2. AWS Configuration

AWS must be configured for the Jenkins user, because Jenkins executes the pipeline using the jenkins user.

Configure AWS:

sudo -u jenkins aws configure

Enter:

AWS Access Key ID: <your-access-key>
AWS Secret Access Key: <your-secret-key>
Default region name: ap-southeast-2
Default output format: json
Verify AWS Configuration
sudo -u jenkins aws sts get-caller-identity
Test S3 Access
sudo -u jenkins aws s3 ls s3://super-mario-game-bucket1

Both commands should work successfully.

For production environments, an EC2 IAM Role is recommended instead of storing long-lived AWS access keys.

3. S3 Requirements

The following S3 bucket must exist:

super-mario-game-bucket1

The AWS user configured for the Jenkins user must have permission to upload objects to this bucket.

The pipeline uploads:

backend/target/student-registration-backend-0.0.1-SNAPSHOT.jar

to:

s3://super-mario-game-bucket1/backend/target/student-registration-backend-0.0.1-SNAPSHOT.jar
Jenkins Console-Level Requirements
4. Required Jenkins Plugins

Go to:

Manage Jenkins → Plugins → Available plugins

Install:

Git

Required for:

git branch: 'main',
    url: 'https://github.com/prathamnandgirwar/student-app-k8s.git'
Pipeline: AWS Steps

Required for:

withAWS()
s3Upload()

The Pipeline plugin is normally installed during the standard Jenkins installation.

5. Configure JDK 17

Go to:

Manage Jenkins → Tools → JDK installations

Add:

Name: jdk17

The name must exactly match the Jenkinsfile:

tools {
    jdk 'jdk17'
}
6. Jenkins Node and Executor

Go to:

Manage Jenkins → Nodes

Make sure the Built-In Node is:

Online

Make sure at least 1 executor is available.

A separate Jenkins agent is not required for this pipeline.

GitHub Repository Requirements

Repository:

https://github.com/prathamnandgirwar/student-app-k8s.git

Expected structure:

student-app-k8s/
├── backend/
│   ├── pom.xml
│   └── ...
└── ...

The pipeline runs:

cd backend
mvn clean package -DskipTests

Therefore:

backend/pom.xml

must exist.

The Maven build must generate:

backend/target/student-registration-backend-0.0.1-SNAPSHOT.jar
Jenkins Pipeline
pipeline {
    agent any


    tools {
        jdk 'jdk17'
    }


    stages {


        stage('pull') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/prathamnandgirwar/student-app-k8s.git'
            }
        }


        stage('build') {
            steps {
                sh '''
                    cd backend
                    mvn clean package -DskipTests
                '''
            }
        }


        stage('s3upload') {
            steps {
                withAWS(region: 'ap-southeast-2') {
                    s3Upload(
                        bucket: 'super-mario-game-bucket1',
                        file: 'backend/target/student-registration-backend-0.0.1-SNAPSHOT.jar',
                        path: 'backend/target/student-registration-backend-0.0.1-SNAPSHOT.jar'
                    )
                }
            }
        }
    }
}
Final Verification

Run these commands on the Jenkins server before running the pipeline:

java -version
git --version
mvn -version
aws --version

Verify AWS for the Jenkins user:

sudo -u jenkins aws sts get-caller-identity

Verify S3 access:

sudo -u jenkins aws s3 ls s3://super-mario-game-bucket1
Complete Checklist
Server Level
 Java 17 installed
 Git installed
 Maven installed
 AWS CLI installed
 AWS configured for jenkins user
 S3 bucket exists
 Jenkins AWS identity has S3 upload permission
 Internet connectivity available
 Sufficient disk space available
Jenkins Console Level
 Git plugin installed
 Pipeline: AWS Steps plugin installed
 JDK installation named jdk17
 Built-In Node is online
 At least 1 executor available
 Pipeline job created
Pipeline Flow
Jenkins
   |
   |-- Pull
   ↓
GitHub Repository
   |
   ↓
Backend Source Code
   |
   |-- Maven Build
   ↓
JAR File
   |
   |-- AWS Authentication
   ↓
S3 Bucket
   |


   ↓
Uploaded JAR









```groovy
pipeline {
    agent any

    stages {

        stage('Clone') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/Sourabhf4/practice.git'
            }
        }

        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }

        stage('Terraform Plan') {
            steps {
                sh 'terraform plan'
            }
        }

        stage('Terraform Apply') {
            steps {
                sh 'terraform apply -auto-approve'
            }
        }
    }
}


==============================================================================================


pipeline {
    agent any

    stages {
        stage('checkout') {
            steps {
                git branch: "main", url:"https://github.com/Sourabhf4/CDEC-B-6.git"
            }
        }
        stage('build') {
            steps {
                sh """ 
                   docker build -t project .
                """
            }
        }
        stage('deploy') {
            steps {
                sh """ 
                    docker run -it --name demo-container -p 80:80 project:latest 
                """
            }
        }
        stage("pushimagetodockerhub")  {
            steps {
                sh """
                    docker login -u username -p YOUR_DOCKERHUB_PASSWORD
                    docker tag project:latest YOUR_DOCKERHUB_USERNAME/project:latest
                    docker push YOUR_DOCKERHUB_USERNAME/project:latest
                """
            }
        }
    }
}














