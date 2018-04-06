function New-bdsEventLog {
	<#
	.SYNOPSIS
	Registers a new eventlog and source

	.DESCRIPTION
	All events need logs, and all logs need sources. This obfuscates the donut making.
	You must register a source with a log before you can write to that log.

	.PARAMETER AppName
	The name of the source (generally the app or script calling it)

	.PARAMETER EventLog
	The event log - 'Application', 'System', or one of your own choosing

	.EXAMPLE
	New-bdsEventLot -AppName 'MyApp' -EventLog 'Application'
	#>
	[cmdletbinding()]
	param (
		[string] $AppName = '',
		[string] $EventLog = 'Application'

	)
	if ($AppName) {
		try {
			write-verbose "Registering new Source ($AppName) in EventLog ($EventLog)"
			New-EventLog -LogName $EventLog -Source $AppName -ErrorAction Stop
			$true
		} catch [System.InvalidOperationException] {
			Write-verbose "  Not registering source - it's already registered."
			Write-Verbose "    $($_.Exception.Message)"
			$true
		} catch {
			Write-verbose "  Could not register new source."
			Write-Verbose "    $($_.Exception.Message)"
			$false
		}
	} else {
		$false
	}
}
