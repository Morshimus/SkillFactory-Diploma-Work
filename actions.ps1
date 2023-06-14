Set-alias tf terraform
function init {
    Param ( 
     [Parameter(Mandatory=$false, Position=0)]
     [switch]$reconfigure,
     [Parameter(Mandatory=$false, Position=0)]
     [switch]$upgrade 
     )

    $path = (Get-Location).path -replace "\\", "\\"
    $state = Get-Content  "$path\\..\\Skillfactory-B5.3.7-lemp-terraform-yc\\S3_BUCKET\\terraform.tfstate"
    $table = $state | ConvertFrom-Json
    
    $S3_NAME = $table.outputs.bucket_name.value
    $S3_SECRET_KEY = $table.outputs.secret_key.value
    $S3_ACCESS_KEY = $table.outputs.access_key.value
    
    if($reconfigure){
    terraform init -reconfigure `
    --backend-config=bucket=$($S3_NAME) `
    --backend-config=secret_key=$($S3_SECRET_KEY) `
    --backend-config=access_key=$($S3_ACCESS_KEY)
    }elseif($upgrade){
    terraform init -upgrade `
    --backend-config=bucket=$($S3_NAME) `
    --backend-config=secret_key=$($S3_SECRET_KEY) `
    --backend-config=access_key=$($S3_ACCESS_KEY)
    }else{
    terraform init `
    --backend-config=bucket=$($S3_NAME) `
    --backend-config=secret_key=$($S3_SECRET_KEY) `
    --backend-config=access_key=$($S3_ACCESS_KEY)
    }
}

function apply {
    param (
        [Parameter(Mandatory=$false, Position=0)]
        [switch]$withoutApprov 
    )
    
    if($withoutApprov){
     terraform apply `
     -var-file="input.tfvars" 
    }else{
     terraform apply `
     -var-file="input.tfvars" `
     -auto-approve       
    }
}

function destroy {
    param (
        [Parameter(Mandatory=$false, Position=0)]
        [switch]$withoutApprov 
    )
    
    if($withoutApprov){
     terraform destroy `
     -var-file="input.tfvars" 
    }else{
     terraform destroy `
     -var-file="input.tfvars" `
     -auto-approve       
    }
}

function plan {
    param (
        [Parameter(Mandatory=$false, Position=0)]
        [switch]$out 
    )
    
    if($out){
     terraform plan `
     -var-file="input.tfvars" `
     -out="/plantf"
    }else{
     terraform plan `
     -var-file="input.tfvars"        
    }
}

function rebuild {    
    destroy ; if($?) {Wait-Event -Timeout 5; apply}
}


function ansible {
    param (
        [Parameter(Mandatory=$False)]
        [string]$distr = "Ubuntu-20.04",
        [Parameter(Mandatory=$False)]
        [String]$user = "morsh92",
        [Parameter(Mandatory=$False)]
        [String]$server = "lemp",
        [Parameter(Mandatory=$False)]
        [String]$invFile = "./yandex_cloud.ini",
        [Parameter(Mandatory=$False)]
        [String]$privateKey = "~/.ssh/morsh_server_SSH",
        [Parameter(Mandatory=$False,Position=0)]
        [String]$args
    )
    wsl -d $distr -u $user -e ansible $server --inventory-file "$invFile" --private-key $privateKey $args
} 

Set-Alias ansible-playbook ansiblePlaybook
function ansiblePlaybook {
    param (
        [Parameter(Mandatory=$False)]
        [string]$distr = "Ubuntu-20.04",
        [Parameter(Mandatory=$False)]
        [String]$user = "morsh92",        
        [Parameter(Mandatory=$False)]
        [String]$invFile = "./yandex_cloud.ini",
        [Parameter(Mandatory=$False)]
        [String]$privateKey = "~/.ssh/morsh_server_SSH",
        [Parameter(Mandatory=$False)]
        [String]$Playbook = "./provisioning.yaml",
        [Parameter(Mandatory=$False,Position=0)]
        [string]$fileSecrets = '~/.vault_pass_B11',
        [Parameter(Mandatory=$False,Position=0)]
        [switch]$tagTST,
        [Parameter(Mandatory=$False,Position=0)]
        [switch]$tagPRD,
        [Parameter(Mandatory=$False,Position=0)]
        [switch]$secret
    )

    if($secret){$params='-e';$secrets = '@secrets.yml'}

    if($tagTST){$param='--tags';$tag = "test"}elseif($tagPRD){$param='--tags';$tag = "production"}

    wsl -d $distr -u $user -e ansible-playbook  -i "$invFile" --private-key $privateKey $params $secrets --vault-password-file=$fileSecrets  $Playbook  $param $tag
} 

Set-Alias ansible-vault ansibleVault
function ansibleVault {
    param (
        [Parameter(Mandatory=$False)]
        [string]$distr = "Ubuntu-20.04",
        [Parameter(Mandatory=$False)]
        [String]$user = "morsh92",
        [Parameter(Mandatory=$False,Position=0)]
        [String]$action = 'encrypt',
        [Parameter(Mandatory=$False,Position=0)]
        [String]$file = 'secrets.yml',
        [Parameter(Mandatory=$False,Position=0)]
        [switch]$ask,
        [Parameter(Mandatory=$False,Position=0)]
        [string]$fileSecrets = '~/.vault_pass_B11'

    )
    
    if($ask){$passwd = "--ask-vault-pass"}

    wsl -d $distr -u $user -e ansible-vault $action --vault-password-file=$fileSecrets $passwd $file
} 


Set-Alias ansible-galaxy ansibleGalaxy
function ansibleGalaxy {
    param (
        [Parameter(Mandatory=$False)]
        [string]$distr = "Ubuntu-20.04",
        [Parameter(Mandatory=$False)]
        [String]$user = "morsh92",
        [Parameter(Mandatory=$False,Position=0)]
        [String]$type = 'role',
        [Parameter(Mandatory=$False,Position=0)]
        [String]$action = 'init',
        [Parameter(Mandatory=$False,Position=0)]
        [String]$roleName = 'sample',
        [Parameter(Mandatory=$False,Position=0)]
        [switch]$force,
        [Parameter(Mandatory=$False,Position=0)]
        [string]$roleFile = './requirements.yml',
        [Parameter(Mandatory=$False,Position=0)]
        [string]$rolesPath = './roles'

    )
    
    if($action -like "install"){$roleName ="";$f = "";$instal_params=@("--role-file", $roleFile, "--roles-path", $rolesPath)}
    if($force){$f = '--force'}

    wsl -d $distr -u $user -e ansible-galaxy $type $action $roleName $f $instal_params[0] $instal_params[1] $instal_params[2] $instal_params[3]
} 

 
 function UpdateAnsibleRoles {
    if(!(Test-path ./roles)){mkdir ./roles}
    Remove-Item -Recurse -Force  ./roles; if($?) {ansible-galaxy -action install} else {write-host -f Magenta "Roles directory is not exist, use ansible-galaxy -action install to populate"}
    
 }


 function prompt {

     #Assign Windows Title Text
     $host.ui.RawUI.WindowTitle = "Current Folder: $pwd"

     #Configure current user, current folder and date outputs
     $CmdPromptCurrentFolder = Split-Path -Path $pwd -Leaf
     $CmdPromptUser = [Security.Principal.WindowsIdentity]::GetCurrent();
     $Date = Get-Date -Format 'dddd hh:mm:ss tt'

     # Test for Admin / Elevated
     $IsAdmin = (New-Object Security.Principal.WindowsPrincipal ([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)

     #Calculate execution time of last cmd and convert to milliseconds, seconds or minutes
     $LastCommand = Get-History -Count 1
     if ($lastCommand) { $RunTime = ($lastCommand.EndExecutionTime - $lastCommand.StartExecutionTime).TotalSeconds }

     if ($RunTime -ge 60) {
         $ts = [timespan]::fromseconds($RunTime)
         $min, $sec = ($ts.ToString("mm\:ss")).Split(":")
         $ElapsedTime = -join ($min, " min ", $sec, " sec")
     }
     else {
         $ElapsedTime = [math]::Round(($RunTime), 2)
         $ElapsedTime = -join (($ElapsedTime.ToString()), " sec")
     }

     #Decorate the CMD Prompt
     Write-Host ""
     Write-host ($(if ($IsAdmin) { 'Elevated ' } else { '' })) -BackgroundColor DarkRed -ForegroundColor White -NoNewline
     Write-Host " USER:$($CmdPromptUser.Name.split("\")[1]) " -BackgroundColor DarkBlue -ForegroundColor Magenta -NoNewline
     If ($CmdPromptCurrentFolder -like "*:*")
         {Write-Host " $CmdPromptCurrentFolder "  -ForegroundColor White -BackgroundColor DarkGray -NoNewline}
         else {Write-Host ".\$CmdPromptCurrentFolder\ "  -ForegroundColor Green -BackgroundColor DarkGray -NoNewline}

     Write-Host " $date " -ForegroundColor White
     Write-Host "[$elapsedTime] " -NoNewline -ForegroundColor Green
     return "> "
 }