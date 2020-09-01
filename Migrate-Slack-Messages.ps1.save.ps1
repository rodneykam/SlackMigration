$root_path = "C:\CHC-ClinicalNetwork Slack export Jul 2 2015 - Aug 28 2020"

$scon = New-Object System.Data.SqlClient.SqlConnection
$scon.ConnectionString = "Data Source=localhost;Initial Catalog=slack_history;Integrated Security=true"

$cmd = New-Object System.Data.SqlClient.SqlCommand
$cmd = New-Object System.Data.SqlClient.SqlCommand
$cmd.Connection = $scon
$cmd.CommandTimeout = 0
$cmd.CommandText = "sp_insert_slack_messages"
$cmd.CommandType = [System.Data.CommandType]::StoredProcedure 

$param = New-Object System.Data.SqlClient.SqlParameter
$param.ParameterName = "@input_file"
$param.SqlDbType = [System.Data.SqlDbType]::NVarChar
$cmd.Parameters.Add($param)

try
{
    $scon.Open()
}
catch [Exception]
{
    Write-Error "Error Opening Database Connection"
    Write-Error $_.Exception.Message
}

$channel_paths = gci  $root_path -Directory
foreach ($channel_path in $channel_paths)
{
    $file_paths = gci (join-path $channel_path.FullName "*.json") | Select FullName
    foreach ($file_path in $file_paths)
    {
        Write-Host "Processing File...$($file_path.FullName)"
        $param.Value = $file_path.FullName
        $param.Size = ($file_path.FullName).Length
        $result = $cmd.ExecuteNonQuery()
        Write-Host "Result=$result"
    }
}

$scon.Dispose()
$cmd.Dispose()
