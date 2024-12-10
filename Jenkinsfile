pipeline {
    agent {
                docker {
                    image 'serversideup/php:8.3-cli'
                    args '--user root'
                }
            }

    stages {
        stage('installing required packages') {
            steps {
                sh '''
                install-php-extensions intl gd xsl pcov
                cp .env.example .env && \
                curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
                composer config --no-plugins allow-plugins.phpstan/extension-installer true && \
                composer install --no-interaction --prefer-dist && \
                php artisan key:generate 
                '''
            }
        }
        stage('php test') {
            steps {
                sh 'php artisan test -p --log-junit coverage/tests.xml --coverage-clover coverage/coverage.xml  --colors=never'
            }
            post {
                always {
                    archiveArtifacts artifacts: 'coverage/tests.xml, coverage/coverage.xml', allowEmptyArchive: true
                }
            }
        }

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
                    sh "cp -r /var/jenkins_home/workspace/Cronos_pipeline/coverage/* ."
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
