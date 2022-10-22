echo ""
echo "================================================="
echo "||                                             ||"
echo "|| https://github.com/LuckyPuppy514/txt-to-m3u ||"
echo "|| @LuckyPuppy514                              ||"
echo "|| 2022-10-21                                  ||"
echo "||                                             ||"
echo "================================================="
echo ""

# 本地歌曲目录
$currentPath = Get-Location;
$path = $currentPath.Path.Replace("\txt-to-m3u", "");
$localPath = Read-Host "请输入需要扫描的路径（默认：$path）"
if ($localPath -eq "") {
    $localPath = $path;
}
echo "";

$null = Read-Host "即将扫描：$localPath，请按回车继续"
# 本地歌单
$localListFile = "$currentPath\local.list";
# 编码
$encode =[Text.Encoding]::GetEncoding('UTF-8');

date
echo "开始扫描";
echo "扫描中......";

if(Test-Path -LiteralPath $localListFile) {
    $null = Remove-Item -Force $localListFile;
}
$null = New-Item -Force $localListFile;
$writer = New-Object System.IO.StreamWriter($localListFile, $encode);

$length = $localPath.Length + 1;
$count = 0;

$dirs = dir $localPath |
Where-Object { 
    $_ -is [System.IO.DirectoryInfo] -and $_.Name -ne 'txt-to-m3u'
}
foreach ($dir in $dirs){
    $null = dir -s $dir.FullName |
    Where-Object { 
        $_ -is [System.IO.FileInfo] -and $_.Extension -eq '.flac';
    } |
    Foreach-Object {
        $writer.WriteLine($_.FullName.Replace("\", "/"));
        $writer.Flush();
        $count = $count + 1;
    }
}
$writer.Close();

echo "扫描完毕，总共 $count 条";
date;
