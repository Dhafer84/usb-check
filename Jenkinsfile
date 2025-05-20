pipeline {
    agent { label 'vm4' }

    environment {
        DOCKERHUB_CREDENTIALS = 'dockerhub-creds'
        IMAGE_NAME = 'uncledhafer/usb-check:latest'
        KUBECONFIG_PATH = '/opt/jenkins/agent/.kube/config'
    }

    stages {
        stage('Init') {
            steps {
                script {
                    currentBuild.displayName = "#${BUILD_NUMBER} - USB Check"
                }
            }
        }    
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
                    echo "🗑️ Suppression ancienne Job"
                    KUBECONFIG=$KUBECONFIG_PATH kubectl --insecure-skip-tls-verify=true delete job usb-check --ignore-not-found=true

                    echo "🚀 Déploiement nouveau Job"
                    KUBECONFIG=$KUBECONFIG_PATH kubectl --insecure-skip-tls-verify=true apply -f usb-check-job.yaml
                '''
            }
        }

        stage('Logs Check') {
            steps {
                sh '''
                    echo "⏳ Attente 10s pour que le pod démarre..."
                    sleep 10
                    POD=$(KUBECONFIG=$KUBECONFIG_PATH kubectl --insecure-skip-tls-verify=true get pods -l job-name=usb-check -o jsonpath='{.items[0].metadata.name}')
                    echo "🔍 Affichage des logs du pod : $POD"
                    KUBECONFIG=$KUBECONFIG_PATH kubectl --insecure-skip-tls-verify=true logs $POD || true
                '''
            }
        }

        stage('Surveillance USB en direct') {
            steps {
                sh '''
                    echo "🕵️ Surveillance en direct pendant 1 minute :"
                    POD=$(KUBECONFIG=$KUBECONFIG_PATH kubectl --insecure-skip-tls-verify=true get pods -l job-name=usb-check -o jsonpath='{.items[0].metadata.name}')

                    for i in $(seq 1 30); do
                        echo "⏱️ $(date +%H:%M:%S)"
                        KUBECONFIG=$KUBECONFIG_PATH kubectl --insecure-skip-tls-verify=true logs $POD --tail=10 || true
                        sleep 2
                    done
                '''
            }
        }
    }
}

