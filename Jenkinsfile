pipeline {
  agent {
    label 'bat-builder'
  }

  parameters {
    string (defaultValue: '4.1.5', description: 'This is the Mule Version to be specified', name: 'MULE_VERSION', trim: false)
  }

  environment {
    DEPLOY_CREDS = credentials('deploy-anypoint-user')
    MULE_VERSION = "${params.MULE_VERSION}"
    BG = "Manufacturing"
    WORKER = "Small"
    DB_JDBC = credentials("$BRANCH_NAME-jdbc-url")
  }
  stages {
    stage('Prepare') {
      steps {
        configFileProvider([configFile(fileId: "${BRANCH_NAME}-sys-product-api-for-mysql.yaml", replaceTokens: true, targetLocation: './src/main/resources/config/configuration.yaml')]) {
          withCredentials([file(credentialsId: 'self-signed-keystore.jks', variable: 'KEYSTORE_FILE')]){
            sh 'echo "Branch NAME: $BRANCH_NAME"'
            sh 'cp $KEYSTORE_FILE ./src/main/resources/keystore.jks'
          }
        }
      }
    }

    stage('Build') {
      steps {
        withMaven(
          mavenSettingsConfig: 'f007350a-b1d5-44a8-9757-07c22cd2a360'){
            sh 'mvn -B clean package -DskipTests'
        }
      }
    }

    stage('Test') {
      steps {
        withMaven(
          mavenSettingsConfig: 'f007350a-b1d5-44a8-9757-07c22cd2a360'){
            sh 'mvn -B test -Ddb.className=org.h2.Driver -Ddb.url=jdbc:h2:mem:1platform'
        }
      }

      post {
        always {
          publishHTML (target: [
            allowMissing: false,
            alwaysLinkToLastBuild: false,
            keepAll: true,
            reportDir: 'target/site/munit/coverage',
            reportFiles: 'summary.html',
            reportName: "Code coverage"
          ])
        }
      }
    }

    stage('Deploy Development') {
      when {
        branch 'develop'
      }
      environment {
        ENVIRONMENT = 'Development'
        ANYPOINT_ENV = credentials('DEV_ANYPOINT_MANUFACTURING')
        APP_NAME = 'dev-nto-product-api-for-mysql-v1'
      }
      steps {
        sh 'mvn -V -B -DskipTests deploy -DmuleDeploy -Dmule.version=$MULE_VERSION -Danypoint.username=$DEPLOY_CREDS_USR -Danypoint.password=$DEPLOY_CREDS_PSW -Dcloudhub.app=$APP_NAME -Dcloudhub.environment=$ENVIRONMENT -Denv.ANYPOINT_CLIENT_ID=$ANYPOINT_ENV_USR -Denv.ANYPOINT_CLIENT_SECRET=$ANYPOINT_ENV_PSW -Dcloudhub.bg=$BG -Dcloudhub.worker=$WORKER -Ddb.url=$DB_JDBC'
      }
    }
    stage('Deploy Production') {
        when {
          branch 'master'
        }
        environment {
          ENVIRONMENT = 'Production'
          ANYPOINT_ENV = credentials('PRD_ANYPOINT_MANUFACTURING')
          APP_NAME = 'nto-product-api-for-mysql-v1'
        }
        steps {
          sh 'mvn -V -B -DskipTests deploy -DmuleDeploy -Dmule.version=$MULE_VERSION -Danypoint.username=$DEPLOY_CREDS_USR -Danypoint.password=$DEPLOY_CREDS_PSW -Dcloudhub.app=$APP_NAME -Dcloudhub.environment=$ENVIRONMENT -Denv.ANYPOINT_CLIENT_ID=$ANYPOINT_ENV_USR -Denv.ANYPOINT_CLIENT_SECRET=$ANYPOINT_ENV_PSW -Dcloudhub.bg=$BG -Dcloudhub.worker=$WORKER -Ddb.url=$DB_JDBC'
        }
    }
    stage('Integration Test') {
      steps {
      	sh 'bat integration-scripts --config=devx'
      }
      post {
        always {
          publishHTML (target: [
            allowMissing: false,
            alwaysLinkToLastBuild: true,
            keepAll: true,
            reportDir: '/tmp',
            reportFiles: 'HTML.html',
            reportName: "Integration Test",
            includes: "**/index.html"
          ])
        }
      }
    }
  }

  post {
      always {
        step([$class: 'hudson.plugins.chucknorris.CordellWalkerRecorder'])
      }
  }

  tools {
    maven 'M3'
  }
}
