String deduceDockerTag() {
    String dockerTag = env.BRANCH_NAME
    if (dockerTag.equals("main")) {
        echo "Building the 'main' branch so we'll publish a Docker tag starting with 'latest'"
        dockerTag = "latest"
    } else {
        dockerTag += env.BUILD_NUMBER
        echo "Building a branch other than 'main' so will publish a Docker tag starting with '$dockerTag', not 'latest'"
    }
    return dockerTag
}

pipeline {
    agent none

    stages {
        stage('Versions') {
            matrix {
                agent {
                    label 'docker'
                }
                axes {
                    axis {
                        name "JDKVERSION"
                        values "jdk8", "jdk11", "jdk17"
                    }
                }
                environment {
                    GAR_BASE_URL = "us-east1-docker.pkg.dev"
                    DOCKER_TAG = deduceDockerTag()
                    FULL_IMAGE_NAME = "${GAR_BASE_URL}/teralivekubernetes/test-docker/precachedagent:${DOCKER_TAG}-${JDKVERSION}"
                }

                stages {
                    stage('Build Docker"') {
                        steps {
                            sh "docker build -t ${FULL_IMAGE_NAME} --build-arg JDKVERSION=${JDKVERSION} ."
                        }
                    }
                    stage('Push Docker Image') {
                        steps {
                            script {
                                // Authenticate with GAR using the service account key then push
                                withCredentials([file(credentialsId: 'jenkins-gar-sa', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
                                    sh """
                                        cat \${GOOGLE_APPLICATION_CREDENTIALS} | docker login -u _json_key --password-stdin https://${GAR_BASE_URL}
                                        docker push ${FULL_IMAGE_NAME}
                                    """
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
