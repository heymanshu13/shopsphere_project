pipeline {

    agent any

    environment {
        IMAGE_PREFIX = "shopsphere"

        AWS_ACCOUNT_ID = '278177224853'
        AWS_REGION = 'ap-south-1'
        ECR_REGISTRY = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

        IMAGE_TAG = "${BUILD_NUMBER}"
    }

    stages {

        // =========================================================
        // CHECKOUT
        // =========================================================

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('AWS Authentication Test') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'shopsphere-aws',
                        usernameVariable: 'AWS_ACCESS_KEY_ID',
                        passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                    )
                ]) {
                    sh '''
                        set -e
        
                        echo "AWS CLI:"
                        aws --version
        
                        echo "AWS Identity:"
                        aws sts get-caller-identity
                    '''
                }
            }
        }
        
        // =========================================================
        // ENVIRONMENT CHECK
        // =========================================================

        stage('Environment Check') {
            steps {
                sh '''
                    echo "========================================"
                    echo "Environment Check"
                    echo "========================================"

                    echo "Python version:"
                    python3 --version

                    echo ""
                    echo "Docker version:"
                    docker --version

                    echo ""
                    echo "Git version:"
                    git --version

                    echo ""
                    echo "Jenkins Build Number:"
                    echo "${BUILD_NUMBER}"

                    echo ""
                    echo "Docker Image Tag:"
                    echo "${IMAGE_TAG}"

                    echo ""
                    echo "ECR Registry:"
                    echo "${ECR_REGISTRY}"
                '''
            }
        }


        // =========================================================
        // UNIT TESTS
        // =========================================================

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

                        python -m pytest -v

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
        
        stage('Gitleaks Secret Scan') {
                steps {
                    sh '''
                        set -e
            
                        echo "========================================"
                        echo "Running Gitleaks Secret Scan"
                        echo "========================================"
            
                        docker run --rm \
                            -v /home/heymanshu/shopsphere:/workspace \
                            zricethezav/gitleaks:latest \
                            detect \
                            --no-git \
                            --source=/workspace \
                            --config=/workspace/.gitleaks.toml \
                            --no-banner \
                            --redact \
                            --exit-code 1
                    '''
                }
            }

        // =========================================================
        // TRIVY FILESYSTEM SCAN
        // =========================================================

        stage('Trivy Filesystem Scan') {
            steps {

                sh '''
                    set -e

                    echo "========================================"
                    echo "Running Trivy Filesystem Scan"
                    echo "========================================"

                    docker run --rm \
                        -v /home/heymanshu/shopsphere:/workspace \
                        aquasec/trivy:0.72.0 \
                        fs \
                        --scanners vuln,secret,misconfig \
                        --severity HIGH,CRITICAL \
                        --skip-dirs /workspace/
                        --exit-code 1 \
                        /workspace
                '''
            }
        }
        
        // =========================================================
        // SONARQUBE
        // =========================================================

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonarqube') {

                    sh '''
                        echo "========================================"
                        echo "Running SonarQube analysis"
                        echo "========================================"

                        sonar-scanner \
                          -Dsonar.projectKey=shopsphere \
                          -Dsonar.sources=services \
                          -Dsonar.exclusions="**/venv/**,**/__pycache__/**"
                    '''
                }
            }
        }


        // =========================================================
        // QUALITY GATE
        // =========================================================

        stage('Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }


        // =========================================================
        // DOCKER BUILD
        // =========================================================

        stage('Docker Build') {
            steps {

                sh '''
                    set -e

                    echo "========================================"
                    echo "Building Docker Images"
                    echo "========================================"

                    echo "Build Number: ${BUILD_NUMBER}"
                    echo "Image Tag: ${IMAGE_TAG}"

                    docker build \
                        -t ${ECR_REGISTRY}/shopsphere-user-service:${IMAGE_TAG} \
                        services/user-service

                    docker build \
                        -t ${ECR_REGISTRY}/shopsphere-product-service:${IMAGE_TAG} \
                        services/product-service

                    docker build \
                        -t ${ECR_REGISTRY}/shopsphere-order-service:${IMAGE_TAG} \
                        services/order-service

                    docker build \
                        -t ${ECR_REGISTRY}/shopsphere-payment-service:${IMAGE_TAG} \
                        services/payment-service

                    docker build \
                        -t ${ECR_REGISTRY}/shopsphere-notification-service:${IMAGE_TAG} \
                        services/notification-service
                '''
            }
        }


        // =========================================================
        // TRIVY IMAGE SCAN
        // =========================================================

        stage('Trivy Image Scan') {
            steps {

                sh '''
                    set -e

                    echo "========================================"
                    echo "Running Trivy Image Scan"
                    echo "========================================"

                    for image in \
                        ${ECR_REGISTRY}/shopsphere-user-service:${IMAGE_TAG} \
                        ${ECR_REGISTRY}/shopsphere-product-service:${IMAGE_TAG} \
                        ${ECR_REGISTRY}/shopsphere-order-service:${IMAGE_TAG} \
                        ${ECR_REGISTRY}/shopsphere-payment-service:${IMAGE_TAG} \
                        ${ECR_REGISTRY}/shopsphere-notification-service:${IMAGE_TAG}
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


        // =========================================================
        // ECR LOGIN
        // =========================================================

        stage('Login to ECR') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'shopsphere-aws',
                        usernameVariable: 'AWS_ACCESS_KEY_ID',
                        passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                    )
                ]) {
                    sh '''
                        set -e
        
                        echo "========================================"
                        echo "Logging into Amazon ECR"
                        echo "========================================"
        
                        aws sts get-caller-identity
        
                        aws ecr get-login-password \
                            --region ${AWS_REGION} | \
                        docker login \
                            --username AWS \
                            --password-stdin \
                            ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
        
                        echo "ECR login successful"
                    '''
                }
            }
        }


        // =========================================================
        // PUSH IMAGES TO ECR
        // =========================================================

        stage('Docker Push') {
            steps {

                sh '''
                    set -e

                    echo "========================================"
                    echo "Pushing Images to ECR"
                    echo "========================================"

                    docker push \
                        ${ECR_REGISTRY}/shopsphere-user-service:${IMAGE_TAG}

                    docker push \
                        ${ECR_REGISTRY}/shopsphere-product-service:${IMAGE_TAG}

                    docker push \
                        ${ECR_REGISTRY}/shopsphere-order-service:${IMAGE_TAG}

                    docker push \
                        ${ECR_REGISTRY}/shopsphere-payment-service:${IMAGE_TAG}

                    docker push \
                        ${ECR_REGISTRY}/shopsphere-notification-service:${IMAGE_TAG}
                '''
            }
        }


        // =========================================================
        // SHOW IMAGES
        // =========================================================

        stage('Images') {
            steps {

                sh '''
                    echo "========================================"
                    echo "ShopSphere Docker Images"
                    echo "========================================"

                    docker images | grep shopsphere || true
                '''
            }
        }

        stage('Update Helm Image Tags') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'github-shopsphere',
                        usernameVariable: 'GIT_USERNAME',
                        passwordVariable: 'GIT_TOKEN'
                    )
                ]) {
                    sh '''
                        set -e
        
                        echo "========================================"
                        echo "Updating Helm Image Tags"
                        echo "========================================"
        
                        VALUES_FILE="helm/shopsphere/values-dev.yaml"
        
                        echo "Updating all services to image tag: ${IMAGE_TAG}"
        
                        sed -i "s/tag: \\"[0-9]*\\"/tag: \\"${IMAGE_TAG}\\"/g" "$VALUES_FILE"
        
                        echo ""
                        echo "Updated Helm values:"
                        cat "$VALUES_FILE"
        
                        echo ""
                        echo "Git diff:"
                        git --no-pager diff -- "$VALUES_FILE"
        
                        git config user.name "jenkins"
                        git config user.email "jenkins@shopsphere.local"
        
                        git add "$VALUES_FILE"
        
                        git commit -m "Update ShopSphere image tags to ${IMAGE_TAG}" || {
                            echo "No Helm image tag changes to commit"
                            exit 0
                        }
        
                        git push \
                            https://${GIT_USERNAME}:${GIT_TOKEN}@github.com/heymanshu13/shopsphere_project.git \
                            HEAD:main
        
                        echo "Helm image tags pushed to GitHub"
                    '''
                }
            }
        }

        // =========================================================
        // CLEANUP LOCAL DOCKER IMAGES
        // =========================================================

        stage('Cleanup Old ShopSphere Images') {
            steps {

                sh '''
                    set -e

                    echo "========================================"
                    echo "Cleaning old local ShopSphere images"
                    echo "========================================"

                    for service in \
                        shopsphere-user-service \
                        shopsphere-product-service \
                        shopsphere-order-service \
                        shopsphere-payment-service \
                        shopsphere-notification-service
                    do

                        echo ""
                        echo "Cleaning old images for: $service"

                        docker images \
                            "${ECR_REGISTRY}/${service}" \
                            --format "{{.Repository}}:{{.Tag}}" \
                            | grep -v ":${IMAGE_TAG}$" \
                            | xargs -r docker rmi || true

                    done

                    echo ""
                    echo "========================================"
                    echo "Remaining ShopSphere Images"
                    echo "========================================"

                    docker images | grep shopsphere || true
                '''
            }
        }
    }


    // =============================================================
    // POST ACTIONS
    // =============================================================

    post {

        success {
            echo """
            ========================================
            ShopSphere CI Pipeline SUCCESS
            ========================================

            Build Number : ${BUILD_NUMBER}
            Image Tag    : ${IMAGE_TAG}
            ECR Registry : ${ECR_REGISTRY}

            All services built, scanned and pushed successfully.
            ========================================
            """
        }

        failure {
            echo """
            ========================================
            ShopSphere CI Pipeline FAILED
            ========================================

            Build Number : ${BUILD_NUMBER}

            Check the failed stage and Jenkins logs.
            ========================================
            """
        }

        always {
            echo "Build completed: ${BUILD_NUMBER}"
        }
    }
}
