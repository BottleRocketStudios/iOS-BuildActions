# Build Actions
A series of Fastlane utilities to make building apps within Bottle Rocket easy and fast.

## How it Works
This project contains two custom Fastlane actions:

* `build_setup`: Sets up everything needed to run a build. This includes creating a new temporary Keychain, copying the right provisioning profiles into `~/Library/MobileDevice/Provisioning Profiles`, and importing the correct certificates into the new Keychain.
* `build_cleanup`: Cleans up everything that `build_setup` does.

## Usage
You can link this project with your existing Fastfile really easily using the `import_from_git` action. You don't need to clone this repo or install it anywhere in your project. Here's an example Fastfile. The exception handler isn't *required*, but you should have it in case your build fails so that the right cleanup can be done.
```ruby
default_platform(:ios)
import_from_git(url: "git@bitbucket.org:BottleRocket/brbuild_ios.git")

platform :ios do
  lane :build do
    begin
      build_setup(
        certificate_names: [""],
        provisioning_profile_names: [""],
        should_log: true
      )

      # insert build command here
    rescue => exception
      raise exception
      build_cleanup() # important!
    end

    build_cleanup()
  end
end
```
