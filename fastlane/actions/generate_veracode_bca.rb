module Fastlane
  module Actions
    class GenerateVeracodeBcaAction < Action

      # Support
      def self.is_supported?(platform)
        platform == :ios
      end

      # Run
      def self.run(params)
        xcarchive_path = params[:xcarchive_path]
        output_name = params[:output_name]

        # Move the "Products/Applications" folder up a directory and rename it to "Payload"
        File.rename("#{xcarchive_path}/Products/Applications", "#{xcarchive_path}/Payload")

        # Delete the (now empty) "Products" folder
        Dir.delete("#{xcarchive_path}/Products")

        # TODO: The Veracode Application Packager app ends up only compressing the "BCSymbolMaps", "dSYMs", and "Payload" folders.
        #       When following the manual packaging instructions, we end up compressing the above plus "Info.plist" and "SwiftSupport" folders.
        #       Need to reach out to Veracode to see if it's okay to omit "Info.plist" and "SwiftSupport" (and have them update their instructions accordingly).

        # Zip up the contents of the archive into a .bca file
        # Based on https://github.com/brian1917/veracode-bca-builder/blob/master/veracode-bca-builder.sh
        Dir.chdir("#{xcarchive_path}") do
            bca_payload = "../#{output_name}.bca"

            sh("zip -r #{bca_payload} $(ls)")

            bca_payload_path = File.expand_path(bca_payload)

            # Return the path to the created .bca file
            bca_payload_path
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Converts a .xcarchive into a .bca file suitable for upload to Veracode"
      end

      def self.details
        "Converts a .xcarchive into a .bca file suitable for upload to the Veracode platform for static analysis security scanning. Follows the manual steps listed in the 'Packaging Guidance' section of Veracode's iOS compilation instructions. For more information, see https://help.veracode.com/reader/4EKhlLSMHm5jC8P8j3XccQ/PJWz14TuPBwScC2EpJtB2Q#ios__guidance"
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

      def self.return_value
        "Returns the absolute path to the generated .bca file"
      end

      def self.authors
        ["Tyler Milner - @tylermilner on GitHub"]
      end
    end
  end
end
