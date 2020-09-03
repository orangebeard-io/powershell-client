enum LogLevel {
    error
    warn
    info
    debug
    trace
    fatal
    unknown
}

enum Status {
    PASSED
    FAILED
    STOPPED
    SKIPPED
    RESETED
    CANCELLED
}

enum TestItemType {
    SUITE
    STORY
    TEST 
    SCENARIO 
    STEP 
    BEFORE_CLASS 
    BEFORE_GROUPS
    BEFORE_METHOD 
    BEFORE_SUITE 
    BEFORE_TEST 
    AFTER_CLASS 
    AFTER_GROUPS
    AFTER_METHOD 
    AFTER_SUITE
    AFTER_TEST
}

class Attribute {
    [string]$key
    [string]$value
}

class AttachmentFile {
    [string]$name
    
    AttachmentFile([string]$fileName) {
        $this.name = [System.IO.Path]::GetFileName($fileName)
    }
}

class Log {
    [string]$launchUuid
    [string]$itemUuid
    [string]$level
    [string]$message
    [AttachmentFile]$file
    [string]$time

    Log([string]$testRunUUID, [string]$itemUuid, [string]$loglevel, [string]$message, [string]$file) {
            $this.launchUuid = $testRunUUID
            $this.itemUuid = $itemUuid
            $this.level = $loglevel
            $this.message = $message
            $this.time = [int64](([datetime]::UtcNow)-(get-date "1/1/1970")).TotalMilliseconds
            $this.file = [AttachmentFile]::new($file)
        }

    Log([string]$testRunUUID, [string]$itemUUID, [string]$loglevel, [string]$message) {
            $this.launchUuid = $testRunUUID
            $this.itemUuid = $itemUuid
            $this.level = $loglevel
            $this.message = $message
            $this.time = [int64](([datetime]::UtcNow)-(get-date "1/1/1970")).TotalMilliseconds
        }
}

class StartTestRun {
    [string]$mode = 'DEFAULT'
    [bool]$rerun = $false
    [string]$rerunOf = $null

    [string]$name
    [string]$description
    [string]$startTime

    StartTestRun([string]$description, [string]$name) {
        $this.description = $description
        $this.name = $name
        $this.startTime = [int64](([datetime]::UtcNow)-(get-date "1/1/1970")).TotalMilliseconds
    }
}

class StartTestItem {
    [string]$launchUuid
    [string]$type
    
    [string]$name
    [string]$description
    [string]$startTime

    StartTestItem([string]$testRunUUID, [string]$type, [string]$description, [string]$name) {
        $this.launchUuid = $testRunUUID
        $this.type = $type
        $this.description = $description
        $this.name = $name
        $this.startTime = [int64](([datetime]::UtcNow)-(get-date "1/1/1970")).TotalMilliseconds
    }
}

class FinishTestRun {
    [string]$endTime
    [string]$status

    FinishTestRun([string]$status) {
        $this.status = $status
        $this.endTime = [int64](([datetime]::UtcNow)-(get-date "1/1/1970")).TotalMilliseconds
    }
}

class FinishTestItem {
    [string]$launchUuid
    [string]$endTime
    [string]$status

    FinishTestItem([string]$testrunUUID, [string]$status) {
        $this.launchUuid = $testrunUUID
        $this.endTime = [int64](([datetime]::UtcNow)-(get-date "1/1/1970")).TotalMilliseconds
        $this.status = $status
    }
}


#####      <<----------------- CLIENT LOGIC ----------------->>      #####
##########################################################################

class OrangebeardClient {
    [string]$orangebeard_endpoint = $env:orangebeard_endpoint;
    [string]$orangebeard_project = $env:orangebeard_project;
    [string]$orangebeard_token = $env:orangebeard_token;
    [string]$orangebeard_testRun = $env:orangebeard_testrun;
    
    hidden [String]$apiVersion = "v1"

    hidden [string]$testrunUUID; 
    hidden [string]$lastRootItem;
    hidden [string]$lastItem;

    hidden [bool]$rerun;
    hidden [string]$rerunOf;

    [string] $projectApiUrl = $this.orangebeard_endpoint + "/api/" + $this.apiVersion + "/" + $this.orangebeard_project

    reportStartTestRun([string]$name, [string]$description){
        [string] $url = $this.projectApiUrl + "/launch"
        [StartTestRun] $startTestRun = [StartTestRun]::new([string]$description, [string]$name)
        
        $body = $startTestRun | ConvertTo-Json
        $response = Invoke-RestMethod -Headers @{Authorization = "bearer " + $this.orangebeard_token} -Method Post -Uri $url -Body $body -ContentType "application/json"
        $this.testrunUUID = $response.id
    }

    reportFinishTestRun([Status]$status) {
        [String] $url = $this.projectApiUrl +  "/launch/" + $this.testrunUUID + "/finish"
        [FinishTestRun] $finishTestRun = [FinishTestRun]::new($status)
        $body = $finishTestRun | ConvertTo-Json
        Invoke-RestMethod -Headers @{Authorization = "bearer " + $this.orangebeard_token} -Method put -Uri $url -Body $body -ContentType "application/json"
    }

    reportStartTestCase([string]$name, [string]$description, [TestItemType]$type) {
        [string] $url = $this.projectApiUrl + "/item"
        [StartTestItem] $startItem = [StartTestItem]::new($this.testrunUUID, $type.ToString(), $description, $name)
        $body = $startItem | ConvertTo-Json
        $response = Invoke-RestMethod -Headers @{Authorization = "bearer " + $this.orangebeard_token} -Method Post -Uri $url -Body $body -ContentType "application/json"
        $this.lastItem = $response.id
    }

    reportFinishTestCase([Status]$status) {
        [string] $url = $this.projectApiUrl + "/item/" + $this.lastItem 
        [FinishTestItem] $finishItem = [FinishtestItem]::new($this.testrunUUID, $status)
        $body = $finishItem | ConvertTo-Json
        Invoke-RestMethod -Headers @{Authorization = "bearer " + $this.orangebeard_token} -Method Put -Uri $url -Body $body -ContentType "application/json"
    }

    reportLog([string]$message, [LogLevel]$level) {
        [string] $url = $this.projectApiUrl + "/log"
        [Log] $logItem = [Log]::new($this.testrunUUID, $this.lastItem, $level, $message)
        $body = $logItem | ConvertTo-Json
        Invoke-RestMethod -Headers @{Authorization = "bearer " + $this.orangebeard_token} -Method Post -Uri $url -Body $body -ContentType "application/json"
    }

    reportAttachment([string]$message, [LogLevel]$level, [string]$file) {
        [string] $url = $this.projectApiUrl + "/log"
        [Log] $logItemWithAttachment = [Log]::new($this.testrunUUID, $this.lastItem, $level, $message, $file)
        
        $fileName = [System.IO.Path]::GetFileName($file)
        $fileBytes = [System.IO.File]::ReadAllBytes($file);
        $fileEnc = [System.Text.Encoding]::GetEncoding('ISO-8859-1').GetString($fileBytes);
        $boundary = [System.Guid]::NewGuid().ToString(); 
        
        $jsonBody = $logItemWithAttachment | ConvertTo-Json
        $LF = "`r`n";

        $body = (     
            "--$boundary",
            "Content-Disposition: form-data; name=`"json_request_part`"",
            "Content-Type: application/json$LF",
            "[$jsonBody]",    
            "--$boundary",
            "Content-Disposition: form-data; name=`"file`"; filename=`"$filename`"",
            "Content-Type: application/octet-stream$LF",
            $fileEnc,
            "--$boundary--$LF" 
        ) -join $LF
        
        Invoke-RestMethod -Headers @{Authorization = "bearer " + $this.orangebeard_token} -Method Post -Uri $url -ContentType "multipart/form-data; boundary=`"$boundary`"" -Body $body
    }



}


