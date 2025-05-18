pipeline {
    agent { label 'vm4' }

    environment {
        DOCKERHUB_CREDENTIALS = 'dockerhub-creds'
        IMAGE_NAME = 'uncledhafer/usb-check:latest'
        KUBECONFIG_PATH = '/opt/jenkins/agent/.kube/config'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/Dhafer84/usb-check.git',
                    credentialsId: 'github-creds'
            }
        }

        stage('Build Image') {
            steps {
                sh 'docker build -t $IMAGE_NAME .'
            }
        }

        stage('Push to DockerHub') {
            steps {
                withDockerRegistry([credentialsId: "${DOCKERHUB_CREDENTIALS}", url: '']) {
                    sh 'docker push $IMAGE_NAME'
                }
            }
        }

        stage('Deploy on K3s') {
            steps {
                sh '''
                    kubectl --insecure-skip-tls-verify=true --kubeconfig=$KUBECONFIG_PATH delete job usb-check --ignore-not-found=true
                    kubectl --insecure-skip-tls-verify=true --kubeconfig=$KUBECONFIG_PATH apply -f usb-check-job.yaml

                '''
            }
        }

        stage('Logs Check') {
            steps {
                script {
                    sh '''
                        echo "⏳ Attente 10s pour que le pod démarre..."
                        sleep 10
                        POD=$(kubectl --kubeconfig=$KUBECONFIG_PATH get pods -l job-name=usb-check -o jsonpath='{.items[0].metadata.name}')
                        echo "🔍 Affichage des logs du pod : $POD"
                        kubectl --kubeconfig=$KUBECONFIG_PATH logs $POD || true
                    '''
                }
            }
        }
    }
}
