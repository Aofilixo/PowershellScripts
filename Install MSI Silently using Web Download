#MSI Quiet Install Using Direct Download Link

$client = new-object System.Net.WebClient
$client.DownloadFile("https://zoom.us/download/vdi/5.11.9.21750/ZoomCitrixHDXMediaPlugin.msi","C:\ZoomCitrixHDXMediaPlugin.msi")
Start-Process msiexec.exe -Wait -ArgumentList '/I C:\ZoomCitrixHDXMediaPlugin.msi /quiet'
