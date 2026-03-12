pipeline {
	agent any

    environment {
        GIT_REPO = "${GITHUB_USER}"
        GIT_BRANCH = "develop"

        DOCKER_IMAGE = "${DOCKER_USER}/nginx-app"
        DOCKER_CREDENTIALS = "dockerhub-creds"

        KUBECONFIG_CREDENTIAL = "kubeconfig"

        HELM_RELEASE = "nginx-release"
        HELM_CHART_PATH = "./helm/nginx-chart"

        K8S_NAMESPACE = "nginx-dev"
    }

    stages {

        stage('Checkout Code') {
            steps {
                echo "Cloning repository"
                git branch: "${GIT_BRANCH}", url: "${GIT_REPO}"
            }
        }

        stage('Verify Project Files') {
            steps {
                echo "Listing project files"
                sh "ls -la"
            }
        }

        stage('Helm Lint Test') {
            steps {
                echo "Running Helm lint"

                sh '''
                helm lint ./helm/nginx-chart
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "Building Docker Image"

                sh '''
                docker build -t ${DOCKER_IMAGE}:${BUILD_NUMBER} .
                '''
            }
        }

        stage('DockerHub Login') {
            steps {

                withCredentials([usernamePassword(
                    credentialsId: "${DOCKER_CREDENTIALS}",
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {

                    sh '''
                    echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                    '''
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                echo "Pushing Docker image"

                sh '''
                docker push ${DOCKER_IMAGE}:${BUILD_NUMBER}

                docker tag ${DOCKER_IMAGE}:${BUILD_NUMBER} ${DOCKER_IMAGE}:latest

                docker push ${DOCKER_IMAGE}:latest
                '''
            }
        }

        stage('Deploy to Kubernetes using Helm') {

            steps {

                echo "Deploying application to Kubernetes"

                withCredentials([file(credentialsId: "${KUBECONFIG_CREDENTIAL}", variable: 'KUBECONFIG')]) {

                    sh '''
                    export KUBECONFIG=$KUBECONFIG

                    echo "Creating namespace if not exists"
                    kubectl create namespace ${K8S_NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -

                    echo "Checking Kubernetes Cluster"
                    kubectl get nodes

                    echo "Deploying Helm Chart"

                    helm upgrade --install ${HELM_RELEASE} ${HELM_CHART_PATH} \
                      --namespace ${K8S_NAMESPACE} \
                      --create-namespace \
                      --set image.repository=${DOCKER_IMAGE} \
                      --set image.tag=${BUILD_NUMBER} \
                      --atomic \
                      --timeout 2m
                    '''
                }
            }
        }

        stage('Verify Kubernetes Deployment') {

            steps {

                withCredentials([file(credentialsId: "${KUBECONFIG_CREDENTIAL}", variable: 'KUBECONFIG')]) {

                    sh '''
                    export KUBECONFIG=$KUBECONFIG

                    echo "Pods:"
                    kubectl get pods -n ${K8S_NAMESPACE}

                    echo "Services:"
                    kubectl get svc -n ${K8S_NAMESPACE}

                    echo "Deployments:"
                    kubectl get deployments -n ${K8S_NAMESPACE}

                    echo "Ingress:"
                    kubectl get ingess -n ${K8S_NAMESPACE}

                    '''
                }
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

        always {
            echo "Pipeline finished"
        }
    }
}
