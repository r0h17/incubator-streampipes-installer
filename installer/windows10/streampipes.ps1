﻿# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

if ($args.Count -lt 1)
{
    Write-Host "Use 'streampipes start' to start StreamPipes, 'streampipes stop' to stop it, and 'streampipes clean' to remove streampipes."
}

$env:COMPOSE_CONVERT_WINDOWS_PATHS = 1
$currentDir = Split-Path -parent $MyInvocation.MyCommand.Definition
$envFileTemp = $currentDir + "/../templates/.env"
$envFileDest = $currentDir + "/.env"
$dockerComposeFullTemp = $currentDir + "/../templates/docker-compose.full.yml"
$dockerComposeLiteTemp = $currentDir + "/../templates/docker-compose.lite.yml"
$dockerCompose = $currentDir + "/docker-compose.yml"
$configFolder = $currentDir + "/config"

function Show-Menu
{
	 Write-Host "StreamPipes can be started in two different setups:"
	 Write-Host ""
     Write-Host "1: StreamPipes Lite (few pipeline elements, needs less memory)"
     Write-Host "2: StreamPipes Full (more pipeline elements, requires > 16 GB RAM)"
     Write-Host "Q: Press 'Q' to quit."
}


if ($args[0] -eq "start")
{

	Write-Host ' _______ __                              ______ __                    '
	Write-Host '|     __|  |_.----.-----.---.-.--------.|   __ \__|.-----.-----.-----.'
	Write-Host '|__     |   _|   _|  -__|  _  |        ||    __/  ||  _  |  -__|__ --|'
	Write-Host '|_______|____|__| |_____|___._|__|__|__||___|  |__||   __|_____|_____|'
	Write-Host '                                                   |__|'
	Write-Host ''
	Write-Host 'Welcome to StreamPipes!'
	Write-Host ''

	if (!(Test-Path  ($dockerCompose)))
	{
		do
		{
			 Show-Menu
			 $input = Read-Host "Please make a selection"
			 switch ($input)
			 {
				   '1' {
						$version="Lite"
						break

				   } '2' {
						$version="Full"
						break
				   }
			 }
			 pause
		}
		until (($input -eq '1') -Or ($input -eq '2'))

    Write-Host "Selected StreamPipes option: $version"

    Write-Host "Configuring StreamPipes $version"

		Copy-Item $envFileTemp -Destination $envFileDest
		if ($version -eq "Lite")
		{
			Copy-Item $dockerComposeLiteTemp -Destination $dockerCompose
		}
		if ($version -eq "Full")
		{
			Copy-Item $dockerComposeFullTemp -Destination $dockerCompose
		}
	}


    Invoke-Expression "docker-compose -f $dockerCompose pull"
    Invoke-Expression "docker-compose -f $dockerCompose up -d"

    if ($LASTEXITCODE -eq 0)
    {
        Write-Host
        Write-Host
        Write-Host "INFO: StreamPipes is now ready to be used on your system"
        Write-Host "      Check https://streampipes.apache.org/ for information on StreamPipes"
        Write-Host
        Write-Host "      Go to the UI and follow the instructions to get started: http://localhost/ (or the hostname of the server)"
        Write-Host
    }
    else
    {
        Write-Host "ERROR: There was a problem while starting StreamPipes"
    }
}

if ($args[0] -eq "stop" -Or $args[0] -eq "clean")
{
	if ($args[0] -eq "stop")
    {
    Invoke-Expression "docker-compose -f $dockerCompose stop"
    Invoke-Expression "echo y | docker-compose -f $dockerCompose down"

    Write-Host "StreamPipes successfully stopped"
	}

    if ($args[0] -eq "clean")
    {
		Invoke-Expression "echo y | docker-compose -f $dockerCompose down -v"
        Remove-Item $envFileDest
        Remove-Item $dockerCompose

        Write-Host "All StreamPipes system information was deleted. The system can now be installed again."
    }
}
