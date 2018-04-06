function Register-bdsEventLogOptions {
	param ( [switch] $force )
	#There's no help here, because while I want this to be public... I don't want it to show up in the show-help list
	if ($force) {
		$script:LogOptions.Add('EventLog', $false)
		$script:LogOptions.Add('EventLogName', 'Application')
		$script:LogOptions.Add('EventLogSource', '')
	}
}

Function Set-bdsEventLogOptions {
	<#
	.SYNOPSIS
	Set options for logging to the EventLog

	.DESCRIPTION
	Sets the options to enable/disable eventlog logging (wow, that gets redundant quickly). Naturally,
	there's an enable/disable options, as well as which event log and the Source. You must specify a
	source or otherwise, you won't be able to find your log entries

	.PARAMETER LogToEventLog
	True or False - do it or don't

	.PARAMETER EventLogName
	Which event log? Application, System, Your Own New One??

	.PARAMETER Source
	The name of the Source of this event... usually your script name

	.EXAMPLE
	Set-bdsEventLogOption -LogToEventLog -EventLogName 'Application' -Source 'MyScriptOnBrontosauruses'
	#>
	[cmdletbinding()]
	param (
		[switch] $LogToEventLog = $script:LogOptions.EventLog,
		[string] $EventLogName = $script:LogOptions.EventLogName,
		[string] $Source = $script:LogOptions.EventLogSource
	)

	write-host 'there'
	write-host $PSBoundParameters.ContainsKey('LogToEventLog')

	if ($PSBoundParameters.ContainsKey('LogToEventLog')) {
		write-host '1'
		if ((-not $script:LogOptions.EventLogSource) -and ($LogToEventLog) -and (-not $PSBoundParameters.ContainsKey('Source'))) {
			write-host '2'
			Write-Host 'The EventLogSource option is not set' -ForegroundColor Red
			Write-Host 'EventLog Logging cannot be enabled.' -ForegroundColor Yellow
		} else {
			write-host '3'
			Write-Verbose "Setting LogToEventLog to $LogToEventLog"
			$script:LogOptions.LogToEventLog = $LogToEventLog.ToBool()
		}
	}
	if ($PSBoundParameters.ContainsKey('EventLogName')) {
		write-host '4'
		Write-Verbose "Setting EventLog to $EventLogName"
		$script:LogOptions.EventLogName = $EventLogName
	}
	if ($PSBoundParameters.ContainsKey('Source')) {
		write-host 'there'5
		Write-Verbose "Setting EventLogSource to $Source"
		$script:LogOptions.EventLogSource = $Source
	}
}

function New-bdsEvent {
	<#
	.SYNOPSIS
	Write an Event to the Windows Event Log

	.DESCRIPTION
	When you want to write an event to the event log, it's not enough to just write an event.
	You have to register the source, you have to specify the log, you have to specify the event,
	you have to specify the event id. It's just nuts.

	This function tries to obfuscate and simplify the background event log stuff for you.

	.PARAMETER AppName
	The name of the app (source) sending the event

	.PARAMETER EventLog
	The eventlog to write the event in (defaults to Application)

	.PARAMETER Type
	Error, Warning, Information

	.PARAMETER Message
	The body of the event. Send as an array for simplicity - otherwise, lots of "`r`n"

	.PARAMETER EventID
	A number for the event. Is best to be consistent, but scripts rarely need a lot of events

	.EXAMPLE
	New-bdsEvent -AppName 'MyScript' -EventLog 'Application' -Message @('An event happened','',Run for the hills')
	#>
	[cmdletbinding()]
	param (
		[string] $AppName = '',
		[string] $EventLog = 'Application',
		[string] $Type = 'Information',
		[string[]] $Message = @(, 'No message text supplied'),
		[int] $EventID = 9999
	)

	[string] $bType = Get-EventType -Type $Type

	if (($Message) -and ($AppName)) {
		[string] $text = $Message -Join "`r`n"
		try {
			if (New-bdsEventLog -AppName $AppName -EventLog $EventLog) {
				Write-Verbose "Writing EventID $EventID to the log"
				Write-EventLog -LogName $EventLog -Source $AppName -eventid $EventID -Message $text -ErrorAction Stop -EntryType $bType
				$true
			} else {
				$false
			}
		} catch {
			Write-verbose "  Could not register new source."
			Write-Verbose "    $($_.Exception.Message)"
			$false
		}
	}
}


