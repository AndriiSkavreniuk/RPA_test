*** Settings ***
Library  SeleniumLibrary
Library  Collections
#Library  RPA.JSON
Library  OperatingSystem


*** Variables ***



*** Test Cases ***
Search function for AIHIT
    [Documentation]  This function for search
    [Tags]  Functional

    Open Browser  https://www.aihitdata.com  chrome
    Maximize Browser Window

    # get cookies
    Sleep  3s
    Click Element  //a[contains(@class, 'accept_all')]


    #authorization
    Click Element  //a[contains(@href, 'login')]
    Input Text  //input[@id="email"]  <your login>
    Input Password  //input[@id="password"]  <your password>
    Press Keys  //input[@id="submit"]  [Return]

    #search company
    Page Should Contain  The Company Database
    Input Text  //input[@id="industry"]  mortgage
    Input Text  //input[@id="location"]  USA
    Press Keys  //button[@type='submit']  [RETURN]

    #skip ads from google (advertising)
    Click Element  (//a[contains(@href, 'company')])[1]
    ${Frame_1}=  Run Keyword And Return Status  Page Should Contain Element  id:aswift_3
    IF  '${Frame_1}'=='True'
    Select Frame  id:aswift_3
    ${Button}=  Run Keyword And Return Status  Page Should Contain Element  id:dismiss-button
    ELSE IF  '${Button}'=='True'
    Click Element  id:dismiss-button
    ELSE
    Select Frame  id:ad_iframe
    Click Element  id:dismiss-button
    END
    Unselect Frame
    Go Back

    #start skraping info
    ${list_of_values}=  Create Dictionary
    FOR  ${i}  IN RANGE  ${1}  ${31}
        Sleep  3s
        Scroll Element Into View  (//a[contains(@href, 'company')])[${i}]
        Wait Until Element Is Visible  (//a[contains(@href, 'company')])[${i}]
        Sleep  1s
        Click Element  (//a[contains(@href, 'company')])[${i}]
        ${NAME}=  Get Text  //h1[@class='text-info']
        ${values}=  Create Dictionary  NAME  ${NAME}
        ${WEBSITE}=  Get Text  //span[@class='text-success']/ancestor::a
        Set To Dictionary  ${values}  WEBSITE  ${WEBSITE}
        ${Result_Adress}=  Run Keyword And Return Status  Page Should Contain Element  //i[contains(@class, 'icon-map-marker')]/ancestor::div[@class='text-muted']
        IF  '${Result_Adress}'=='True'
        ${ADRESS}=  Get Text  //i[contains(@class, 'icon-map-marker')]/ancestor::div[@class='text-muted']
        Set To Dictionary  ${values}  ADRESS  ${ADRESS}
        ELSE
        Set To Dictionary  ${values}  ADRESS  None
        END
        ${Result_Email}=  Run Keyword And Return Status  Page Should Contain Element  //i[contains(@class, 'icon-email')]/ancestor::li/a
        IF  '${Result_Email}'=='True'
        ${EMAIL}=  Get Text  //i[contains(@class, 'icon-email')]/ancestor::li/a
        Set To Dictionary  ${values}  EMAIL  ${EMAIL}
        ELSE
        Set To Dictionary  ${values}  EMAIL  None
        END
        ${Result_Phone}=  Run Keyword And Return Status  Page Should Contain Element  //i[contains(@class, 'icon-phone')]/ancestor::li
        IF  '${Result_Phone}'=='True'
        ${PHONE}=  Get Text  //i[contains(@class, 'icon-phone')]/ancestor::li
        Set To Dictionary  ${values}  PHONE  ${PHONE}
        ELSE
        Set To Dictionary  ${values}  PHONE  None
        END
        Set To Dictionary  ${list_of_values}  ${i}  ${values}
        Log  ${list_of_values}
        Go Back
    END
    Log  ${list_of_values}
    ${list_of_company}=  Evaluate  json.dumps(${list_of_values})  json
    Create Binary File  /home/andrii/PycharmProjects/RPA_test/results_json/list_of_company.json  ${list_of_company}
#    Save JSON to file  ${list_of_values}  list_of_company.json   ### another way to save json

    #close browser
    Close Browser

*** Keywords ***


