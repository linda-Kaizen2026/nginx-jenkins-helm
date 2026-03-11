pipeline {
    agent any

    environment {
        GIT_REPO = "https://github.com/linda-Kaizen2026/nginx-jenkins-helm.git"
        GIT_BRANCH = "develop"

        DOCKER_IMAGE = "lindakaizen2026/nginx-app"
        DOCKER_CREDENTIALS = "dockerhub-creds"

        HELM_RELEASE = "nginx-release"
        HELM_CHART_PATH = "./helm/nginx-chart"
    }

    stages {

        stage('Checkout Code') {
            steps {
                echo "Cloning Git repository"
                git branch: "${GIT_BRANCH}", url: "${GIT_REPO}"
            }
        }

        stage('Verify Project Files') {
            steps {
                sh "ls -la"
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "Building Docker Image"
                sh "docker build -t ${DOCKER_IMAGE}:${BUILD_NUMBER} ."
            }
        }

        stage('DockerHub Login') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: "${DOCKER_CREDENTIALS}",
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh """
                    echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin
                    """
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                echo "Pushing Docker Image"
                sh """
                docker push ${DOCKER_IMAGE}:${BUILD_NUMBER}
                docker tag ${DOCKER_IMAGE}:${BUILD_NUMBER} ${DOCKER_IMAGE}:latest
                docker push ${DOCKER_IMAGE}:latest
                """
            }
        }

        stage('Deploy with Helm') {
            steps {
                echo "Deploying application using Helm"
                sh """
                helm upgrade --install ${HELM_RELEASE} ${HELM_CHART_PATH} \
                --set image.repository=${DOCKER_IMAGE} \
                --set image.tag=${BUILD_NUMBER}
                """
            }
        }

        stage('Verify Kubernetes Deployment') {
            steps {
                echo "Checking Kubernetes resources"
                sh "kubectl get pods"
                sh "kubectl get svc"
            }
        }
    }

    post {
        success {
            echo "Pipeline completed successfully"
        }

        failure {
            echo "Pipeline failed"
        }
    }
}
