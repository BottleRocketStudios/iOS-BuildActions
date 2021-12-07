module Fastlane
  module Actions
    class SynologyTransferAction < Action

      # Support
      def self.is_supported?(platform)
        true
      end

      # Run
      def self.run(params)
        destination_url = params[:destination_url]
        # destination_uri = URI(destination_url)
        # destination_host = destination_uri.hostname + destination_uri.path
        destination_host = destination_url

        # sh "mount | grep '#{destination_host}'" do |status, output, command|
        #   if output.empty?
        #     UI.message("Synology (#{destination_host}) is not mounted. Unable to transfer artifacts.")
        #   else
        #     UI.message("Synology (#{destination_host}) is mounted.")
            copy_artifacts(destination_host, params[:project_name], params[:export_kind], params[:identifier])
      #     end
      #   end
      end

      # Helper

      def self.copy_artifacts(root_url, project_name, identifier)
        # artifact_url = File.join(root_url, project_name, export_kind == "build" ? "ios-builds" : "ios-tests", identifier)


        # Attempt to copy build artifacts to the destination URL
        ipa_path = ".build/*.ipa"
        dsym_path = ".build/*.zip"

        if File.exist?(ipa_path)
          build_artifacts_url = File.join(root_url, project_name, "ios-builds", identifier)
          sh("mkdir -p #{artifact_url}")

          sh("cp #{ipa_path} #{build_artifacts_url} || true")

          if File.exist?(dsym_path)
            sh("cp #{dsym_path} #{build_artifacts_url} || true")
          end
        end

        # if include_test_results
        #   # Attempt to copy any test artifacts to the destination URL
        #   sh("zip -r fastlane/test_output/TestResults.zip fastlane/test_output || true")
        #   sh("cp fastlane/test_output/TestResults.zip #{artifact_url} || true")
        # end
      end

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
