function Get-EventType {
	param (
		[string] $Type = 'Information'
	)

	[string] $bType = 'Information'
	switch -Regex ($Type) {
		"^E" { $bType = 'Error' }
		"^W" { $bType = 'Warning' }
		DEFAULT { $bType = 'Information'}
	}
	$bType
}

function Get-EventLogName {
	param (
		[string] $Log = 'Application'
	)

	[string] $bType = 'Application'
	switch -Regex ($Type) {
		"^A" { $bType = 'Application' }
		"^S" { $bType = 'System' }
		DEFAULT { $bType = 'Application'}
	}
	$bType
}

Function Remove-InvalidFileNameChars {
	param(
		[Parameter(Mandatory = $true, Position = 0)]
		[String] $Text
	)
	#Remove invalid filesystem characters and ones we just do not like in filenames
	$invalidChars = ([IO.Path]::GetInvalidFileNameChars() + "," + ";") -join ''
	$re = "[{0}]" -f [RegEx]::Escape($invalidChars)
	$Text = $Text -replace $re
	return $Text
}
