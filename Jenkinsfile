pipeline {

    agent any

    environment {
        IMAGE_PREFIX = "shopsphere"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Environment Check') {
            steps {
                sh '''
                    echo "Python version:"
                    python3 --version

                    echo "Docker version:"
                    docker --version

                    echo "Git version:"
                    git --version
                '''
            }
        }

        stage('Unit Tests') {
            steps {
                sh '''
                    set -e

                    for service in user-service product-service order-service payment-service notification-service
                    do
                        echo "========================================"
                        echo "Testing $service"
                        echo "========================================"

                        cd services/$service

                        python3 -m venv venv
                        . venv/bin/activate

                        pip install --no-cache-dir -r requirements.txt

                        pytest -v

                        deactivate

                        cd ../..
                    done
                '''
            }

            post {
                always {
                    junit allowEmptyResults: true,
                         testResults: '**/test-results/*.xml'
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonarqube') {

                    sh '''
                        echo "Running SonarQube analysis..."

                        sonar-scanner \
                          -Dsonar.projectKey=shopsphere \
                          -Dsonar.sources=services \
                          -Dsonar.exclusions="**/venv/**,**/__pycache__/**"
                    '''
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Docker Build') {
            steps {

                sh '''
                    set -e

                    docker build \
                        -t shopsphere-user:${BUILD_NUMBER} \
                        services/user-service

                    docker build \
                        -t shopsphere-product:${BUILD_NUMBER} \
                        services/product-service

                    docker build \
                        -t shopsphere-order:${BUILD_NUMBER} \
                        services/order-service

                    docker build \
                        -t shopsphere-payment:${BUILD_NUMBER} \
                        services/payment-service

                    docker build \
                        -t shopsphere-notification:${BUILD_NUMBER} \
                        services/notification-service
                '''
            }
        }

        stage('Trivy Filesystem Scan') {
            steps {

                sh '''
                    docker run --rm \
                        -v "$WORKSPACE:/workspace" \
                        aquasec/trivy:0.72.0 \
                        fs \
                        --scanners vuln,secret,misconfig \
                        --severity HIGH,CRITICAL \
                        --exit-code 1 \
                        /workspace
                '''
            }
        }

        stage('Trivy Image Scan') {
            steps {

                sh '''
                    set -e

                    for image in \
                        shopsphere-user:${BUILD_NUMBER} \
                        shopsphere-product:${BUILD_NUMBER} \
                        shopsphere-order:${BUILD_NUMBER} \
                        shopsphere-payment:${BUILD_NUMBER} \
                        shopsphere-notification:${BUILD_NUMBER}
                    do

                        echo "========================================"
                        echo "Scanning $image"
                        echo "========================================"

                        docker run --rm \
                            -v /var/run/docker.sock:/var/run/docker.sock \
                            aquasec/trivy:0.72.0 \
                            image \
                            --severity HIGH,CRITICAL \
                            --exit-code 1 \
                            "$image"

                    done
                '''
            }
        }

        stage('Images') {
            steps {
                sh '''
                    docker images | grep shopsphere
                '''
            }
        }
    }

    post {

        success {
            echo 'CI pipeline completed successfully.'
        }

        failure {
            echo 'CI pipeline failed. Check the failed stage and logs.'
        }

        always {
            echo "Build completed: ${BUILD_NUMBER}"
        }
    }
}
