# WebApp
1. SQLAccount Mock Web App 2
   Mock SQL Account Software to test for connection and data transfer<br>
   Frontend:<br>

        cd sqlaccountmock
        flutter run -d chrome --web-port=3003

    <br>

2. WebAppFrontEnd
   E-commerce Web App which includes Google Sign-in, Link Stores, Link Inventory and logout which has connected to API endpoints and database<br>
   Backend: <br>

        cd otp_login/invite_code_service
        go run main.go
           
    Frontend:<br>

        cd kclogin
        fvm flutter run -d chrome --web-port=3001

    <br>

3. Set Up<br>
   a. Backend
      - Add own .env file in otp_login/scripts with KEYCLOAK_CLIENT_ID and KEYCLOAK_CLIENT_SECRET
   
   b. FrontEnd
      - install fvm packages from github
      - deactivate fvm in project ([steps to deactivate fvm](https://www.notion.so/jssql/13-Deactivate-fvm-in-project-19d6b1f12b088090a714ec0ae190110a?pvs=4)
)
           
    <br>

