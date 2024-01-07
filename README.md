# WFX-S3 : Total Commander S3 plugin

[![GitHub releases](https://img.shields.io/github/downloads/woutervannifterick/wfx-s3-wvn/total.svg)](https://github.com/woutervannifterick/wfx-s3-wvn/releases)
[![Issues open](https://img.shields.io/github/issues/woutervannifterick/wfx-s3-wvn.svg)](https://github.com/woutervannifterick/wfx-s3-wvn/issues)
[![Issues closed](https://img.shields.io/github/issues-closed/woutervannifterick/wfx-s3-wvn.svg)](https://github.com/woutervannifterick/wfx-s3-wvn/issues?q=is%3Aissue+is%3Aclosed)
[![License](https://img.shields.io/github/license/woutervannifterick/wfx-s3-wvn.svg)](https://github.com/woutervannifterick/wfx-s3-wvn/blob/master/LICENSE)

![AWS](https://img.shields.io/badge/S3-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)
![WFX](https://img.shields.io/badge/WFX-%23666688.svg?style=for-the-badge)
![Delphi](https://img.shields.io/badge/Delphi-%23EE1F35.svg?style=for-the-badge&logo=delphi&logoColor=white)

### What is this?
This is a free [Total Commander](https://www.ghisler.com/) FileSystem (WFX) plugin.

It lets you browse and manage files in your [Amazon S3 buckets](https://aws.amazon.com/s3/).

Get it here: [Downloads](https://github.com/WouterVanNifterick/wfx-s3-wvn/tags)

#### What is S3?
S3 is a cloud storage service provided by Amazon Web Services (AWS). 
For small amounts of data, it's free. For larger amounts, it's very cheap. It can be used to store backups, or to host static websites.

#### What is Total Commander?
Total Commander is a file manager for Windows. It's a great tool for power users, and it's highly customizable.


# Features

* Browse, create, delete, upload, download, rename, copy, and move files and folders.
* Pick bucket from a list of all your buckets.
* Pick an AWS account
* Directly copy/move files between two S3 buckets

### Why use this plugin?
This plugin is:
* **Free**, open source, has no ads or tracking, and doesn't try to sell you anything.
* It's a native plugin, so it's fast, lightweight, and doesn't need any frameworks or additional software to be installed.
* It doesn't only let you browse, but also lets you create, delete, upload, download, rename, copy, and move files and folders.
* It's easy to use. You can use it without having to learn any new commands.

And of course, it's awesome being able to browse your S3 buckets from within Total Commander. 😎

# Installation

### Prerequisites
* [This plugin](https://github.com/WouterVanNifterick/wfx-s3-wvn/tags)
* [Total Commander](https://www.ghisler.com/)
* [An Amazon Web Services (AWS) account](https://aws.amazon.com/). <br>
  *Note: having S3 buckets are optional, as you can create them from within the plugin.*


#### Automatic installation (recommended)
  
  Using Total Commander, locate the downloaded .zip file and open it.<br />
  Total Commander will ask you if you want to install the plugin.

#### Manual installation
<details><summary><i>In case you want more control: (click to expand)</i></summary>
  1. Extract the contents of the .zip file to a folder of your choice.
  2. In Total Commander, open the Options dialog (menu Configuration -> Options).
  3. Go to the "Plugins" page.
  4. Click the "Configure" button next to the "File system plugins (WFX)" field.
  5. Click "Add" and browse to the folder where you extracted the .zip file.
  6. Select the file "wfx_s3_wvn.wfx64" and click "OK".
  7. Click "OK" to close the "Configure plugins" dialog.
</details>


# Usage

### Start using the plugin
1. Installed the plugin. [See installation](#installation)
2. Open the plugin: 
     - <kbd>Alt+F1</kbd>, then <kbd> \ </kbd>. (Network Neighborhood)
     - Select "S3" from the list.
3. Connect to S3
   - The plugin will automatically attempt to use your default AWS credentials.
   - If you have multiple AWS accounts, you can select the account to use from the list.
4. Pick one of your buckets from the list.

5. You can now browse, create, delete, upload, download, rename, copy, and move files and folders.

### Copy/move files between two S3 buckets
To copy/move files between two S3 buckets, open another instance of the plugin on the other pane and select the other bucket.

### Change AWS account
To change the AWS account, go up to the parent folder.
There's a "file" called `[PICK AWS PROFILE]`. When you open it, you'll see a list of all your AWS accounts.
Select the account you want.

### Download/upload files
To download a file, make sure to have S3 opened in one pane, and a local drive on the other.
Select the files you want to copy or move, and press <kbd>F5</kbd> or <kbd>F6</kbd> to copy or move them.

### Creating a new bucket
To create a new bucket, go up to the parent folder, and press F7.
Enter the name of the bucket you want to create, and press enter.
It'll create a button, which is "private" by default.
For now, if you want to change the permissions, you'll have to do that in the [AWS console](https://s3.console.aws.amazon.com/s3/home)

### Deleting a bucket
To delete a bucket, go up to the parent folder, and press <kbd>F8</kbd>.
It'll ask you to confirm the deletion. Watch out, because this is irreversible!

# Roadmap
* [x] Browsing a bucket
* [x] Picking from a list of **buckets**
* [x] Picking from a list of **AWS accounts**
* [x] **Uploading/downloading** files
* [x] Creating/deleting **buckets**
* [x] Renaming files
* [x] Copying/moving files between **two S3 buckets**
* [x] Deleting files
* [ ] Deleting folders
* [ ] Setting permissions
* [ ] Setting / Viewing metadata
* [ ] Viewing object version history

# Support
This plugin was mainly built to scratch my own itch, in my spare time. 
I'm sharing it for free because I thought somebody else might find it useful.

The more positive feedback I get, the more motivated I am to improve it.

### Found a bug, or want to request a feature?

1. Preferred option: 
    1. Fork this repository
    1. Fix the bug/implement the improvement
    1. Create a pull request
1. Alternative:
    1. Create an issue on GitHub.
    1. Wait for me to fix it/implement it.
    1. To speed things up: [convince](https://patreon.com/WoutervanNifterick) my wife that I should spend more time on this, and less on social activities and household chores. 😅
