*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images..
Library           RPA.Browser.Selenium    auto_close=${True}
Library           RPA.HTTP
Library           RPA.Tables
Library           RPA.Windows
Library           RPA.Desktop
Library           RPA.PDF
Library           RPA.Archive
Library           RPA.Dialogs
Library           RPA.Robocorp.Vault

*** Tasks ***

Order robots from RobotSpareBin Industries Inc
    Input CSV link
    Open the robot order website
    Download the orders list    ${result.csv}
    Read csv file
    FOR    ${table}    IN    @{tables}
        Fill the form    ${table}    ${table}[Body]    ${table}[Head]
        Preview Robot
        Wait Until Keyword Succeeds    5x    1 sec    Order robot
        ${pdf}=    Export order to PDF    ${table}[Order number]
        ${screenshot}=    Store the receipt as a PDF file    ${table}[Order number]
        Create pdf    ${pdf}    ${screenshot}    ${table}[Order number]
        Order Another Robot     
    END
        Archive Folder With Zip    ${OUTPUT_DIR}${/}pdfs    ${OUTPUT_DIR}${/}receipts.zip


*** Keywords ***
Open the robot order website
    ${secret}=    Get Secret    credentials
    Log    VAULT:${secret}[URL Order]    console=True
    Open Available Browser    ${secret}[URL Order]
    Click Button    xpath://*[@id="root"]/div/div[2]/div/div/div/div/div/button[1] 
    
Download the orders list
    [Arguments]    ${csv_URL}
    Download    ${csv_URL}   overwrite=True

Read csv file
    ${tables}    Read table from CSV    orders.csv    header=True
    Set Global Variable    ${tables}

Fill the form
    [Arguments]    ${str}    ${value}    ${head}
    Input Text    address    ${str}[Address]
    Input Text   xpath://html/body/div/div/div[1]/div/div[1]/form/div[3]/input    ${str}[Legs]
    Click Element    xpath://*[@id="id-body-${value}"]
    Select From List By Value    xpath://*[@id="head"]   ${head}

Preview Robot
    Click Button    preview

Order robot
    Click Button    order
    Element Should Be Visible    receipt

Order Another Robot
    Click Button    order-another
    Click Button    xpath://*[@id="root"]/div/div[2]/div/div/div/div/div/button[1] 

Export order to PDF
    [Arguments]    ${order_number}
    Wait Until Element Is Visible    id:receipt
    ${order_results}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${order_results}    ${OUTPUT_DIR}${/}receipts${/}${order_number}.pdf

Store the receipt as a PDF file
    [Arguments]    ${order_number}
    ${order_screenshot}=    Capture Element Screenshot    id:robot-preview-image    ${OUTPUT_DIR}${/}receipts${/}${order_number}.png

Create pdf
    [Arguments]    ${pdf}    ${screenshot}    ${order_number}
    ${files}=    Create List
    ...    ${OUTPUT_DIR}${/}receipts${/}${order_number}.pdf
    ...    ${OUTPUT_DIR}${/}receipts${/}${order_number}.png
    Add Files To PDF    ${files}    ${OUTPUT_DIR}${/}pdfs${/}${order_number}.pdf

Input CSV link
    Add heading    Please insert csv URL
    Add text input    csv    label=CSV URL    placeholder=Default URL:https://robotsparebinindustries.com/orders.csv
    ${result}=    Run dialog
    Set Global Variable    ${result}


    