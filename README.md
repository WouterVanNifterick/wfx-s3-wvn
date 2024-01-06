# wfx-s3-wvn
Total commander WFX plugin: S3

[![GitHub releases](https://img.shields.io/github/downloads/woutervannifterick/wfx-s3-wvn/total.svg)](https://github.com/woutervannifterick/wfx-s3-wvn/releases)
[![Issues open](https://img.shields.io/github/issues/woutervannifterick/wfx-s3-wvn.svg)](https://github.com/woutervannifterick/wfx-s3-wvn/issues)
[![Issues closed](https://img.shields.io/github/issues-closed/woutervannifterick/wfx-s3-wvn.svg)](https://github.com/woutervannifterick/wfx-s3-wvn/issues?q=is%3Aissue+is%3Aclosed)
[![License](https://img.shields.io/github/license/woutervannifterick/wfx-s3-wvn.svg)](https://github.com/woutervannifterick/wfx-s3-wvn/blob/master/LICENSE)


# Description
This plugin allows you to browse and manage files in your Amazon S3 bucket, via [Total Commander](https://www.ghisler.com/).

# Features

* Browse, create, delete, upload, download, rename, copy, and move files and folders.
* Pick bucket from a list of all your buckets.
* Pick an AWS account
* Directly copy/move files between two S3 buckets

# Installation
#### Automatic (recommended)
  
  Using Total Commander, locate the downloaded .zip file and open it.<br />
  Total Commander will ask you if you want to install the plugin.

#### Manual
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
1. In Total Commander, open the Network Neighborhood.
      - Using keyboard: <kbd>Alt+F1</kbd>, then <kbd> \ </kbd>
2. Select "S3" from the list.
3. The plugin will automatically attempt to use your default AWS credentials.
      - If you have multiple AWS accounts, you can select the account to use from the list.
4. You'll now see a list of your S3 buckets.
5. Select a bucket to browse its contents.
6. You can now browse, create, delete, upload, download, rename, copy, and move files and folders.

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

### Prerequisites
* Total Commander
* An Amazon Web Services (AWS) account
* An S3 bucket
