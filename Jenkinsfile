pipeline {
    agent { label 'centos7-docker-4c-2g' }
    options {
        timestamps()
        disableConcurrentBuilds()
        preserveStashes()
        quietPeriod(5) // wait a few seconds before starting to aggregate multiple commits into a single build
        durabilityHint 'PERFORMANCE_OPTIMIZED'
    }
    triggers {
        issueCommentTrigger('.*^recheck$.*')
    }
    stages {
        stage('Build Docs') {
            agent {
                docker { 
                    image 'python:3-slim' 
                    reuseNode true
                    args '-u 0:0 --privileged'
                }
            }
            steps {
                sh 'pip install mkdocs'
                sh 'pip install mkdocs-material==5.1.0'
                sh 'mkdocs build'

                // stash the site contents generated from mkdocs build
                stash name: 'site-contents', includes: 'docs/**', useDefaultExcludes: false
            }
        }

        // back onto the main centos agent (not in docker container)
        stage('Push Changes') {
            when { expression { edgex.isReleaseStream() } }
            steps {
                script {
                    def originalCommitMsg = sh(script: 'git log --format=%B -n 1 | grep -v Signed-off-by | head -n 1', returnStdout: true)

                    // cleanup workspace
                    cleanWs()

                    dir('edgex-docs-clean') {
                        git url: 'git@github.com:edgexfoundry/edgex-docs.git', branch: 'gh-pages', credentialsId: 'edgex-jenkins-ssh', changelog: false, poll: false
                        unstash 'site-contents'

                        sh 'cp -rlf docs/* .'
                        sh 'rm -rf docs'

                        def changesDetected = sh(script: 'git diff-index --quiet HEAD --', returnStatus: true)
                        echo "We have detected there are changes to commit: [${changesDetected}] [${changesDetected != 0}]"

                        if(changesDetected != 0) {
                            sh 'git config --global user.email "jenkins@edgexfoundry.org"'
                            sh 'git config --global user.name "EdgeX Jenkins"'
                            sh 'git add .'

                            sh "git commit -s -m 'ci: ${originalCommitMsg}'"

                            sshagent (credentials: ['edgex-jenkins-ssh']) {
                                sh 'git push origin gh-pages'
                            }
                        }
                    }
                }
            }
        }
    }

    post {
        always {
            edgeXInfraPublish()
        }
        cleanup {
            cleanWs()
        }
    }
}