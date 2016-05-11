#### releasinator config ####
configatron.product_name = "PayPal-Cordova-Plugin"

# List of items to confirm from the person releasing.  Required, but empty list is ok.
configatron.prerelease_checklist_items = [  
  "Run the IOS Tests.",
  "Run the Android Tests.",
  "Sanity check the master branch."
]

def validate_version_match()
  if plugin_version != @current_release.version
    Printer.fail("Plugin.xml version #{plugin_version} does not match changelog version #{@current_release.version}.")
    abort()
  end
  Printer.success("Plugin.xml version #{plugin_version} matches latest changelog version.")

  if package_version != @current_release.version
      Printer.fail("Package.json version #{package_version} does not match changelog version #{@current_release.version}.")
      abort()
    end
    Printer.success("Package.json version #{package_version} matches latest changelog version.")
end

configatron.custom_validation_methods = [
  method(:validate_version_match)
]

def build_method
  # run tests first
  # detect non-zero failures/errors, since ruby command won't exit properly if unit tests called exit/abort
  output = CommandProcessor.command("ruby test/ts_allTests.rb | cat", live_output=true)
  if !output.match /assertions, 0 failures, 0 errors, 0 pendings, 0 omissions, 0 notifications$/
    Printer.fail("There were unit test failures.")
    abort()
  end

  output_dir = "build"
  CommandProcessor.command("gem build releasinator.gemspec")
  Dir.mkdir(output_dir) unless File.exists?(output_dir)
  CommandProcessor.command("mv releasinator-*.gem #{output_dir}")
end

# The command that builds the sdk.  Required.
configatron.build_method = method(:build_method)

def publish_to_package_manager(version)
  output_dir = "build"
  Dir.chdir(output_dir) do
    CommandProcessor.command("gem push releasinator-#{version}.gem")
  end
end

# The method that publishes the sdk to the package manager.  Required.
configatron.publish_to_package_manager_method = method(:publish_to_package_manager)


def wait_for_package_manager(version)
  CommandProcessor.wait_for("wget -U \"non-empty-user-agent\" -qO- https://www.npmjs.com/package/com.paypal.cordova.mobilesdk#{version} | cat")
end

# The method that waits for the package manager to be done.  Required
configatron.wait_for_package_manager_method = method(:wait_for_package_manager)

# Whether to publish the root repo to GitHub.  Required.
configatron.release_to_github = true


def plugin_version()
  f=File.new("plugin.xml", 'r')
  f.each do |line|
     if line.match (/version=\"\d*\.\d*\.\d*\"/)
       return line.strip.split('=')[1].strip.split('"')[1]
    end
  end
  f.close
end

def package_version()
f=File.new("Package.json", 'r')
  f.each do |line|
    if line.match (/\"version\": \"\d*\.\d*\.\d*\"/)
      return line.strip.split(':')[1].strip.split('"')[1]
    end
  end
  f.close
end

