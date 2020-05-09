pipeline {
    options { disableConcurrentBuilds() }
    agent any
    environment {
        PROJECT_ID = 'reliable-brace-268207'
        CLUSTER_NAME = 'ibc-gke-dev'
        CREDENTIALS_ID = 'reliable-brace-gcr-credentials'
        LOCATION = 'us-central1-a'
    }
    stages {
        stage('cleanup') {
            steps {
                script{
                    echo "Stopping any old container to release ports needs for the new builds"
                    sleep 5
                    sh "docker stop \$(docker ps -q) 2>/dev/null || true"
                    sleep 5
                }
            }
        }
        stage('Build') {
            steps {
                script {
                    echo "Building Docker image"
                    myapp = docker.build("kranthik123/umbrella_zipcodes:${env.BUILD_ID}")
                }
            }
        }
        stage('run_container') {
            steps {
                script{
                    echo "Starting Docker Container locally for testing the build"
                    sh "docker run -d -p 4000:4000 kranthik123/umbrella_zipcodes:${env.BUILD_ID}"
                }
            }
        }
        stage('build-test') {
            steps {
                withPythonEnv('python3') {
                    echo "Testing the new build to validate code and provide test coverage"
                    sh "cd \$WORKSPACE/app && pip install -r requirements.txt && nose2 -v --with-coverage"
                }
            }
        }
        stage('push-image') {
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', 'DockerHubCreds') {
                        myapp.push("latest")
                        myapp.push("${env.BUILD_ID}")
                    }
                }
            }
        }
        stage('Deploy-To-Dev') {
            steps {
              sh "cd \$WORKSPACE/manifests && pwd && ls -l && cat dev_deployment.yaml && sed -i 's/umbrella_zipcodes:latest/umbrella_zipcodes:${env.BUILD_ID}/g' \$WORKSPACE/manifests/dev_deployment.yaml"
              sh "cat \$WORKSPACE/manifests/dev_deployment.yaml"
              echo "Deploying to Dev Kubernetes namespace"
              step([$class: 'KubernetesEngineBuilder', projectId: env.PROJECT_ID, clusterName: env.CLUSTER_NAME, location: env.LOCATION, manifestPattern: "manifests/dev_deployment.yaml", credentialsId: env.CREDENTIALS_ID, verifyDeployments: false])
              echo "Deploying to Dev Kubernetes namespace completed successfully."
            }
        }
        stage('Deploy-To-stage') {
            steps {
                sh "cd \$WORKSPACE/manifests && pwd && ls -l && cat stage_deployment.yaml && sed -i 's/umbrella_zipcodes:latest/umbrella_zipcodes:${env.BUILD_ID}/g' \$WORKSPACE/manifests/stage_deployment.yaml"
                sh "cat \$WORKSPACE/manifests/stage_deployment.yaml"
                echo "Deploying to Stage Kubernetes namespace."
                step([$class: 'KubernetesEngineBuilder', projectId: env.PROJECT_ID, clusterName: env.CLUSTER_NAME, location: env.LOCATION, manifestPattern: "manifests/stage_deployment.yaml", credentialsId: env.CREDENTIALS_ID, verifyDeployments: false])
                echo "Deploying to Stage Kubernetes namespace completed successfully."
            }
        }
        stage('Deploy-To-prod') {
            steps {
                sh "cd \$WORKSPACE/manifests && pwd && ls -l && cat prod_deployment.yaml && sed -i 's/umbrella_zipcodes:latest/umbrella_zipcodes:${env.BUILD_ID}/g' \$WORKSPACE/manifests/prod_deployment.yaml"
                sh "cat \$WORKSPACE/manifests/prod_deployment.yaml"
                echo "Deploying to Prod Kubernetes namespace."
                step([$class: 'KubernetesEngineBuilder', projectId: env.PROJECT_ID, clusterName: env.CLUSTER_NAME, location: env.LOCATION, manifestPattern: "manifests/prod_deployment.yaml", credentialsId: env.CREDENTIALS_ID, verifyDeployments: false])
                echo "Deploying to Prod Kubernetes namespace completed successfully."
            }
        }
    }

  }
//===================================
