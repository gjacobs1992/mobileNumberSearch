Add-Type -AssemblyName System.Windows.Forms

# Create form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Mobile Number Search"
$form.Width = 400
$form.Height = 250
$form.StartPosition = "CenterScreen"

# Create controls
$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10, 20)
$label.Size = New-Object System.Drawing.Size(150, 20)
$label.Text = "Enter Mobile Number:"

$textbox = New-Object System.Windows.Forms.TextBox
$textbox.Location = New-Object System.Drawing.Point(170, 20)
$textbox.Size = New-Object System.Drawing.Size(150, 20)

$button = New-Object System.Windows.Forms.Button
$button.Location = New-Object System.Drawing.Point(170, 60)
$button.Size = New-Object System.Drawing.Size(100, 30)
$button.Text = "Search"

$richtextbox = New-Object System.Windows.Forms.RichTextBox
$richtextbox.Location = New-Object System.Drawing.Point(10, 100)
$richtextbox.Size = New-Object System.Drawing.Size(350, 100)
$richtextbox.ReadOnly = $true

# Add controls to form
$form.Controls.Add($label)
$form.Controls.Add($textbox)
$form.Controls.Add($button)
$form.Controls.Add($richtextbox)

# Add button click event
$button.Add_Click({
    ExecuteSearch
})

# Add key press event for text box
$textbox.Add_KeyPress({
    if ($_.KeyChar -eq [char]13) {
        ExecuteSearch
    }
})

# Function to execute the search
function ExecuteSearch {
    $mobileNumber = $textbox.Text

    if ($mobileNumber -eq 'exit') {
        $form.Close()
    }

    $cleanedInputMobileNumber = $mobileNumber -replace '\D', ''
    $users = Get-ADUser -Filter * -Properties DisplayName, SamAccountName, Mobile, mail |
        Where-Object { $_.Mobile -replace '\D', '' -eq $cleanedInputMobileNumber }

    $richtextbox.Clear()

    if ($users) {
        foreach ($user in $users) {
            $formattedMobileNumber = '{0:(###) ###-####}' -f $user.mobile
            $output = "User found:`nDisplay Name: $($user.DisplayName)`nUsername: $($user.SamAccountName)`nMobile Phone: $formattedMobileNumber`nEmail: $($user.mail)`n-----------------------"
            $richtextbox.AppendText($output)
        }
    } else {
        $richtextbox.AppendText("No users with mobile phone number $mobileNumber found.")
    }
}

# Show the form
$form.ShowDialog()
