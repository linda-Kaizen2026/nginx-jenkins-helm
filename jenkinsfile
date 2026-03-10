pipeline {
    agent any

    stages {

        stage('Checkout Source Code') {
            steps {
                git branch: 'develop', 
                url 'https://github.com/linda-Kaizen2026/nginx-jenkins-helm.git'
            }
        }

        stage('Run Ruby Deployment Script') {
            steps {
                sh 'ruby deploy.rb'
            }
        }

    }
}
