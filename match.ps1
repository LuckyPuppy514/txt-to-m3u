echo ""
echo "================================================="
echo "||                                             ||"
echo "|| https://github.com/LuckyPuppy514/txt-to-m3u ||"
echo "|| @LuckyPuppy514                              ||"
echo "|| 2022-10-21                                  ||"
echo "||                                             ||"
echo "================================================="
echo ""

# 当前路径
$currentPath = Get-Location;
$path = $currentPath.Path.Replace("txt-to-m3u", "");
$matchParentPath = Read-Host "请输入需要替换的路径（默认：$path）"
echo ""
$replaceParentPath = Read-Host "请输入替换后的路径（回车替换为空）"
if ($matchParentPath -eq "") {
    $matchParentPath = $path;
}
echo ""
$null = Read-Host "【$matchParentPath】 => 【$replaceParentPath】，请按回车继续"
# 本地歌单
$localListFile = "$currentPath\local.list";
# txt歌单目录
$txtPath = "$currentPath\txt\*.txt";
# m3u歌单目录
$m3uPath = "$currentPath\m3u";
# 失败目录
$failPath = "$currentPath\fail";

if(-Not (Test-Path -LiteralPath $localListFile)) {
    echo "";
    echo "文件不存在：$localListFile，请先执行 scan.ps1 扫描";
    exit;
}

# 删除旧数据
if(Test-Path -LiteralPath $m3uPath) {
    $null = Remove-Item -Force -Recurse $m3uPath;
}
if(Test-Path -LiteralPath $failPath) {
    $null = Remove-Item -Force -Recurse $failPath;
}

$localList = Get-Content -Encoding UTF8 $localListFile;
$txtListFiles = dir $txtPath;

foreach ($txtListFile in $txtListFiles) {
    if(Test-Path -LiteralPath $txtListFile) {
        # m3u歌单文件名
        $m3uListFileName = $txtListFile.Name.Replace("lx_list_", "");
        $endIndex = $m3uListFileName.Length - 4;
        $m3uListFileName = "新 - " + $m3uListFileName.subString(0, $endIndex);
        # 创建m3u歌单文件
        $m3uListFile = "$m3uPath\$m3uListFileName.m3u";
        $failListFile = "$failPath\$m3uListFileName.txt";
        $null = New-Item -Force $m3uListFile;
        $null = New-Item -Force $failListFile;
        # 写入头信息
        echo "#EXTM3U" | Out-File -Encoding UTF8 -LiteralPath $m3uListFile;
        # 匹配并转换
        $txtList = Get-Content -Encoding UTF8 -LiteralPath $txtListFile;
        $index = 0;
        foreach ($txt in $txtList ) {
            $song = $txt -Split "\s{2,}";
            $name = $song[0] -replace "\s*[(|（][^)^）]*[)|）]", "";
            $name = $name.trim();
            $artist = $song[1] -replace "[^\w^\u4e00-\u9fa5^ ^\u0800-\u4e00^\xAC00-\xD7A3^\x3130-\x318F].*", "";
            $artist = $artist.trim();
            $isMatch = "fail";
            foreach ($local in $localList) {
                if ($local.Contains($artist)) {
                    $localName = $local.subString($local.LastIndexOf('\') + 1);
                    if($localName.Contains("$name")){
                        echo $local.Replace($matchParentPath, $replaceParentPath).Replace("\", "/") | Out-File -Encoding UTF8 -LiteralPath $m3uListFile -Append;
                        $isMatch = "success";
                        break;
                    }
                }
            }
            # 写入失败清单
            if ($isMatch -eq "fail") {
                echo $txt | Out-File -Encoding UTF8 -LiteralPath $failListFile -Append;
            }
            # 进度条
            $index = $index + 1;
            $percent = "{0:N2}" -f ($index / $txtList.Length * 100);
            Write-Progress -Activity "生成中：$m3uListFileName.m3u" -Status "$percent% Complete" -PercentComplete $percent;
        }
        if((Get-Item $failListFile).Length -eq 0){
            Remove-Item -Force $failListFile;
        }
        echo "生成完毕：$m3uListFileName.m3u";
    } else {
        echo "找不到文件：$txtListFile"
        continue;
    }
}
