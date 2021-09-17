module Fastlane
  module Actions
    class BuildCleanupAction < Action

      # Support
      def self.is_supported?(platform)
        true
      end

      # Run
      def self.run(params)
        keychain_path = lane_context[:keychain_path] || UI.user_error!("No build keychain requiring cleanup found. Did you run build_setup before build_cleanup?")

        provisioning_profile_destination = "#{Dir.home}/Library/MobileDevice/Provisioning Profiles"
        provisioning_profile_names = lane_context[:provisioning_profile_names] || UI.user_error!("No provisioning profiles requiring cleanup found. Did you run build_setup before build_cleanup?")

        Fastlane::Actions::DeleteKeychainAction.run(keychain_path: keychain_path)

        provisioning_profile_names.each do |profile_name|
          profile_path = File.join(provisioning_profile_destination, profile_name)
          File.delete(profile_path) if File.exist?(profile_path)
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
        [ ]
      end
    end
  end
end
