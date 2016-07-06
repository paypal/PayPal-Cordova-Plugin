#### releasinator config ####
configatron.product_name = "PayPal-Cordova-Plugin"

# List of items to confirm from the person releasing.  Required, but empty list is ok.
configatron.prerelease_checklist_items = [  
  "Run the iOS Tests.",
  "Run the Android Tests.",
  "Sanity check the master branch."
]

def validate_version_match()
  if plugin_version() != @current_release.version
    Printer.fail("plugin.xml version #{plugin_version} does not match changelog version #{@current_release.version}.")
    abort()
  end
  Printer.success("plugin.xml version #{plugin_version} matches latest changelog version.")

  if package_version() != @current_release.version
      Printer.fail("package.json version #{package_version} does not match changelog version #{@current_release.version}.")
      abort()
    end
    Printer.success("package.json version #{package_version} matches latest changelog version.")
end

def validate_paths
  @validator.validate_in_path("wget")
  @validator.validate_in_path("jq")
end

def validate_npm_version()
  npm_version_output = CommandProcessor.command("npm --version").strip
  expected_npm_version = "2.15.5"

  if Gem::Version.new(expected_npm_version) > Gem::Version.new(npm_version_output)
    Printer.fail("Actual npm version " + npm_version_output.bold + " is smaller than expected npm version " + expected_npm_version.bold)
    abort()
  else
    Printer.success("npm version " + npm_version_output.bold + " found, and is higher than or equal to expected npm version " + expected_npm_version.bold)
  end
end

configatron.custom_validation_methods = [
  method(:validate_paths),
  method(:validate_npm_version),
  method(:validate_version_match)
]

# there are no separate build steps for PayPal-Cordova-Plugin, so it is just empty method
def build_method
end

# The command that builds the sdk.  Required.
configatron.build_method = method(:build_method)

def publish_to_package_manager(version)
  CommandProcessor.command("npm publish .")
end

# The method that publishes the sdk to the package manager.  Required.
configatron.publish_to_package_manager_method = method(:publish_to_package_manager)


def wait_for_package_manager(version)
  CommandProcessor.wait_for("wget -U \"non-empty-user-agent\" -qO- https://registry.npmjs.org/com.paypal.cordova.mobilesdk | jq '.[\"dist-tags\"][\"latest\"]' | grep #{version} | cat")
end

# The method that waits for the package manager to be done.  Required
configatron.wait_for_package_manager_method = method(:wait_for_package_manager)

# Whether to publish the root repo to GitHub.  Required.
configatron.release_to_github = true


def plugin_version()
  File.open("plugin.xml", 'r') do |f|
    f.each_line do |line|
      if line.match (/version=\"\d*\.\d*\.\d*\"/)
        return line.strip.split('=')[1].strip.split('"')[1]
      end
    end
  end
end

def package_version()
  File.open("package.json", 'r') do |f|
    f.each_line do |line|
      if line.match (/\"version\": \"\d*\.\d*\.\d*\"/)
        return line.strip.split(':')[1].strip.split('"')[1]
      end
    end
  end
end
