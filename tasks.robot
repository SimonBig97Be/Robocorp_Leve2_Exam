*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.
Library    RPA.Browser.Selenium    auto_close=${False}
Library    RPA.HTTP
Library    RPA.Excel.Files
Library    RPA.Tables
Library    RPA.PDF
Library    RPA.Desktop
Library    RPA.Archive
Library    RPA.FileSystem

*** Variables ***
${PDF_TEMP_OUTPUT_DIRECTORY}=       ${CURDIR}${/}temp

*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Set up directories
    Open the robot order website
    ${orders}    Get orders
    Close the annoying modal
    Fill the form    ${orders}
    Store the order receipt as a PDF
    Take a screenshot of the robot image
    Embed the robot screenshot to the receipt PDF file
    Create ZIP package from PDF files
    [Teardown]    Close the browser

*** Keywords ***
Set up directories
    Create Directory    ${PDF_TEMP_OUTPUT_DIRECTORY}
Open the robot order website
    #ToDo: Implement your keyword here
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Get orders
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True
    ${table}=    Read table from CSV    orders.csv    dialect=excel
    FOR    ${robot}    IN    @{table}
        Log    ${robot}
    END
    RETURN    ${robot}

Close the annoying modal
    Click Button    Yep

Fill the form
    [Arguments]    ${table_rep}
    Select From List By Value    head    ${table_rep}[Head]
    Select Radio Button    body    ${table_rep}[Body]
    Input Text    css:input[placeholder="Enter the part number for the legs"]    ${table_rep}[Legs]
    Input Text    address    ${table_rep}[Address]
    Click Button    preview
    # Retry three times at half-second intervals.
    Wait Until Keyword Succeeds    10x    0.5 sec    Click Button    order

Store the order receipt as a PDF
    Wait Until Element Is Visible    receipt
    ${sales_results_html}=    Get Element Attribute    receipt    outerHTML
    Html To Pdf    ${sales_results_html}    ${OUTPUT_DIR}${/}receipt.pdf

Take a screenshot of the robot image
    Wait Until Element Is Visible    robot-preview
    Screenshot    robot-preview    robot.png

Embed the robot screenshot to the receipt PDF file
    Add Watermark Image To PDF
    ...    image_path=robot.png
    ...    source_path=output/receipt.pdf
    ...    output_path=temp/robotReceipt.pdf
    
Create ZIP package from PDF files
    ${zip_file_name}=    Set Variable    ${OUTPUT_DIR}/PDFsRobotReceipt.zip
    Archive Folder With Zip
    ...    ${PDF_TEMP_OUTPUT_DIRECTORY}
    ...    ${zip_file_name}

Close the browser
    Close Browser

    
