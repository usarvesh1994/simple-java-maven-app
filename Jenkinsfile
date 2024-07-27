@Library('jenkins-Shared-Library') _

def gv

pipeline {
    agent any
      tools {
        maven 'maven-3.9' 
    } 

    triggers {
        pollSCM('* * * * *') // This is a fallback polling trigger, if webhooks fail
    }


    stages {
        stage('Building Jarssss') {
            steps {
               buildJar()

               
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