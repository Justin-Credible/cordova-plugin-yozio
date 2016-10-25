#!/usr/bin/env node

/**
 * This build hook is responsible for adding the domain from the URL_SCHEME plugin variable
 * to the XCode associated domains entitlement. If an entitlement file does not already exist
 * one will be created.
 */

/**
 * The ID of this plugin; this should match the value in plugin.xml.
 */
var PLUGIN_ID = "cordova-plugin-yozio";

/**
 * Node modules imported via the main function.
 */
var path, fs, xcode, plist, common;

/**
 * The Cordova context; see https://cordova.apache.org/docs/en/latest/guide/appdev/hooks/#script-interface
 */
var context;

/**
 * The main hook entrypoint.
 * 
 * This build hook is wired up to execute only for the iOS platform via plugin.xml.
 */
module.exports = function (cordovaContext) {

    // Save off so we don't have to pass it around everywhere.
    context = cordovaContext;

    // Grab the modules we need for this build hook.
    path = cordovaContext.requireCordovaModule("path");
    fs = cordovaContext.requireCordovaModule("fs");
    xcode = cordovaContext.requireCordovaModule("xcode");
    plist = cordovaContext.requireCordovaModule("plist");
    common = cordovaContext.requireCordovaModule("cordova-common");

    // Determine the action depending on the current plugin operation.
    if (context.hook === "after_plugin_install") {
        addEntitlement();
    }
    else if (context.hook === "before_plugin_uninstall") {
        removeEntitlement();
    }
};

/** Helpers *************************************************************************************/

function log(message) {
    console.log(PLUGIN_ID + ": " + message);
}

function throwError(message) {
    throw new Error(PLUGIN_ID + ": " + message);
}

function getXcodeProjectFilePath() {
    var ConfigParser = common.ConfigParser;

    var configXmlPath = path.join(context.opts.projectRoot, "config.xml");
    var config = new ConfigParser(configXmlPath);

    var projectName = config.name();
    var projectPath = path.join(context.opts.projectRoot, "platforms", "ios", projectName + ".xcodeproj", "project.pbxproj");

    return projectPath;
}

function getYozioDomainFromPluginConfig() {

    // I'm not sure why, but this collection always has null values.
    // return context.opts.plugin.pluginInfo.getPreferences()["YOZIO_DOMAIN"];

    var platformConfigPath = path.join(context.opts.projectRoot, "platforms", "ios", "ios.json");

    // Sanity check
    if (!fs.existsSync(platformConfigPath)) {
        throwError(": sanity check failed; unable to locate iOS platform configuration at: " + platformConfigPath);
    }

    var json = fs.readFileSync(platformConfigPath, { encoding: "utf8" });
    var config = JSON.parse(json);

    // Sanity check
    if (!config.installed_plugins || !config.installed_plugins[PLUGIN_ID] || !config.installed_plugins[PLUGIN_ID]["URL_SCHEME"]) {
        throwError(": sanity check failed; unable to locate URL_SCHEME for the plugin in: " + platformConfigPath)
    }

    return config.installed_plugins[PLUGIN_ID]["URL_SCHEME"];
}

function getNewEntitlementsFileName() {
    var ConfigParser = common.ConfigParser;

    var configXmlPath = path.join(context.opts.projectRoot, "config.xml");
    var config = new ConfigParser(configXmlPath);

    var projectName = config.name();

    return projectName + ".entitlements";
}

function getNewEntitlementsPath() {
    var ConfigParser = common.ConfigParser;

    var configXmlPath = path.join(context.opts.projectRoot, "config.xml");
    var config = new ConfigParser(configXmlPath);

    var projectName = config.name();
    var fileName = getNewEntitlementsFileName();

    return path.join(projectName, "Resources", fileName);
}

function getEntitlementsFilePath(buildConfig) {

    if (!buildConfig) {
        throwError(": a build configuration is required to set an entitlements path.");
    }

    var returnValue = null;

    Object.keys(buildConfig).forEach(function (key) {

        var section = buildConfig[key];

        // The field we are looking for is nested on buildSettings.
        if (!section["buildSettings"]) {
            return; // continue
        }

        // Only look at sections that have a product name.
        // The cordova lib project does not have a product name, so this effectively skips it.
        if (!section["buildSettings"]["PRODUCT_NAME"]) {
            return; // continue
        }

        var entitlementsPath = section["buildSettings"]["CODE_SIGN_ENTITLEMENTS"];

        if (!entitlementsPath) {
            return; // continue
        }

        if (returnValue) {
            log("Multiple entitlement files were found; now using: " + entitlementsPath);
        }

        returnValue = entitlementsPath;
    });

    return returnValue;
}

function setEntitlementsFilePath(buildConfig, path) {

    if (!buildConfig) {
        throwError(": a build configuration is required to set an entitlements path.");
    }

    Object.keys(buildConfig).forEach(function (key) {

        var section = buildConfig[key];

        // The field we are looking for is nested on buildSettings.
        if (!section["buildSettings"]) {
            return; // continue
        }

        // Only look at sections that have a product name.
        // The cordova lib project does not have a product name, so this effectively skips it.
        if (!section["buildSettings"]["PRODUCT_NAME"]) {
            return; // continue
        }

        section["buildSettings"]["CODE_SIGN_ENTITLEMENTS"] = path;
    });
}

/** Add Entitlement *****************************************************************************/

function addEntitlement(context) {

    // Keep track if we needed to create an entitlements file.
    // If we created one, we'll need to set the path to it in the XCode project file later.
    var createdEntitlements = false;

    // Load the XCode project.
    var xcodeProjectPath = getXcodeProjectFilePath();
    var xcodeProject = xcode.project(xcodeProjectPath);
    xcodeProject.parseSync();
    buildConfig = xcodeProject.pbxXCBuildConfigurationSection();

    // Determine the paths to the entitlements file; we need the path relative to the Cordova project for reading/writing
    // the file from this build hook, and we need the path relative to the XCode project so the XCode can find it when
    // open opening the project.
    var entitlementsPathRelativeToXCodeProject = getEntitlementsFilePath(buildConfig);
    var entitlementsPathRelativeToCordovaRoot = null;

    if (entitlementsPathRelativeToXCodeProject) {
        // If we found an entitlements file in the XCode project we don't need to create one.
        // In this case, just calculate the same path relative to the Cordova project root.
        entitlementsPathRelativeToCordovaRoot = path.join("platforms", "ios", entitlementsPathRelativeToXCodeProject);
    }
    else {
        // If the XCode project didn't already have an entitlements file, then create one.
        entitlementsPathRelativeToXCodeProject = getNewEntitlementsPath();
        entitlementsPathRelativeToCordovaRoot = path.join("platforms", "ios", entitlementsPathRelativeToXCodeProject);

        log("An entitlements file was not found; creating one at: " + entitlementsPathRelativeToCordovaRoot);

        var plistEmptyXml = plist.build({}, { pretty: true });
        fs.writeFileSync(entitlementsPathRelativeToCordovaRoot, plistEmptyXml, { encoding: "utf8" });

        // We'll need to write to the XCode project later.
        createdEntitlements = true;
    }

    log("Using entitlements file at: " + entitlementsPathRelativeToCordovaRoot);

    // Read the entitlements file (which is a plist/XML format) and parse it into a native JSON object.
    var plistOriginalXml = fs.readFileSync(entitlementsPathRelativeToCordovaRoot, "utf8");
    var plistObj = plist.parse(plistOriginalXml);

    // If the associated domains array doesn't already exist, then create it.
    if (!plistObj["com.apple.developer.associated-domains"]) {
        plistObj["com.apple.developer.associated-domains"] = [];
    }

    var associatedDomains = plistObj["com.apple.developer.associated-domains"];

    // Grab the domain from the plugin preferences (as defined during cordova plugin add).
    var domain = getYozioDomainFromPluginConfig();

    // If the domain already exists in the list, then we can bail out now.
    if (associatedDomains.indexOf(domain) !== -1) {
        log("Associated domain for '" + domain + "' was already present; no changes required.");
        return;
    }

    // Add the domain to the associated domain list.
    log("Adding associated domain for '" + domain + "'.");
    associatedDomains.push(domain);

    // Serialize back into the XML/plist format and write back to disk.
    var plistNewXml = plist.build(plistObj, { pretty: true });
    fs.writeFileSync(entitlementsPathRelativeToCordovaRoot, plistNewXml, { encoding: "utf8" });

    // Update the XCode project with the path to the entitlements file (if we created one).
    if (createdEntitlements) {
        log("Updating XCode project with reference to the new entitlements file.");
        xcodeProject.addResourceFile(getNewEntitlementsFileName());
        setEntitlementsFilePath(buildConfig, entitlementsPathRelativeToXCodeProject);
        fs.writeFileSync(xcodeProjectPath, xcodeProject.writeSync());
    }
}

/** Remove Entitlement **************************************************************************/

function removeEntitlement(context) {

    // Load the XCode project.
    var xcodeProjectPath = getXcodeProjectFilePath();
    var xcodeProject = xcode.project(xcodeProjectPath);
    xcodeProject.parseSync();
    buildConfig = xcodeProject.pbxXCBuildConfigurationSection();

    // Determine the paths to the entitlements file; we need the path relative to the Cordova project for reading/writing
    // the file from this build hook, and we need the path relative to the XCode project so the XCode can find it when
    // open opening the project.

    var entitlementsPathRelativeToXCodeProject = getEntitlementsFilePath(buildConfig);

    // If an entitlements file doesn't exist, then there is nothing to do.
    if (!entitlementsPathRelativeToXCodeProject) {
        log("No entitlements file present; nothing to remove.");
        return;
    }

    var entitlementsPathRelativeToCordovaRoot = path.join("platforms", "ios", entitlementsPathRelativeToXCodeProject);

    log("Using entitlements file at: " + entitlementsPathRelativeToCordovaRoot);

    // Read the entitlements file (which is a plist/XML format) and parse it into a native JSON object.
    var plistOriginalXml = fs.readFileSync(entitlementsPathRelativeToCordovaRoot, "utf8");
    var plistObj = plist.parse(plistOriginalXml);

    // If the associated domains array doesn't exist, then there is nothing to do.
    if (!plistObj["com.apple.developer.associated-domains"]) {
        log("No associated domains present; nothing to remove.");
        return;
    }

    var associatedDomains = plistObj["com.apple.developer.associated-domains"];

    // Grab the domain from the plugin preferences (as defined during cordova plugin add).
    var domain = getYozioDomainFromPluginConfig();

    // Attempt to locate the domain in the list.
    var index = associatedDomains.indexOf(domain);

    // If the domain is not in the list, then we can bail out now.
    if (index === -1) {
        log("Associated domain for '" + domain + "' was not present; no changes required.");
        return;
    }

    // Remove the domain from the list.
    associatedDomains = associatedDomains.splice(index, 1);

    log("Removing domain '" + domain + "' from associated domains list.");

    // Serialize back into the XML/plist format and write back to disk.
    var plistNewXml = plist.build(plistObj, { pretty: true });
    fs.writeFileSync(entitlementsPathRelativeToCordovaRoot, plistNewXml, { encoding: "utf8" });
}
