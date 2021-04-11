#!/bin/bash

function checkDocker() {
    docker version >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Docker not found in this machine"
        echo "Please install docker"
        exit 1
    fi

}

function checkMinikubeInstalled() {
    exit=${1:-true}
    minikube version >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Minikube not found in this machine"
        if [ $exit == true ]; then
            echo "Please run"
            echo "$0 install"
            exit 1
        else
            installMinikube
        fi
    fi
}

function installMinikube() {
    echo "Installing Minikube"
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    sudo install minikube-linux-amd64 /usr/local/bin/minikube
    rm minikube-linux-amd64
}

function uninstallMinikube() {
    echo "Removing minikube"
    minikube stop; minikube delete --all --purge
    docker stop $(docker ps -aq)
    rm -r ~/.kube ~/.minikube
    sudo rm /usr/local/bin/localkube /usr/local/bin/minikube
    sudo systemctl stop '*kubelet*.mount'
    sudo rm -rf /etc/kubernetes/
    docker system prune -af --volumes
}

function checkMinikubeSarted() {

    minikube status >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Starting minikube"
        minikube start --memory=2048 --cpus=2 --ports=3000:3000 --ports=80:80 --ports=8081:8081
    fi
}

function checkFluxCTL() {

    fluxctl version >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Installing fluxctl"
        sudo curl -L "https://github.com/fluxcd/flux/releases/download/1.22.1/fluxctl_linux_amd64" -o /usr/local/bin/fluxctl
        sudo chmod +x /usr/local/bin/fluxctl
    fi
}

function installFlux(){
    fluxctl install \
    --git-user=ssadok \
    --git-email=ssadok@gmail.com \
    --git-url=git@github.com:ssadok/fluxcd.git \
    --git-path=kubernetes/mongodb,kubernetes/services,kubernetes/deployments \
    --git-branch=main \
    --namespace=flux | kubectl apply -f -
}

if [ "$1" == "remove" ]; then
    uninstallMinikube
    rm -rf /usr/local/bin/fluxctl
elif [ "$1" == "install" ]; then
    checkDocker
    checkMinikubeInstalled false
elif [ "$1" == "flux" ]; then
    checkFluxCTL
    installFlux
else
    checkDocker
    checkMinikubeInstalled
    checkMinikubeSarted
fi

