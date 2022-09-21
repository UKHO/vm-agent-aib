$dateLine = (Get-Date).AddMonths(-1)
$list = (az sig image-version list -g $(imageResourceGroup) -r $(sharedImageGalleryName) -i $(imageDefName) -o json | ConvertFrom-Json)
$splice = $list | Select-Object -Skip 4
foreach($item in $splice) {
    $publishedDate = Get-Date($item.publishingProfile.publishedDate)
    if($publishedDate -lt $dateLine) {
      $item.name
      Start-Job -ScriptBlock {param($imagename) az sig image-version delete -g $(imageResourceGroup) -r $(sharedImageGalleryName) -i $(imageDefName) -e $imagename} -ArgumentList @($($item.name))
    }
}