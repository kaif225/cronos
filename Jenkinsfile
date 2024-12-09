pipeline {
    agent none

    stages {
        stage('PHP Test') {
            agent {
                docker {
                    image 'serversideup/php:8.3-cli'
                    args '--user root'
                }
            }

            steps {
                sh '''
                install-php-extensions intl gd xsl pcov xdebug
                echo "zend_extension=/usr/local/lib/php/extensions/no-debug-non-zts-20230831/xdebug.so" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
                cp .env.example .env && \
                curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
                composer config --no-plugins allow-plugins.phpstan/extension-installer true && \
                composer install --no-interaction --prefer-dist && \
                php artisan key:generate && \
                php artisan test -p --log-junit coverage/tests.xml --coverage-xml coverage --colors=never
                '''
            }
            
            post {
                always {
                    archiveArtifacts artifacts: 'coverage/tests.xml, coverage/index.xml', allowEmptyArchive: true
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
                    withSonarQubeEnv('sonarNew') {
                        sh "${scannerHome}/bin/sonar-scanner \
                             -Dsonar.projectKey=cronos \
                             -Dsonar.projectName=cronos \
                             -Dsonar.sources=. \
                             -Dsonar.projectVersion=1.0 \
                             -Dsonar.php.coverage.reportPaths=coverage/index.xml \
                             -Dsonar.php.tests.reportPath=coverage/tests.xml"
                    }
                }
            }
        }

        stage('Quality Gate') {
            agent {
                docker {
                    image 'sonarsource/sonar-scanner-cli:latest'
                    args '--user root'
                }
            }
            steps {
                script {
                    timeout(time: 5, unit: 'MINUTES') {
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
    }
}
