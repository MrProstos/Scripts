Import-Module ActiveDirectory
Add-Type -AssemblyName System.Web

$PathFile=Read-Host 'Enter the path to the file.'
$ExcelObj=New-Object -comobject Excel.Application
$ExcelWorkBook=$ExcelObj.Workbooks.Open($PathFile)
$ExcelWorkSheet=$ExcelWorkBook.Sheets.Item(1)
$rowcount=$ExcelWorkSheet.UsedRange.Rows.Count
for($i=2;$i -le $rowcount;$i++)
{
    $LastNameStudent=$ExcelWorkSheet.Columns.Item(3).Rows.Item($i).text
    $NameStudent=$ExcelWorkSheet.Columns.Item(2).Rows.Item($i).text
    $GroupStudent=$ExcelWorkSheet.Columns.Item(1).Rows.Item($i).text
    $GeneratPassword=[System.Web.Security.Membership]::GeneratePassword(10,2)
    $ExcelWorkSheet.Columns.Item(4).Rows.Item($i) = $GeneratPassword
    
    
    $User=(Get-ADUser -Filter *).Name
    foreach ($line in $User)
    {
        if ($line -eq $LastNameStudent)
        {
            $LastNameStudent+=$i
        }
    }

    New-ADUser -Name $LastNameStudent `
    -GivenName $NameStudent `
    -Description $GroupStudent `
    -AccountPassword (ConvertTo-SecureString "$GeneratPassword" -AsPlainText -Force) -Enabled $true
    if ((Get-ADGroup -Filter "Name -like '$GroupStudent'").Name -ne $GroupStudent)
    {
        New-ADGroup -Name $GroupStudent -GroupScope Global
    }
    Add-ADGroupMember -Identity $GroupStudent -Members $LastNameStudent

}
$ExcelObj.Quit()
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($ExcelObj)
Remove-Variable ExcelObj