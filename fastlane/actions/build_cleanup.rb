module Fastlane
  module Actions
    class BuildCleanupAction < Action

      # Support
      def self.is_supported?(platform)
        true
      end

      # Run
      def self.run(params)
        keychain_path = lane_context[:keychain_path]
        provisioning_profile_destination = "#{Dir.home}/Library/MobileDevice/Provisioning Profiles"
        provisioning_profile_names = lane_context[:provisioning_profile_names]

        if keychain_path.nil? || provisioning_profile_names.nil? then
          if params[:fail_silently] == false then
            UI.user_error!("No build keychain or provisioning profiles requiring cleanup found. Did you run build_setup before build_cleanup?")
          end
        else
          # Delete the keychain and provisioning profiles
          Fastlane::Actions::DeleteKeychainAction.run(keychain_path: keychain_path)
          provisioning_profile_names.each do |profile_name|
            profile_path = File.join(provisioning_profile_destination, profile_name)
            File.delete(profile_path) if File.exist?(profile_path)
          end
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Performs cleanup after the build, deleting the keychain and removing provisioning profiles"
      end

      def self.authors
        ["Pranjal Satija - @pranjalsatija on GitHub",
         "Will McGinty - @wmcginty on GitHub"]
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :fail_silently,
            description: "Determines whether the cleanup action should emit an error if the build keychain or provisioning profiles can't be found",
            default_value: false,
            type: Boolean
          )
        ]
      end
    end
  end
end
