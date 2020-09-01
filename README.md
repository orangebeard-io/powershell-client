<h1 align="center">
  <a href="https://github.com/orangebeard-io/powershell-client">
    <img src="https://raw.githubusercontent.com/orangebeard-io/powershell-client/master/.github/logo.svg" alt="Orangebeard.io Powershell Client" height="200">
  </a>
  <br>Orangebeard.io Powershell Client<br>
</h1>

<h4 align="center">A client to report output from Powershell scripts to Orangebeard</h4>

<!--<p align="center">
  <a href="https://repo.maven.apache.org/maven2/io/orangebeard/fitnesse-toolchain-listener/">
    <img src="https://img.shields.io/maven-central/v/io.orangebeard/fitnesse-toolchain-listener.svg?maxAge=3600&style=flat-square"
      alt="MVN Version" />
  </a>
  <a href="https://github.com/orangebeard-io/fitnesse-toolchain-listener/actions">
    <img src="https://img.shields.io/github/workflow/status/orangebeard-io/fitnesse-toolchain-listener/release?style=flat-square"
      alt="Build Status" />
  </a>
  <a href="https://github.com/orangebeard-io/fitnesse-toolchain-listener/blob/master/LICENSE.txt">
    <img src="https://img.shields.io/github/license/orangebeard-io/fitnesse-toolchain-listener?style=flat-square"
      alt="License" />
  </a>
</p>-->

<div align="center">
  <h4>
    <a href="https://orangebeard.io" target="_blank">Orangebeard</a> |
    <a href="#installation">Installation</a> |
    <a href="#configuration">Configuration</a>
  </h4>
</div>

## Installation
Copy the OrangebeardClient folder to your PowerShell Modules directory 

## Configuration
Start you script with: `using module OrangebeardClient`

Set the following environment variables:
```
$env:orangebeard_endpoint = "https://my.orangebeard.app";
$env:orangebeard_project = "your-project";
$env:orangebeard_token = "your-access-token";
```

Start the client using: `$orangebeard = [OrangebeardClient]::new()`

The orangebeard client currently supports the following methods:

### reportStartTestRun ("Test run name", "Description")
Starts the testrun in Orangebeard.

### reportFinishTestRun (Status)
Finishes the test run and sets the desired [Status]

### reportStartTestCase ("Test Case Name", "Description", TestItemType)
report the start of a test case.

### reportFinishTestCase (Status)
Finishes the test case and sets the desired [Status]

### reportLog ("Message", LogLevel)
Logs a message to the current test report.

### reportAttachment("Message", LogLevel, "file path") 
Logs an attachment file to the current test report.

## Enumerations

### LogLevel
 * error
 * warn
 * info
 * debug
 * trace
 * fatal
 * unknown

### Status
 * PASSED
 * FAILED
 * STOPPED
 * SKIPPED
 * RESETED
 * CANCELLED

### TestItemType
 * SUITE
 * STORY
 * TEST 
 * SCENARIO 
 * STEP 
 * BEFORE_CLASS 
 * BEFORE_GROUPS
 * BEFORE_METHOD 
 * BEFORE_SUITE 
 * BEFORE_TEST 
 * AFTER_CLASS 
 * AFTER_GROUPS
 * AFTER_METHOD 
 * AFTER_SUITE
 * AFTER_TEST

## Limitations
 - Currently, only flat suites are supported (one suite, containing testcases). No further nesting logic is implemented
