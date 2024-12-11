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
            environment {
                scannerHome = tool 'sonar'
            }
            steps {
                script {
                    withSonarQubeEnv('sonarNew') {
                        sh "${scannerHome}/bin/sonar-scanner \
                             -Dsonar.projectKey=cronos \
                             -Dsonar.projectName=cronos \
                             -Dsonar.sources=. \
                             -Dsonar.projectVersion=1.0 \
                             -Dsonar.tests=tests \
                             -Dsonar.exclusions=vendor/**,node_modules/**,tests/**,coverage/**,coverage_report/** \
                             -Dsonar.php.coverage.reportPaths=coverage/coverage.xml \
                             -Dsonar.php.tests.reportPath=coverage/tests.xml"      
                    }
                }
            }
        }
        stage('quality gate') {
            steps {
                script {
                    def qg = waitForQualityGate()
                    if (qg.status != 'OK') {
                        echo "Quality Gate failed: ${qg.status}"
                        echo "Full Quality Gate details: ${qg}"
                        error "Pipeline failed due to quality gate failure: ${qg.status}"
                    }
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}

