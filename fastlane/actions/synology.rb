module Fastlane
  module Actions
    class SynologyAction < Action

      # Support
      def self.is_supported?(platform)
        true
      end

      # Run
      def self.run(params)
        destination_url = params[:destination_url]
        destination_uri = URI(destination_url)
        destination_host = destination_uri.hostname + destination_uri.path

        sh "mount | grep '#{destination_host}'" do |status, output, command|
          if output.empty?
            UI.message("Synology (#{destination_host}) is not mounted. Unable to transfer artifacts.")
          else
            UI.message("Synology (#{destination_host}) is mounted.")
            copy_artifacts(destination_host, params[:project_name], params[:export_kind], params[:identifier])
          end
        end
      end

      # Helper

      def self.copy_artifacts(root_url, project_name, export_kind, identifier)
        artifact_url = File.join(root_url, project_name, export_kind == "build" ? "ios-builds" : "ios-tests", identifier)
        UI.message(artifact_url)
        sh("mkdir -p #{artifact_url}")

        # if export_kind == "build"
        #   sh("cp .build/*.ipa #{artifact_url} || true")
        #   sh("cp .build/*.zip #{artifact_url} || true")
        # else
        #   sh("zip -r fastlane/test_output/TestResults.zip fastlane/test_output || true")
        #   sh("cp fastlane/test_output/TestResults.zip #{artifact_url} || true")
        # end
      end

        # //     String FILE_SERVER_PROJECT_URL = "smb://files.bottlerocketstudios.com/Builds/${env.SYNOLOGY_PROJECT_NAME}/ios-builds/"
        #   //     String FILE_SERVER_BUILD_URL = "${FILE_SERVER_PROJECT_URL}${BUILD_NUMBER}"
        #   //     String DECODED_JOB_NAME = URLDecoder.decode("${env.JOB_NAME}", 'UTF-8')
        #   //     String SLACK_MESSAGE = "${DECODED_JOB_NAME} - #${env.BUILD_NUMBER}\nSuccess. Duration: ${currentBuild.durationString} (<${env.BUILD_URL}|Jenkins> | <$FILE_SERVER_BUILD_URL|Artifact> | <$FILE_SERVER_PROJECT_URL|Project>)."
        #   //     sendSlackWithLogging(SLACK_MESSAGE, 'good')

        # sh """
        # if mount | grep 'files.bottlerocketstudios.com/Builds' >/dev/null 2>&1; then
        #   echo "Synology is mounted. Copying test results to Synology"
        #   mkdir -p ${SYNOLOGY_PATH}
        #   zip -r fastlane/test_output/TestResults.zip fastlane/test_output
        #   cp fastlane/test_output/TestResults.zip ${SYNOLOGY_PATH}
        # else
        #   echo "Synology is not mounted. Unable to copy test results to Synology."
        # fi
        # """

        # sh """
        # if mount | grep 'files.bottlerocketstudios.com/Builds' >/dev/null 2>&1; then
        #   echo "Synology is mounted. Copying builds to Synology"
        #   mkdir -p ${SYNOLOGY_PATH}
        #   cp .build/*.ipa ${SYNOLOGY_PATH}
        #   cp .build/*.zip ${SYNOLOGY_PATH}
        # else
        #   echo "Synology is not mounted. Unable to copy builds to Synology."
        # fi
        # """

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Transfers build artifacts to Synology for long term storage"
      end

      def self.authors
        ["Will McGinty - @wmcginty on GitHub"]
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :destination_url,
            description: "The root directory in Synology from which all artifacts will be placed",
            type: String
          ),
          FastlaneCore::ConfigItem.new(
            key: :project_name,
            description: "The name of the project in Synology",
            type: String
          ),
          FastlaneCore::ConfigItem.new(
            key: :export_kind,
            description: "Either 'build' or 'test'",
            type: String,
            default_value: "build"
          ),
          FastlaneCore::ConfigItem.new(
            key: :identifier,
            description: "Any additional identifiers needed for the current set of artifacts (ex: build number or branch)",
            type: String,
            default_value: ""
          )
        ]
      end
    end
  end
end
