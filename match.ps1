echo ""
echo "================================================="
echo "||                                             ||"
echo "|| https://github.com/LuckyPuppy514/txt-to-m3u ||"
echo "|| @LuckyPuppy514                              ||"
echo "|| 2022-10-21                                  ||"
echo "||                                             ||"
echo "================================================="
echo ""

# ��ǰ·��
$currentPath = Get-Location;
$path = $currentPath.Path.Replace("txt-to-m3u", "");
$matchParentPath = Read-Host "��������Ҫ�滻��·����Ĭ�ϣ�$path��"
echo ""
$replaceParentPath = Read-Host "�������滻���·�����س��滻Ϊ�գ�"
if ($matchParentPath -eq "") {
    $matchParentPath = $path;
}
echo ""
$null = Read-Host "��$matchParentPath�� => ��$replaceParentPath�����밴�س�����"
# ���ظ赥
$localListFile = "$currentPath\local.list";
# txt�赥Ŀ¼
$txtPath = "$currentPath\txt\*.txt";
# m3u�赥Ŀ¼
$m3uPath = "$currentPath\m3u";
# ʧ��Ŀ¼
$failPath = "$currentPath\fail";

if(-Not (Test-Path -LiteralPath $localListFile)) {
    echo "";
    echo "�ļ������ڣ�$localListFile������ִ�� scan.ps1 ɨ��";
    exit;
}

# ɾ��������
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
        # m3u�赥�ļ���
        $m3uListFileName = $txtListFile.Name.Replace("lx_list_", "");
        $endIndex = $m3uListFileName.Length - 4;
        $m3uListFileName = "�� - " + $m3uListFileName.subString(0, $endIndex);
        # ����m3u�赥�ļ�
        $m3uListFile = "$m3uPath\$m3uListFileName.m3u";
        $failListFile = "$failPath\$m3uListFileName.txt";
        $null = New-Item -Force $m3uListFile;
        $null = New-Item -Force $failListFile;
        # д��ͷ��Ϣ
        echo "#EXTM3U" | Out-File -Encoding UTF8 -LiteralPath $m3uListFile;
        # ƥ�䲢ת��
        $txtList = Get-Content -Encoding UTF8 -LiteralPath $txtListFile;
        $index = 0;
        foreach ($txt in $txtList ) {
            $song = $txt -Split "\s{2,}";
            $name = $song[0] -replace "\s*[(|��][^)^��]*[)|��]", "";
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
            # д��ʧ���嵥
            if ($isMatch -eq "fail") {
                echo $txt | Out-File -Encoding UTF8 -LiteralPath $failListFile -Append;
            }
            # ������
            $index = $index + 1;
            $percent = "{0:N2}" -f ($index / $txtList.Length * 100);
            Write-Progress -Activity "�����У�$m3uListFileName.m3u" -Status "$percent% Complete" -PercentComplete $percent;
        }
        if((Get-Item $failListFile).Length -eq 0){
            Remove-Item -Force $failListFile;
        }
        echo "������ϣ�$m3uListFileName.m3u";
    } else {
        echo "�Ҳ����ļ���$txtListFile"
        continue;
    }
}
