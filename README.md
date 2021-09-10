# Build Actions
A series of Fastlane utilities to make building apps within Bottle Rocket simpler.

## How it Works
This project contains two custom Fastlane actions:

* `build_setup`: Sets up everything needed to run a build. This includes creating a new temporary Keychain, copying the right provisioning profiles into `~/Library/MobileDevice/Provisioning Profiles`, and importing the correct certificates into the newly created Keychain.
* `build_cleanup`: Cleans up everything that `build_setup` does - including deleting the provisioning profiles and the temporary keychain.

## Usage
You can link this project with your existing Fastfile using the `import_from_git` action. You don't need to clone this repo or install it anywhere in your project. An example usage inside a `Fastfile` is below. There are two main ways to properly utilize these actions and account for build failures - and both examples are below. The exception handling is not explicitly *required*, but it should be present so cleanup can be done even in the case of a build failure.

```ruby
default_platform(:ios)
import_from_git(url: "git@github.com:BottleRocketStudios/iOS-BuildActions.git")

platform :ios do

  lane :buildExample do
    begin
      build_setup(
        certificate_names: ["Certificate1.p12"],
        provisioning_profile_names: ["Profile1.mobileprovision", "Profile2.mobileprovision"],
        should_log: true
      )

      # `gym` command not shown
    rescue => exception
      raise exception
      build_cleanup()
    end

    build_cleanup()
  end

  lane :buildExample2 do
    build_setup(
      certificate_names: ["Certificate1.p12"],
      provisioning_profile_names: ["Profile1.mobileprovision", "Profile2.mobileprovision"],
      should_log: true
    )
    # `gym` command not shown
    build_cleanup()
  end

  error do |lane, exception|
   UI.error("Lane [#{lane}] Threw Exception: #{exception}")
   cleanup_build # Keep in mind if you have other lanes, they may not need cleanup!
 end
end
```
