
Function Get-bdsLogOptions {
	<#
	.SYNOPSIS
	Display the current logging options

	.DESCRIPTION
	Display the logging options - eventlog, file, and/or time series DB, as well as the current values set to support them

	.EXAMPLE
	Get-LogOptions
	#>
	$script:LogOptions
}

