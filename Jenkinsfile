pipeline {
    agent {
        label 'docker' 
    }

    stages {
        stage('Build Docker"') {
            steps {
              sh 'docker build -t precachedagent:latest .'
              sh 'docker tag precachedagent:latest us-east1-docker.pkg.dev/teralivekubernetes/test-docker/precachedagent:latest'
            }
        }
        stage('Push Docker Image') {
            steps {
                script {
                    def garImage = 'us-east1-docker.pkg.dev/teralivekubernetes/test-docker/precachedagent:latest'

                    // Authenticate with GAR using the service account key then push
                    withCredentials([file(credentialsId: 'jenkins-gar-sa', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
                        sh """
                        cat \${GOOGLE_APPLICATION_CREDENTIALS} | docker login -u _json_key --password-stdin https://us-east1-docker.pkg.dev
                        docker push ${garImage}
                        """
                    }
                }
            }
        }
    }
}
