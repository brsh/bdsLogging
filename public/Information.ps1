Function Get-bdsLoggingHelp {
	<#
	.SYNOPSIS
	List commands available in the bdsLogging Module

	.DESCRIPTION
	List all available commands in this module

	.EXAMPLE
	Get-bdsLoggingHelp
	#>
	[CmdLetBinding()]
	param ()
	Write-Host ""
	Write-Host "Getting available functions..." -ForegroundColor Yellow

	$all = @()
	$list = Get-Command -Type function -Module "bdsLogging" -verbose:$false | Where-Object { $_.Name -in $script:showhelp}
	$list | ForEach-Object {
		$RetHelp = Get-help $_.Name -ShowWindow:$false -ErrorAction SilentlyContinue -Verbose:$false
		Write-Verbose "Found $($_.Name)"
		if ($RetHelp.Description) {
			$Infohash = @{
				Command     = $_.Name
				Description = $RetHelp.Synopsis
			}
			$out = New-Object -TypeName psobject -Property $InfoHash
			$all += $out
		}
	}
	$all | format-table -Wrap -AutoSize | Out-String | Write-Host
}
