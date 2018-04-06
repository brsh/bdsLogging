function Register-bdsFileLogOptions {
	#There's no help here, because while I want this to be public... I don't want it to show up in the show-help list
	param ( [switch] $force )
	if ($force) {
		$script:LogOptions.LogToFile = $false
		$script:LogOptions.FileName = ''
	}
}
Function Set-bdsFileLogOptions {
	<#
	.SYNOPSIS
	Set options for logging to a file

	.DESCRIPTION
	Sets the options to enable/disable logging to a file. Naturally, there's an enable/disable options,
	as well as an option for the path\filename. You must set a filename or else you can't log to a file.

	.PARAMETER LogToFile
	True or false, do it or don't

	.PARAMETER FileName
	The path and filename to use

	.EXAMPLE
	Set-bdsFileLogOptions -LogToFile -FileName 'C:\scripts\mylog.log'

	#>
	[cmdletbinding()]
	param (
		[switch] $LogToFile = $script:LogOptions.LogToFile,
		[ValidateScript( { test-path $_ -IsValid } )]
		[string] $FileName = $script:LogOptions.FileName
	)
	# $LogOptions = @{
	# LogToFile         = $false
	# FileName          = [string] ''
	# LogToEventLog     = $true
	# EventLogName      = [string] 'Application'
	# EventLogSource    = [string] ''
	# LogToTimeSeriesDB = $false
	# TimeSeriesDBuri   = [string] ''
	# TimeSeriesDBTags  = ''
	# }

	if ($PSBoundParameters.ContainsKey('LogToFile')) {
		if ((-not $script:LogOptions.FileName) -and ($LogToFile) -and (-not $PSBoundParameters.ContainsKey('FileName'))) {
			Write-Host 'The FileName option is not set' -ForegroundColor Red
			Write-Host 'Logging to File cannot be enabled.' -ForegroundColor Yellow
		} else {
			Write-Verbose "Setting LogToFile to $LogToFile"
			$script:LogOptions.LogToFile = $LogToFile

		}
	}
	if ($PSBoundParameters.ContainsKey('FileName')) {
		Write-Verbose "Setting File to $FileName"
		$script:LogOptions.FileName = $FileName
	}

}

function New-bdsLogFileEntry {
	<#
	.SYNOPSIS
	Write an Event to a Log File

	.DESCRIPTION
	When you want to write an event to a log filem this will do it, complete with timestamp

	.PARAMETER LogFile
	The name and path of the file to write to (defaults to $env:temp\Month.log)

	.PARAMETER Type
	Error, Warning, Information

	.PARAMETER Message
	The body of the event

	.EXAMPLE
	New-bdsLogFileEntry -LogFile '.\thislog.log' -Type 'Error' -Message 'An event happened'
	#>
	param (
		[string] $LogFile = "${env:Temp}\$((get-date).ToString('MMM')).log",
		[string] $Message = 'No message text supplied',
		[string] $Type = 'Information'
	)

	$bType = Get-EventType -Type $Type

	[string] $text = "$((Get-Date).ToString())`t$btype`t$($Message.Trim())"
	Write-Verbose "Trying to write to log file: $LogFile"
	try {
		$text | Out-File -FilePath $LogFile -Append -ErrorAction SilentlyContinue
		$true
	} catch {
		write-verbose "  Failed to write to file."
		Write-Verbose "    $($_.Exception.Message)"
	}
}
