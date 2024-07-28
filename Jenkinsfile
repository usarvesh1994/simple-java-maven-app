@Library('jenkins-Shared-Library') _

def gv

pipeline {
    agent any
      tools {
        maven 'maven-3.9' 
    } 

 

    stages {
        stage('Increment Version') {
            steps {
                script {
                    sh '''
                        mvn build-helper:parse-version versions:set -DnewVersion=${parsedVersion.majorVersion}.${parsedVersion.minorVersion}.${parsedVersion.nextIncrementalVersion} versions:commit
                    '''
                }
            }
        }
        stage('Building Jar') {
            steps { 
               sh "mvn clean package"   
            }
        }

         stage('Building image') {
            environment {
                SERVICE_CREDS = credentials('nexus')
            }
            steps {
                
                buildImage()
            }
        }
    }
}