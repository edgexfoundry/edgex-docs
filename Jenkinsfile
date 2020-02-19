pipeline {
    agent { label 'centos7-docker-4c-2g' }
    options {
        timestamps()
    }
    
    stages {
        stage('Build Docs') {
                agent {
                docker { 
                    image 'python:3-slim' 
                    reuseNode true
                    args '-u 0:0 --privileged'
                }
            }
            steps{
                sh 'pip install mkdocs'
                sh 'pip install mkdocs-material'
                sh 'mkdocs build'
            }
        }
    }
}