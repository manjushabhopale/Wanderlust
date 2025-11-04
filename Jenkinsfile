pipeline {
    agent any

    tools {
        nodejs 'NodeJS'
    }
    environment {
        //NODE_ENV = 'test'
        //MONGODB_URI = credentials('mongo-uri')
        //REDIS_URL   = credentials('redis-uri')
        //BACKEND_API_PATH = credentials('backend-api')
        //FRONTEND_API_PATH = credentials('frontend-api')
        AWS_ACCOUNT_ID = credentials('aws-account-id')
        REGION = 'ap-south-1'
        BACKEND_TAG = "backend-${BUILD_NUMBER}"
        FRONTEND_TAG = "frontend-${BUILD_NUMBER}"
        SONAR_TOKEN = credentials('sonar-scan-token')
        SONARQUBE = 'SonarCloud'
    }

    stages {
        stage('Git Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/manjushabhopale/Wanderlust.git'
            }
        }
        stage('Install Dependencies') {
            steps {
                dir('frontend') {
                    sh 'npm install'
                }
                dir('backend') {
                    sh 'npm install'
                }
            }
        }
        stage('Frontend Test') {
            steps {
                dir('frontend') {
                    sh 'npm install'
                    sh 'npm test -- --testPathIgnorePatterns=home.test.tsx --coverage'
                }
            }
        }
        stage('Backend Test') {
            steps {
                dir('backend') {
                    sh 'npm install'
                    sh 'npm test -- --coverage'
                }
            }
        }
        stage('Merge Coverage Reports') {
            steps {
                sh '''
                mkdir -p merged-coverage
                npx lcov-result-merger "frontend/coverage/lcov.info" "backend/coverage/lcov.info" "merged-coverage/lcov.info"
                '''
            }
        }

        stage('SonarCloud Analysis') {
            steps {
                withSonarQubeEnv("${SONARQUBE}") {
                    withCredentials([string(credentialsId: 'sonar-scan-token', variable: 'SONAR_TOKEN')]) {
                        sh """
                        ${tool name: 'SonarCloud', type: 'hudson.plugins.sonar.SonarRunnerInstallation'}/bin/sonar-scanner \
                          -Dsonar.organization=manjushabhopale \
                          -Dsonar.projectKey=manjushabhopale_wanderlust \
                          -Dsonar.sources=frontend/src,backend \
                          -Dsonar.javascript.lcov.reportPaths=frontend/coverage/lcov.info,backend/coverage/lcov.info \
                          -Dsonar.host.url=https://sonarcloud.io \
                          -Dsonar.login=$SONAR_TOKEN
                        """
                    }
                }
            }
        }

        stage('Exporting environment variables') {
            parallel{
                stage("Backend env setup"){
                    steps {
                        script{
                            dir("Automations"){
                                sh "bash updatebackendnew.sh"
                            }
                        }
                    }
                }
                
                stage("Frontend env setup"){
                    steps {
                        script{
                            dir("Automations"){
                                sh "bash updatefrontendnew.sh"
                            }
                        }
                    }
                }
            }
        }


        stage('Build Frontend Docker Image') {
            steps {
                dir('frontend') {
                    sh """
                docker build \
                 -t wanderlust-frontend .
                """
                }
            }
        }
        stage('Build  Backend Docker Image') {
            steps {
                dir('backend') {
                    sh """
                docker build  \
                //--build-arg MONGODB_URI=${MONGODB_URI} \
                //--build-arg REDIS_URL=${REDIS_URL} \
                //--build-arg VITE_API_PATH=${BACKEND_API_PATH} \
                -t wanderlust-backend .
                """
                }
            }
        }

        stage('ECR login')
    {
            steps {
                withCredentials([[ $class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']])
          {
                    sh 'aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com'
                    echo 'login successful'
          }
            }
    }
        stage('Frontend image push')
    {
            steps {
                sh '''
            docker tag wanderlust-frontend:latest ${AWS_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/wanderlust-frontend:${FRONTEND_TAG}
            docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/wanderlust-frontend:${FRONTEND_TAG}
            '''
            }
    }
        stage('Backend image push')
    {
            steps {
                sh '''
            docker tag wanderlust-backend:latest ${AWS_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/wanderlust-backend:${BACKEND_TAG}
            docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/wanderlust-backend:${BACKEND_TAG}
            '''
            }
    }
    stage('K8S - Update Image Tag') {
            steps {
                withCredentials([string(credentialsId: 'github-token', variable: 'GIT_TOKEN')]) {
                 sh 'rm -rf Wanderlust-K8s'
                sh 'git clone -b main https://github.com/manjushabhopale/Wanderlust-K8s.git'
                dir("Wanderlust-K8s") {
                    sh '''
                        #### Replace Docker Tag ####
                        git checkout main
                        sed -i "s#wanderlust-backend.*#wanderlust-backend:${BACKEND_TAG}#g" backend-deployment.yml
                        cat backend-deployment.yml
                        
                        #### Commit and Push to Feature Branch ####
                        git config --global user.email "manjushabhopale95.com"
                        git remote set-url origin https://${GIT_TOKEN}@github.com/manjushabhopale/Wanderlust-K8s.git
                        git add .
                        git commit -am "Updated docker image"
                        git push -u origin main
                    '''
                }
                dir("Wanderlust-K8s") {
                    sh '''
                        #### Replace Docker Tag ####
                        git checkout main
                        sed -i "s#wanderlust-frontend.*#wanderlust-frontend:${FRONTEND_TAG}#g" frontend-deployment.yml
                        cat frontend-deployment.yml
                        
                        #### Commit and Push to Feature Branch ####
                        git config --global user.email "manjushabhopale95.com"
                        git remote set-url origin https://${GIT_TOKEN}@github.com/manjushabhopale/Wanderlust-K8s.git
                        git add .
                        git commit -am "Updated docker image"
                        git push -u origin main
                    '''
                }


                }
            }
        }

    }
    post {
        always {
            sh 'docker system prune -f'  // Clean up local space
        }
    }
}
