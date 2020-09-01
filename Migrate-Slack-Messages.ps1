$root_path = "C:\CHC-ClinicalNetwork Slack export Jul 2 2015 - Aug 28 2020"

$scon = New-Object System.Data.SqlClient.SqlConnection
$scon.ConnectionString = "Data Source=localhost;Initial Catalog=slack_history;Integrated Security=true"
try
{
    $scon.Open()
}
catch [Exception]
{
    Write-Error "Error Opening Database Connection"
    Write-Error $_.Exception.Message
}

$cmd = New-Object System.Data.SqlClient.SqlCommand

$cmd.Connection = $scon
$cmd.CommandTimeout = 0
$cmd.CommandText = "SELECT * FROM slack_channel ORDER BY name"
$cmd.CommandType = [System.Data.CommandType]::Text

$channel_list = @()
$reader = $cmd.ExecuteReader()
while($reader.Read())
{
    $channel = New-Object PSObject
    $channel | Add-Member -type NoteProperty -Name 'Id' -Value $reader["id"]
    $channel | Add-Member -type NoteProperty -Name 'Name' -Value $reader["name"]
    $channel_list += $channel
}
$reader.Close()

$cmd.CommandText = "sp_insert_slack_messages"
$cmd.CommandType = [System.Data.CommandType]::StoredProcedure

$param1 = New-Object System.Data.SqlClient.SqlParameter
$param1.ParameterName = "@channel_id"
$param1.SqlDbType = [System.Data.SqlDbType]::NVarChar
$param1.Size = 50
$cmd.Parameters.Add($param1)

$param2 = New-Object System.Data.SqlClient.SqlParameter
$param2.ParameterName = "@input_file"
$param2.SqlDbType = [System.Data.SqlDbType]::NVarChar
$cmd.Parameters.Add($param2)

foreach ($channel in $channel_list)
{
    Write-Host "Processing files for Channel =" $channel.Name -f GREEN
    $file_paths = gci (join-path $root_path "$($channel.Name)\*.json") | Select FullName
    foreach ($file_path in $file_paths)
    {
        $param1.Value = $channel.Id
        $param2.Value = $file_path.FullName
        $param2.Size = ($file_path.FullName).Length
        $result = $cmd.ExecuteNonQuery()

        $file_name = gci $file_path.FullName | Select Name
        Write-Host $channel.Name $file_name.Name "Count=$result"
    }
}

$scon.Close()
$scon.Dispose()
$cmd.Dispose()
