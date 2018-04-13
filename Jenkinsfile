#!groovy

def channel = '#devops-builds'

properties(
  [[$class: 'GithubProjectProperty', projectUrlStr: 'http://github.com/hmcts/terraform-module-vm-managed-disk/'],
   pipelineTriggers([[$class: 'GitHubPushTrigger']])]
)

@Library('Reform') _

        def env = "sandbox"
        def product = "sandbox"

        def secrets = [
            // The following entry is required for the backend
            [$class: 'VaultSecret', path: 'secret/devops/azure_subsription_ids', secretValues:
                [[$class: 'VaultSecretValue', envVar: 'ARM_SUBSCRIPTION_ID', vaultKey: "${env}"]]
            ],
            // The following entries are required for variables interpolation
            [$class: 'VaultSecret', path: 'secret/devops/azure_subsription_ids', secretValues:
                [[$class: 'VaultSecretValue', envVar: 'TF_VAR_subscription_id', vaultKey: "${env}"]]
            ],
            [$class: 'VaultSecret', path: 'secret/devops/public_key', secretValues:
                [[$class: 'VaultSecretValue', envVar: 'TF_VAR_ssh_pubkey', vaultKey: 'value']]
            ],
            [$class: 'VaultSecret', path: 'secret/devops/ssh-port', secretValues:
                [[$class: 'VaultSecretValue', envVar: 'TF_VAR_port', vaultKey: 'value']]
            ],
            [$class: 'VaultSecret', path: 'secret/devops/vm-username', secretValues:
                [[$class: 'VaultSecretValue', envVar: 'TF_VAR_admin_username', vaultKey: 'value']]
        ]
    ]

node {
  ws("${WORKSPACE}") {
    try {
      wrap([$class: 'AnsiColorBuildWrapper', colorMapName: 'xterm']) {

        stage('Checkout') {
          checkout scm
        }

        stage('Run terraform fmt') {
            dir ("${WORKSPACE}/module") {
                def fmtExitCode = sh(returnStatus: true, script: """terraform fmt -check=true""")
                echo("Terraform fmt exit status was ${fmtExitCode}")
                if (fmtExitCode != 0) {
                    notifyBuildResult channel: "${channel}", color: 'danger', message: "Terraform fmt failed"
                    currentBuild.result = 'FAILURE'
                    error("'terraform fmt' failed")
                }
            }
        }

        withCredentials([
            [$class: 'StringBinding', credentialsId: 'IDAM_ARM_CLIENT_SECRET', variable: 'ARM_CLIENT_SECRET'],
            [$class: 'StringBinding', credentialsId: 'IDAM_ARM_CLIENT_ID', variable: 'ARM_CLIENT_ID'],
            [$class: 'StringBinding', credentialsId: 'IDAM_ARM_TENANT_ID', variable: 'ARM_TENANT_ID'],
            [$class: 'StringBinding', credentialsId: 'IDAM_ARM_SUBSCRIPTION_ID', variable: 'ARM_SUBSCRIPTION_ID']
        ]) {

            dir ("${WORKSPACE}/tests") {
                def planfile = "sandbox.plan"
                def planExitCode = -1
                def applyExitCode = -1
                def destroyExitCode = -1

                stage(name: 'TF Plan') {
                    planExitCode = sh(returnStatus: true, script: """
                      echo "Workspace=${WORKSPACE}"
                      echo "Curdir=\$(pwd)"
                      terraform version
                      terraform init
                      terraform plan -out=${planfile} -detailed-exitcode
                    """)
                    echo("Terraform plan exit status was ${planExitCode}")

                    if (planExitCode == 0) {
                        // Nothing to do - the infrastructure is up to date.
                        currentBuild.result = 'SUCCESS'
                    } else if (planExitCode == 1) {
                        // There was some sort of problem working out the plan.
                        notifyBuildResult channel: "${channel}", color: 'danger', message: "Plan Failed"
                        currentBuild.result = 'FAILURE'
                        error("'terraform plan' failed")
                    }
                }

                stage(name: 'TF Apply') {
                    if (planExitCode == 2) {
                        def apply = false
                        timeout(time: 60, unit: 'SECONDS') {
                            try {
                                input 'Apply Plan ?'
                                apply = true
                            } catch (err) {
                                notifyBuildResult channel: "${channel}", color: 'warning', message: "Apply Discarded"
                                apply = false
                                currentBuild.result = 'UNSTABLE'
                                error("'terraform apply' discarded")
                            }
                        }

                        if (apply) {
                            applyExitCode = sh(returnStatus: true, script: "terraform apply ${planfile}")
                            if (applyExitCode == 0) {
                                notifyBuildResult channel: "${channel}", color: 'good', message: "Changes Applied"
                            } else {
                                notifyBuildResult channel: "${channel}", color: 'danger', message: "Apply Failed"
                                currentBuild.result = 'FAILURE'
                                error("'terraform apply' failed")
                            }
                        }
                    }
                }

                stage(name: 'TF Destroy') {
                    def destroy = false
                    timeout(time: 60, unit: 'SECONDS') {
                        try {
                          input 'Destroy resources ?'
                          destroy = true
                        } catch (err) {
                          destroy = false
                        }
                    }

                    if (destroy) {
                        destroyExitCode = sh(returnStatus: true, script: "terraform destroy -force")
                        if (destroyExitCode == 0) {
                            notifyBuildResult channel: "${channel}", color: 'good', message: "Destruction successful"
                        } else {
                            notifyBuildResult channel: "${channel}", color: 'danger', message: "Destruction Failed"
                            currentBuild.result = 'FAILURE'
                            error("'terraform destroy' failed")
                        }
                    }
                }
            }
         }
      }

    } catch (err) {
      notifyBuildFailure channel: "${channel}"
      throw err
    } finally {
        deleteDir()
      }
    }
}
