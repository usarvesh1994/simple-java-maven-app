

pipeline {

    agent any
    tools {
        maven 'maven-3.9' 
    }

    stages {
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
                    archiveArtifacts artifacts: '**/target/*.jar', fingerprint: true
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
                    sh "${scannerHome}/bin/sonar-scanner -Dsonar.projectKey=simple-java-maven-app -Dsonar.sources=src/main/java -Dsonar.tests=src/test/java -Dsonar.java.binaries=target/classes -Dsonar.junit.reportPaths=target/surefire-reports -Dsonar.jacoco.reportPaths=target/jacoco.exec"
                }
            }
        }

        stage('Quality Gates') {
            steps {
                script {
                    timeout(time: 1, unit: 'HOURS') {
                        waitForQualityGate abortPipeline: true
                    }
                }
            }
        } 

           stage('Artifact uploader') {
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
                    [artifactId: 'maven-app',
                    classifier: '',
                    file: 'target/my-app-1.0-SNAPSHOT.jar',
                    type: 'jar']
                ]
            )
                    }
        } 

    }

     post {
        success {
            slackSend(channel: "#devops", color: 'good', message: "Build ${env.JOB_NAME} #${env.BUILD_NUMBER} succeeded")
        }
        failure {
            slackSend(channel: "#devops",, color: 'danger', message: "Build ${env.JOB_NAME} #${env.BUILD_NUMBER} failed")
        }
        always {
            slackSend(channel: "#devops",, color: 'warning', message: "Build ${env.JOB_NAME} #${env.BUILD_NUMBER} completed")
        }
    }
}
