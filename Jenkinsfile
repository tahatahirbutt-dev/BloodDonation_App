// Jenkins on a Windows machine. Needs on the agent's PATH: git, flutter, java.
// A localhost Jenkins cannot receive GitHub webhooks, so it polls every 5 min.
// Optional: add a "Secret file" credential with id google-services-json to
// enable the APK build (the file is not committed to git).
pipeline {
  agent any

  options {
    timestamps()
    timeout(time: 40, unit: 'MINUTES')
    disableConcurrentBuilds()
    buildDiscarder(logRotator(numToKeepStr: '15'))
  }

  triggers {
    pollSCM('H/5 * * * *')
  }

  stages {
    stage('Pub get') {
      steps { bat 'flutter pub get' }
    }

    stage('Generate code') {
      steps { bat 'dart run build_runner build --delete-conflicting-outputs' }
    }

    stage('Analyze') {
      steps { bat 'flutter analyze' }
    }

    stage('Test') {
      steps { bat 'flutter test --coverage' }
    }

    stage('Build APK') {
      when { branch 'main' }
      steps {
        script {
          try {
            withCredentials([file(credentialsId: 'google-services-json', variable: 'GSJ')]) {
              bat 'copy /Y "%GSJ%" android\\app\\google-services.json'
              bat 'flutter build apk --release'
            }
          } catch (err) {
            echo "APK build skipped or failed: ${err.message}"
            if (!err.message.contains('google-services-json')) { throw err }
            unstable('No google-services-json credential, APK not built')
          }
        }
      }
    }
  }

  post {
    always {
      archiveArtifacts artifacts: 'build/app/outputs/flutter-apk/*.apk, coverage/lcov.info',
                       allowEmptyArchive: true, fingerprint: true
    }
  }
}
