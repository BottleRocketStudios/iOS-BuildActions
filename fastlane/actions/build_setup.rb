require 'securerandom'

module Fastlane
  module Actions
    class BuildSetupAction < Action

      # Support
      def self.is_supported?(platform)
        true
      end

      # Run
      def self.run(params)
        certificate_source = params[:certificate_source] || UI.user_error!("Please provide a certificate_source.")
        certificate_names = params[:certificate_names] || UI.user_error!("Please provide an array of certificate_names.")

        provisioning_profile_destination = "#{Dir.home}/Library/MobileDevice/Provisioning Profiles"
        provisioning_profile_source = params[:provisioning_profile_source] || UI.user_error!("Please provide a provisioning_profile_source.")
        provisioning_profile_names = params[:provisioning_profile_names] || UI.user_error!("Please provide an array of provisioning_profile_names.")
        lane_context[:provisioning_profile_names] = provisioning_profile_names

        should_log = params[:should_log] || false

        keychain_directory = "#{Dir.pwd}/.build/keychain"
        keychain_path = "#{keychain_directory}/#{SecureRandom.hex(8)}.keychain"
        keychain_password = SecureRandom.hex(8)
        lane_context[:keychain_path] = keychain_path

        # Keychain Creation
        should_log && UI.message("Creating keychain at #{keychain_path} ...")
        Fastlane::Actions::CreateKeychainAction.run(
          add_to_search_list: true,
          default_keychain: false,
          password: keychain_password,
          path: keychain_path,
          timeout: false,
          unlock: true
        )
        should_log && UI.message("Finished creating keychain at #{keychain_path}.")

        # Profile Import
        should_log && UI.message("Copying provisioning profiles from #{provisioning_profile_source} to #{provisioning_profile_destination} ...")
        provisioning_profile_names.each_index do |index|
          profile_source = File.join(provisioning_profile_source, provisioning_profile_names[index])
          should_log && UI.message("Copying #{profile_source} to #{provisioning_profile_destination} ...")
          FileUtils.copy(profile_source, provisioning_profile_destination)
        end
        should_log && UI.message("Finished copying provisioning profiles to #{provisioning_profile_destination}.")

        # Certificate Import
        should_log && UI.message("Importing certificates to keychain at #{keychain_path} ...")
        certificate_names.each do |certificate_name|
          certificate_path = File.join(certificate_source, certificate_name)
          certificate_password = get_certificate_password(certificate_source, certificate_name)

          should_log && UI.message("Copying #{certificate_path} to keychain at #{keychain_path} ...")
          Fastlane::Actions::ImportCertificateAction.run(
            certificate_path: certificate_path,
            certificate_password: certificate_password,
            keychain_password: keychain_password,
            keychain_path: keychain_path,
          )
        end
        should_log && UI.message("Finished importing certificates to keychain at #{keychain_path}.")
      end

      # Helper

      # Extract the password for a given '.p12' certificate
      def self.get_certificate_password(certificate_source, certificate_name)
        certificate_basename = File.basename(certificate_name, ".p12")
        certificate_passfile_name = certificate_basename + ".pass"
        certificate_passfile_path = File.join(certificate_source, certificate_passfile_name)

        if File.exist?(certificate_passfile_path)
          File.read(certificate_passfile_path).chomp
        else
          UI.user_error!("Failed to find a .pass file for #{certificate_name}. To fix this, create a file at #{certificate_passfile_path} with the contents set to the password for #{certificate_name}.")
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Performs setup for the build, creating a keychain for the build, importing the appropriate certificates and provisioning profiles"
      end

      def self.authors
        ["Pranjal Satija - @pranjalsatija on GitHub",
         "Will McGinty - @wmcginty on GitHub"]
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :certificate_names,
            description: "The names, including the '.p12' extension, of each certificate to use. These certificates should be in the directory specified by 'certificate_source'",
            type: Array,
          ),

          FastlaneCore::ConfigItem.new(
            key: :certificate_source,
            description: "The directory that contains the certificates specified in 'certificate_names'",
            default_value: "./ios-p12-vault",
            type: String
          ),

          FastlaneCore::ConfigItem.new(
            key: :provisioning_profile_names,
            description: "The names, including the '.mobileprovision' extension, of each provisioning profile to use. These profiles should be in the directory specified by 'provisioning_profile_source'",
            type: Array,
          ),

          FastlaneCore::ConfigItem.new(
            key: :provisioning_profile_source,
            description: "The directory that contains the provisioning profiles specified in 'provisioning_profile_names'",
            default_value: "./ios-provisioning-profile-vault",
            type: String
          ),

          FastlaneCore::ConfigItem.new(
            key: :should_log,
            description: "Should the action output additional information as it runs",
            default_value: false,
            type: Boolean
          )
        ]
      end
    end
  end
end
