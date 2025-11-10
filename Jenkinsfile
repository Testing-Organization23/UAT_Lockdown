pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        ECR_REPO  = '302263069749.dkr.ecr.us-east-1.amazonaws.com/east-post'
        CLUSTER   = 'uat-eks-cluster'
        K8S_MANIFEST = 'k8s/post.yaml'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'release/uat_11thNov', 
                    credentialsId: 'github-creds',
                    url: 'https://github.com/Testing-Organization23/UAT_Lockdown.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    def imageTag = "${ECR_REPO}:${env.BUILD_NUMBER}"
                    sh """
                        cd post-service
                        docker build -t ${imageTag} .
                        aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REPO}
                        docker push ${imageTag}
                    """
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                script {
                    sh """
                        aws eks update-kubeconfig --name ${CLUSTER} --region ${AWS_REGION}
                        kubectl apply -f ${K8S_MANIFEST}
                    """
                }
            }
        }
    }

    post {
        success {
            echo "Deployment to UAT cluster succeeded!"
        }
        failure {
            echo "Deployment failed. Check logs for details."
        }
    }
}
