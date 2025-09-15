// ================================
// UserController - 취약한 SQL Injection 포함
// ================================
package com.petcommunity.controller;

import com.petcommunity.entity.User;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import javax.servlet.http.HttpSession;
import javax.sql.DataSource;
import java.sql.*;

@Controller
public class UserController {

    @Autowired
    private DataSource dataSource;

    @GetMapping("/")
    public String home() {
        return "index";
    }

    @GetMapping("/register")
    public String registerForm() {
        return "register";
    }

    @PostMapping("/register")
    public String register(@RequestParam String name,
                          @RequestParam String nickname,
                          @RequestParam String email,
                          @RequestParam String password,
                          Model model) {
        try (Connection conn = dataSource.getConnection()) {
            // 취약점: SQL Injection - 파라미터를 직접 문자열 연결로 쿼리 생성
            // 수정방법: PreparedStatement 사용해야 함
            String sql = "INSERT INTO users (name, nickname, email, password, role, created_at, updated_at) " +
                        "VALUES ('" + name + "', '" + nickname + "', '" + email + "', '" + password + "', 'USER', NOW(), NOW())";

            Statement stmt = conn.createStatement();
            stmt.executeUpdate(sql);

            model.addAttribute("message", "회원가입이 완료되었습니다.");
            return "login";

        } catch (SQLException e) {
            model.addAttribute("error", "회원가입 중 오류가 발생했습니다: " + e.getMessage());
            return "register";
        }
    }

    @GetMapping("/login")
    public String loginForm() {
        return "login";
    }

    @PostMapping("/login")
    public String login(@RequestParam String email,
                       @RequestParam String password,
                       HttpSession session, Model model) {
        try (Connection conn = dataSource.getConnection()) {
            // 취약점: SQL Injection - WHERE 절에 직접 파라미터 삽입
            // 수정방법: PreparedStatement의 ? 플레이스홀더 사용해야 함
            String sql = "SELECT * FROM users WHERE email = '" + email + "' AND password = '" + password + "'";

            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery(sql);

            if (rs.next()) {
                User user = new User();
                user.setId(rs.getLong("id"));
                user.setName(rs.getString("name"));
                user.setNickname(rs.getString("nickname"));
                user.setEmail(rs.getString("email"));
                user.setRole(rs.getString("role"));

                session.setAttribute("user", user);
                return "redirect:/posts";
            } else {
                model.addAttribute("error", "이메일 또는 비밀번호가 잘못되었습니다.");
                return "login";
            }

        } catch (SQLException e) {
            model.addAttribute("error", "로그인 중 오류가 발생했습니다: " + e.getMessage());
            return "login";
        }
    }

    @GetMapping("/logout")
    public String logout(HttpSession session) {
        session.invalidate();
        return "redirect:/";
    }

    @GetMapping("/mypage")
    public String mypage(HttpSession session, Model model) {
        User user = (User) session.getAttribute("user");
        if (user == null) {
            return "redirect:/login";
        }
        model.addAttribute("user", user);
        return "mypage";
    }

    @PostMapping("/mypage/update")
    public String updateProfile(@RequestParam String name,
                               @RequestParam String nickname,
                               @RequestParam String password,
                               HttpSession session, Model model) {
        User user = (User) session.getAttribute("user");
        if (user == null) {
            return "redirect:/login";
        }

        try (Connection conn = dataSource.getConnection()) {
            // 취약점: SQL Injection - UPDATE 쿼리에도 직접 파라미터 삽입
            // 수정방법: PreparedStatement 사용해야 함
            String sql = "UPDATE users SET name = '" + name + "', nickname = '" + nickname +
                        "', password = '" + password + "', updated_at = NOW() WHERE id = " + user.getId();

            Statement stmt = conn.createStatement();
            stmt.executeUpdate(sql);

            // 세션 정보 업데이트
            user.setName(name);
            user.setNickname(nickname);
            user.setPassword(password);
            session.setAttribute("user", user);

            model.addAttribute("message", "회원정보가 수정되었습니다.");
            return "mypage";

        } catch (SQLException e) {
            model.addAttribute("error", "회원정보 수정 중 오류가 발생했습니다: " + e.getMessage());
            return "mypage";
        }
    }

    // 관리자 페이지 - 회원 검색 기능 (취약점 포함)
    @GetMapping("/admin")
    public String admin(HttpSession session, Model model) {
        User user = (User) session.getAttribute("user");
        if (user == null || !"ADMIN".equals(user.getRole())) {
            return "redirect:/login";
        }
        return "admin";
    }

    @GetMapping("/admin/users")
    public String searchUsers(@RequestParam(required = false) String search,
                             HttpSession session, Model model) {
        User user = (User) session.getAttribute("user");
        if (user == null || !"ADMIN".equals(user.getRole())) {
            return "redirect:/login";
        }

        try (Connection conn = dataSource.getConnection()) {
            String sql;
            if (search != null && !search.trim().isEmpty()) {
                // 취약점: SQL Injection - LIKE 구문에 직접 파라미터 삽입
                // 수정방법: PreparedStatement 사용해야 함
                sql = "SELECT * FROM users WHERE name LIKE '%" + search + "%' OR email LIKE '%" + search + "%'";
            } else {
                sql = "SELECT * FROM users ORDER BY created_at DESC";
            }

            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery(sql);

            java.util.List<User> users = new java.util.ArrayList<>();
            while (rs.next()) {
                User u = new User();
                u.setId(rs.getLong("id"));
                u.setName(rs.getString("name"));
                u.setNickname(rs.getString("nickname"));
                u.setEmail(rs.getString("email"));
                u.setRole(rs.getString("role"));
                u.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
                users.add(u);
            }

            model.addAttribute("users", users);
            model.addAttribute("search", search);
            return "admin_users";

        } catch (SQLException e) {
            model.addAttribute("error", "사용자 검색 중 오류가 발생했습니다: " + e.getMessage());
            return "admin";
        }
    }

}