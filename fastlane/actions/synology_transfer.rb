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
          if output.empty? && params[:verify_mounted]
            UI.message("Synology (#{destination_url}) is not mounted. Unable to transfer artifacts.")
          else
            copy_build_artifacts(params[:build_output_types], params[:build_output_directory], destination_url, params[:project_name], params[:identifier])
            copy_test_artifacts(params[:test_output_directory], destination_url, params[:project_name], params[:identifier], params[:test_artifact_name])
          end
        end
      end


      # Helper

      # Searches for all desired build artifacts present in the output directory, before copying them to the appropriate destination in Synology
      def self.copy_build_artifacts(build_output_types, build_output_directory, destination_url, project_name, identifier)
        build_output_types.each do |ext|
          source = File.join(build_output_directory, "*.#{ext}")
          if !Dir.glob(source).empty?

            # If any are present, create the root directory for output and copy them to the destination
            build_artifacts_url = File.join(destination_url, project_name, "ios-builds", identifier)
            FileUtils.mkdir_p(build_artifacts_url)
            copy_all_matching(source, build_artifacts_url)
          end
        end
      end

      # Searches for any test results in the output directory, before zipping and copying them to the appropriate destination in Synology
      def self.copy_test_artifacts(test_output_directory, destination_url, project_name, identifier, test_artifact_name)
        if !Dir.empty?(test_output_directory)

          # If any test results are present, create the root directory for output, zip them up and copy to the destination
          test_artifacts_url = File.join(destination_url, project_name, "ios-tests", identifier)
          FileUtils.mkdir_p(test_artifacts_url)

          archive_path = File.join(test_output_directory, "#{test_artifact_name}.zip")
          sh("zip -r #{archive_path} #{test_output_directory}")
          FileUtils.cp(archive_path, test_artifacts_url)
          File.delete(archive_path)
        end
      end

      # Copies all files matching a wildcard path into the destination directory
      def self.copy_all_matching(source, destination_directory)
        Dir.glob(source).select { |f| File.file?(f) }.each do |file|
          destination_path = File.join(destination_directory, File.basename(file))

          FileUtils.mkdir_p(File.dirname(destination_path) )
          FileUtils.cp(file, destination_path)
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
            key: :verify_mounted,
            description: "Specify whether the action should verify that the destination URL is mounted before attempting transfer",
            default_value: true,
            type: Boolean
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
            optional: true
          ),
          FastlaneCore::ConfigItem.new(
            key: :build_output_directory,
            description: "The directory in which the build artifacts are stored in after the build process",
            type: String,
            default_value: ".build"
          ),
          FastlaneCore::ConfigItem.new(
            key: :build_output_types,
            description: "The extensions of build artifacts that should be transferred (ex: ipa, zip)",
            type: Array,
            optional: true,
            default_value: ["ipa", "zip"]
          ),
          FastlaneCore::ConfigItem.new(
            key: :test_output_directory,
            description: "The directory in which the test artifacts are stored in",
            type: String,
            default_value: "fastlane/test_output"
          ),
          FastlaneCore::ConfigItem.new(
            key: :test_artifact_name,
            description: "The name of the test output artifact after it is compressed and transferred",
            type: String,
            default_value: "Results"
          ),
        ]
      end
    end
  end
end
