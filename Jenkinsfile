pipeline {
    agent none

    stages {
        
        stage('Code Analysis') {
            agent {
                docker {
                    image 'sonarsource/sonar-scanner-cli:latest'
                    args '--user root'
                }
            }
            
            steps {
                script {
                    withSonarQubeEnv('sonarNew') {
                        sh "${scannerHome}/bin/sonar-scanner \
                             -Dsonar.projectKey=cronos \
                             -Dsonar.projectName=cronos \
                             -Dsonar.sources=. \
                             -Dsonar.projectVersion=1.0 \
                             -Dsonar.qualitygate.wait=true \
                             -Dsonar.tests=tests \
                             -Dsonar.exclusions=vendor/**,node_modules/**,tests/**,coverage/**,coverage_report/** \
                             -Dsonar.php.coverage.reportPaths=coverage/coverage.xml \
                             -Dsonar.php.tests.reportPath=coverage/tests.xml"      
                    }
                }
            }
        }
    }
}
