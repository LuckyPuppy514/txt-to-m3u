echo ""
echo "================================================="
echo "||                                             ||"
echo "|| https://github.com/LuckyPuppy514/txt-to-m3u ||"
echo "|| @LuckyPuppy514                              ||"
echo "|| 2022-10-21                                  ||"
echo "||                                             ||"
echo "================================================="
echo ""

# ���ظ���Ŀ¼
$currentPath = Get-Location;
$path = $currentPath.Path.Replace("\txt-to-m3u", "");
$localPath = Read-Host "��������Ҫɨ���·����Ĭ�ϣ�$path��"
if ($localPath -eq "") {
    $localPath = $path;
}
echo "";

$null = Read-Host "����ɨ�裺$localPath���밴�س�����"
# ���ظ赥
$localListFile = "$currentPath\local.list";
# ����
$encode =[Text.Encoding]::GetEncoding('UTF-8');

date
echo "��ʼɨ��";
echo "ɨ����......";

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

echo "ɨ����ϣ��ܹ� $count ��";
date;
