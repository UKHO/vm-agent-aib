# Ubuntu Agent VM image [![Build Status](https://ukhogov.visualstudio.com/Digital%20Operations/_apis/build/status/UKHO.vm-agent-aib?branchName=master)](https://ukhogov.visualstudio.com/Digital%20Operations/_build/latest?definitionId=180&branchName=master)

Uses the [Azure Image Builder](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/image-builder-overview) to create an image for the UKHO flavour Ubuntu Agents which is  distributed to a [shared image gallery](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/shared-image-galleries).

The finished image contains the following:

- Base dependencies (docker, maven etc.)
- A version of the Azure Pipelines agent
- The latest version of the [VM Drainer](https://github.com/UKHO/AzDoAgentDrainer)

> **N.B.** [Azure Image Builder](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/image-builder-overview) is in preview and restricted to certain regions. This means the image is built in the UK West and then replicated to UK South.

## Creating the image

The build associated with this repo "orchestrates" the creation of the image. It adds the json configuration to Azure as a resource, ensures it runs and deletes the configuration afterwards. It additionally replaces variables within the json configuration.

The build is also triggered by the completion of the [drainer](https://github.com/UKHO/AzDoAgentDrainer) build.

## Editing the image

### Add a new resource

> These instructions only refer to the shell script customizer. [Other customizers are available](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/image-builder-json#properties-customize)

- Add a new shell script in [ubuntu-agent-vm/scripts](ubuntu-agent-vm/scripts) that installs the resource
  - Give the script a descriptive name
  - Ensure you ONLY affect one resource. Do not create a script that adds multiple resources.
- Add the script to the `customize` array of  [ubuntu-agent-vm-aib.json](ubuntu-agent-vm/ubuntu-agent-vm-aib.json) following the same pattern as the other shell scripts
  - These scripts are executed in order. If you have a dependency on a earlier resource, your script must be after that resource
- Push changes as a PR
- On merge to master, a new image is built and distributed. This takes approximently 45 minutes
- DDC will then update the agents to use the new image, this will take up to half an hour.

### Edit an exisiting resource

- Find and update the relevant shell script under [ubuntu-agent-vm/scripts](ubuntu-agent-vm/scripts)
- Make changes and push as a PR
- On merge to master, a new image is built and distributed. This takes approximently 45 minutes
- DDC will then update the agents to use the new image, this will take up to half an hour.

## Deploying/Moving the Image Builder in a subscription

> These instructions are borrowed liberally from the [Image Builder Overview](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/image-builder-overview).

For AIB to create images, configuration is required. This should only need to be done if the images need to be built in a new subscription or the images added to a different resource group.

### Enable AIB for the subscription

> Needs to be done whilst AIB is in preview

```powershell
# Add the feature to the subscription
az account set --subscription $subscriptionID
az feature register --namespace Microsoft.VirtualMachineImages --name VirtualMachineTemplatePreview

# Wait for the feature state to show as registered. This can take 10 mins.
az feature show --namespace Microsoft.VirtualMachineImages --name VirtualMachineTemplatePreview

# Check if VMI is registered and if not, register it
az provider show -n Microsoft.VirtualMachineImages
az provider register -n Microsoft.VirtualMachineImages

# Check if Storage is registered and if not, register it.
az provider register -n Microsoft.Storage
az provider register -n Microsoft.Storage
```

### Add the Image Builder application to a resource group

AIB requires contributor rights for the resource group where the image will **end up**. If AIB does not have these permissions, then it will be unable to add the completed image to the resource group. The GUID below is the ID of the Image Builder application.

```powershell
az role assignment create \
    --assignee cf32a0cc-373c-47c9-9156-0db11f6a6dfc \
    --role Contributor \
    --scope /subscriptions/$subscriptionID/resourceGroups/$imageResourceGroup
```
