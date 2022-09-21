param(
    $imageResourceGroup,
    $sharedImageGalleryName,
    $imageDefName
)

$dateLine = (Get-Date).AddMonths(-1)
$list = (az sig image-version list -g $imageResourceGroup -r $sharedImageGalleryName -i $imageDefName -o json | ConvertFrom-Json)
$splice = $list | Select-Object -Skip 4
foreach($item in $splice) {
    $publishedDate = Get-Date($item.publishingProfile.publishedDate)
    if($publishedDate -lt $dateLine) {
      $item.name
      Start-Job -ScriptBlock {param($rg, $gallery,$imagedef,$imagename) az sig image-version delete -g $rg -r $gallery -i $imagedef -e $imagename} -ArgumentList @($imageResourceGroup, $sharedImageGalleryName,$imageDefName,$($item.name))
    }
}