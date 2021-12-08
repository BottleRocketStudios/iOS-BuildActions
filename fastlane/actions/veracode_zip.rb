module Fastlane
  module Actions
    class VeracodeZipAction < Action

      # Support
      def self.is_supported?(platform)
        platform == :ios
      end

      # Run
      def self.run(params)
        xcarchive_path = params[:xcarchive_path]
        output_name = params[:output_name]

        Dir.chdir("#{xcarchive_path}") do
            payload_path = "../#{output_name}.zip"
            sh("zip -r #{payload_path} $(ls)")

            final_payload_path = File.expand_path(payload_path)

            # Return the path to the created .bca file
            final_payload_path
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Converts a .xcarchive into a .zip file suitable for upload to Veracode"
      end

      def self.return_value
        "Returns the absolute path to the generated .bca file"
      end

      def self.authors
        ["Tyler Milner - @tylermilner on GitHub",
         "Will McGinty - @wmcginty on GitHub"]
      end

      def self.details
        "Converts a .xcarchive into a .zip file suitable for upload to the Veracode platform for static analysis security scanning. Follows the manual steps listed in the 'Packaging Guidance' section of Veracode's iOS compilation instructions. For more information, see https://help.veracode.com/reader/4EKhlLSMHm5jC8P8j3XccQ/PJWz14TuPBwScC2EpJtB2Q#ios__guidance"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :xcarchive_path,
                                       description: "The path to the .xcarchive file to be converted into the Veracode .bca",
                                       type: String,
                                       verify_block: proc do |value|
                                          UI.user_error!("A non-empty xcarchive path must be provided") unless (value and not value.empty?)
                                       end),

          FastlaneCore::ConfigItem.new(key: :output_name,
                                       description: "The file name to be used for the generated .bca file (not including the '.bca' extension)",
                                       type: String,
                                       verify_block: proc do |value|
                                          UI.user_error!("A non-empty output file name must be provided") unless (value and not value.empty?)
                                       end)
        ]
      end
    end
  end
end
