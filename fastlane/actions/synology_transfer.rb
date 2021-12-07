require "fileutils"

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

        sh "mount | grep '#{destination_url}'" do |status, output, command|
          if output.empty?
            UI.message("Synology (#{destination_url}) is not mounted. Unable to transfer artifacts.")
          else
            UI.message("Synology (#{destination_url}) is mounted.")
            copy_build_artifacts(destination_url, params[:project_name], params[:identifier], params[:build_output_directory])
            copy_test_artifacts(destination_url, params[:project_name], params[:identifier], params[:test_output_directory])
          end
        end
      end


      # Helper

      def self.copy_build_artifacts(root_url, project_name, identifier, build_output_directory)
        ipa_path = ".build/*.ipa"
        dsym_path = ".build/*.zip"

        if !Dir.glob(ipa_path).empty?
          build_artifacts_url = File.join(root_url, project_name, "ios-builds", identifier)
          FileUtils.mkdir_p "#{build_artifacts_url}"

          # If any .ipa are present, copy to the destination
          sh("cp #{ipa_path} #{build_artifacts_url}")

          if !Dir.glob(dsym_path).empty?
            # If any .dsym are present, copy to the destination
            sh("cp #{dsym_path} #{build_artifacts_url}")
          end
        end
      end

      def self.copy_test_artifacts(root_url, project_name, identifier, test_output_directory)
        if !Dir.empty?(test_output_directory)
          # If any test results are present, zip them up and copy to the destination

          test_artifacts_url = File.join(root_url, project_name, "ios-tests", identifier)
          FileUtils.mkdir_p "#{test_artifacts_url}"

          sh("zip -r #{test_output_directory}/Results.zip #{test_output_directory}")
          FileUtils.cp("#{test_output_directory}/Results.zip", test_artifacts_url)
          File.delete("#{test_output_directory}/Results.zip")
        end
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
          ),
          FastlaneCore::ConfigItem.new(
            key: :build_output_directory,
            description: "The directory in which the build artifacts are stored in",
            type: String,
            default_value: ".build"
          ),
          FastlaneCore::ConfigItem.new(
            key: :test_output_directory,
            description: "The directory in which the test artifacts are stored in",
            type: String,
            default_value: "fastlane/test_output"
          ),
        ]
      end
    end
  end
end
