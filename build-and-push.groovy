#!groovy

def buildAndPush() {
    deleteDir()
    checkout(scm)

    withCredentials([[
                             $class: 'UsernamePasswordMultiBinding',
                             usernameVariable: 'REGISTRY_USERNAME',
                             passwordVariable: 'REGISTRY_PASSWORD',
                             credentialsId: 'orcaeng-hub.docker.com',
                     ], [
                             $class: 'UsernamePasswordMultiBinding',
                             usernameVariable: 'GITHUB_USERNAME',
                             passwordVariable: 'GITHUB_AUTH_TOKEN',
                             credentialsId: 'docker-jenkins.private.token.github.com',
                     ], [
                             $class: 'UsernamePasswordMultiBinding',
                             usernameVariable: 'JENKINS_USER',
                             passwordVariable: 'JENKINS_PASS',
                             credentialsId: 'job-reader_ci.qa.aws.dckr.io',
                     ]]) {

        sh("env")
        stage("Build and push") {
            sh("make build && make push")
        }
    }
}

parallel(
    linux: {wrappedNode(label: 'docker-edge && ubuntu') {
        buildAndPush()
    }},

    s390xlinux: { wrappedNode(label: 's390x-ubuntu-1604') {
        buildAndPush()
    }}
)
