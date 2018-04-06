param (
	[switch] $quiet = $false
)
#region Private Variables
# Current script path
[string] $ScriptPath = Split-Path (get-variable myinvocation -scope script).value.Mycommand.Definition -Parent
#endregion Private Variables

#region Private Helpers

# Dot sourcing private script files
Get-ChildItem $ScriptPath/private -Recurse -Filter "*.ps1" -File | ForEach-Object {
	. $_.FullName
}
#endregion Load Private Helpers

$LogOptions = [ordered] @{ }
[string[]] $script:showhelp = @()
# Dot sourcing public script files
Get-ChildItem $ScriptPath/public -Recurse -Filter "*.ps1" -File | ForEach-Object {
	. $_.FullName

	# From https://www.the-little-things.net/blog/2015/10/03/powershell-thoughts-on-module-design/
	# Find all the functions defined no deeper than the first level deep and export it.
	# This looks ugly but allows us to not keep any uneeded variables from poluting the module.
	([System.Management.Automation.Language.Parser]::ParseInput((Get-Content -Path $_.FullName -Raw), [ref] $null, [ref] $null)).FindAll( { $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $false) | Foreach {
		Export-ModuleMember $_.Name
		$showhelp += $_.Name
		if ($_.Name -match '^Register-') {
			try {
				& $_.Name -Force
			} catch { Write-Host $_.Exception.Message }
		}
	}
}
#endregion Load public Helpers

if (test-path $ScriptPath\formats\bdsLogging.format.ps1xml) {
	Update-FormatData $ScriptPath\formats\bdsLogging.format.ps1xml
}

if (-not $quiet) {
	Get-bdsLoggingHelp
}

###################################################
## END - Cleanup

#region Module Cleanup
$ExecutionContext.SessionState.Module.OnRemove = {
	# cleanup when unloading module (if any)
	Get-ChildItem alias: | Where-Object { $_.Source -match "bdsLogging" } | Remove-Item
	Get-ChildItem function: | Where-Object { $_.Source -match "bdsLogging" } | Remove-Item
	Get-ChildItem variable: | Where-Object { $_.Source -match "bdsLogging" } | Remove-Item
}
#endregion Module Cleanup

