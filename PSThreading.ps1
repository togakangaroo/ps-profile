function global:New-Thread
{
    $config   = [System.Management.Automation.Runspaces.Runspace]::DefaultRunspace.RunspaceConfiguration
    $runspace = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspace($config)
    $thread   = New-Object System.Object
    
        $thread = $thread | Add-Member NoteProperty "Runspace" $runspace -passThru
        $thread = $thread | Add-Member NoteProperty "Pipeline" $null -passThru        
        $thread = $thread | Add-Member ScriptProperty "Running" { return ($this.Pipeline -ne $null -and (-not $this.Pipeline.Error.EndOfPipeline -or -not $this.Pipeline.Output.EndOfPipeline)) } -passThru

    $thread.Runspace.Open()
    
    return $thread
}

function global:Start-Thread
{
    param
    (
        [object]      $thread      = $null,
        [ScriptBlock] $scriptBlock = $(throw "The parameter -scriptBlock is required.")
    )
    
    if ($thread -eq $null)
    {
        $thread = New-Thread
    }
    
    if ($thread.Running)
    {
        throw "The thread is already running, please wait for it complete before trying again."
    }
    
    $thread.Pipeline = $thread.Runspace.CreatePipeline($scriptBlock)
    $thread.Pipeline.Input.Close()
    $thread.Pipeline.InvokeAsync()
    
    return $thread
}

function global:Stop-Thread
{
    param
    (
        [object] $thread = $(throw "The parameter -thread is required.")
    )
    
    if ($thread.Pipeline -ne $null)
    {
        if ($thread.Pipeline.PipelineStateInfo.State -eq "Running")
        {
            $thread.Pipeline.StopAsync()
        }
    }
}

function global:Read-Thread
{
    param
    (
        [object] $thread = $(throw "The parameter -thread is required.")
    )
    
    if ($thread.Pipeline -ne $null)
    {
        $thread.Pipeline.Error.NonBlockingRead() |% { Write-Error $_ }
        $thread.Pipeline.Output.NonBlockingRead() |% { Write-Output $_ }
    }
}

function global:Join-Thread
{
    param
    (
        [object] $thread = $(throw "The parameter -thread is required.")
    )
    
    if ($thread.Pipeline -ne $null)
    {
        while ($true)
        {
            Read-Thread -thread $thread
            
            if ($thread.Pipeline.Error.EndOfPipeline -and $thread.Pipeline.Output.EndOfPipeline)
            {
                break
            }
            
            $thread.Pipeline.Output.WaitHandle.WaitOne(250, $false) | Out-Null
        }
        
        Stop-Thread $thread
        
        if ($thread.Pipeline.PipelineStateInfo.State -eq "Failed")
        {
            throw $thread.Pipeline.PipelineStateInfo.Reason
        }
    }
}