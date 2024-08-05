pipeline {
    agent any
    environment {
        REPO_CRED = 'ecr:ap-southeast-2:awsjenkins'
        REPO_URI = '148000812951.dkr.ecr.ap-southeast-2.amazonaws.com/jenkinsrepo'
        IMAGE_NAME = "${REPO_URI}:${env.BUILD_ID}"
        ECR_REGISTRY = 'https://148000812951.dkr.ecr.ap-southeast-2.amazonaws.com'
    }
    tools {
        maven 'maven-3.9'
    }

    stages {

         stage('Install AWS CLI') {
            steps {
                sh 'curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"'
                sh 'unzip awscliv2.zip'
                sh './aws/install'
            }
        }

        stage('Fetch Code') {
            steps {
                git credentialsId: 'githhub', branch: 'master', url: 'https://github.com/usarvesh1994/simple-java-maven-app.git'
            }
        }

        stage('Build Phases') {
            steps {
                sh 'mvn install'
            }
            post {
                success {
                    echo 'Archiving...'
                    archiveArtifacts artifacts: '**/target/*.war', fingerprint: true
                }
            }
        }

        stage('Unit Testing') {
            steps {
                sh 'mvn test'
            }
        }

        stage('Code Checkstyle Analysis') {
            steps {
                sh 'mvn checkstyle:checkstyle'
            }
        }

        stage('Code Coverage') {
            steps {
                sh 'mvn jacoco:report'
            }
        }

        stage('SonarQube Analysis') {
            environment {
                scannerHome = tool 'sonar4.7' // Ensure this matches the SonarQube Scanner configuration name in Jenkins
            }
            steps {
                withSonarQubeEnv('sonar') { // Ensure this matches the name of the SonarQube server configuration in Jenkins
                    sh "${scannerHome}/bin/sonar-scanner -Dsonar.projectKey=simple-java-maven-app -Dsonar.sources=src/main/webapp"
                }
            }
        }

        stage('Artifact Uploader') {
            steps {
                nexusArtifactUploader(
                    nexusVersion: 'nexus3',
                    protocol: 'http',
                    nexusUrl: '172.31.0.215:8081',
                    groupId: 'QA',
                    version: "${env.BUILD_ID}-${env.BUILD_TIMESTAMP}",
                    repository: 'maven-jave',
                    credentialsId: 'NexusCred',
                    artifacts: [
                        [
                            artifactId: 'maven-app',
                            classifier: '',
                            file: 'target/maven-web.war',
                            type: 'war'
                        ]
                    ]
                )
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    dockerImage = docker.build(IMAGE_NAME)
                }
            }
        }

        stage('Image Push') {
            steps {
                script {
                    docker.withRegistry(ECR_REGISTRY, REPO_CRED) {
                        dockerImage.push("${env.BUILD_ID}")
                        dockerImage.push('latest')
                    }
                }
            }
        }

         stage('Deploy ECS') {
            steps {
                withAWS(credentials:'awsjenkins',region:'ap-southeast-2') {
                       sh 'aws ecs update-service --cluster devcluster --service jenkins-service --force-new-deployment'

                    }
                
            }
        }
    }

    post {
        success {
            slackSend(channel: "#devops", color: 'good', message: "Build ${env.JOB_NAME} #${env.BUILD_NUMBER} succeeded")
        }
        failure {
            slackSend(channel: "#devops", color: 'danger', message: "Build ${env.JOB_NAME} #${env.BUILD_NUMBER} failed")
        }
        always {
            slackSend(channel: "#devops", color: 'warning', message: "Build ${env.JOB_NAME} #${env.BUILD_NUMBER} completed")
        }
    }
}
