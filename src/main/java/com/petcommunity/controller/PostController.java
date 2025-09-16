// ================================
// PostController - 개선된 버전 (댓글/대댓글 기능 추가)
// ================================
package com.petcommunity.controller;

import com.petcommunity.entity.User;
import com.petcommunity.entity.Post;
import com.petcommunity.entity.Comment;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import javax.servlet.http.HttpSession;
import javax.sql.DataSource;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Controller
public class PostController {

    @Autowired
    private DataSource dataSource;

    // 취약점: 하드코딩된 업로드 경로, 웹 접근 가능한 디렉토리
    private static final String UPLOAD_DIR = "src/main/resources/static/uploads/";

    @GetMapping("/posts")
    public String posts(@RequestParam(required = false) String search, 
                    Model model, HttpSession session) {
        try (Connection conn = dataSource.getConnection()) {
            String sql;
            if (search != null && !search.trim().isEmpty()) {
                // JOIN을 사용하여 사용자 정보도 함께 조회
                sql = "SELECT p.id, p.title, p.content, p.user_id, p.view_count, p.created_at, p.image_path, u.nickname, u.name " +
                    "FROM posts p LEFT JOIN users u ON p.user_id = u.id " +
                    "WHERE p.title LIKE '%" + search + "%' OR p.content LIKE '%" + search + "%'";
            } else {
                sql = "SELECT p.id, p.title, p.content, p.user_id, p.view_count, p.created_at, p.image_path, u.nickname, u.name " +
                    "FROM posts p LEFT JOIN users u ON p.user_id = u.id " +
                    "ORDER BY p.created_at DESC";
            }
            
            System.out.println("검색 SQL: " + sql);

            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery(sql);

            List<Post> posts = new ArrayList<>();
            while (rs.next()) {
                Post post = new Post();
                post.setId(rs.getLong("id"));
                post.setTitle(rs.getString("title"));
                post.setContent(rs.getString("content"));
                
                // 안전한 방식으로 image_path 처리
                try {
                    post.setImagePath(rs.getString("image_path"));
                } catch (SQLException e) {
                    post.setImagePath(null); // 컬럼이 없으면 null로 설정
                }
                
                post.setViewCount(rs.getInt("view_count"));
                
                // created_at 처리
                try {
                    Timestamp createdAt = rs.getTimestamp("created_at");
                    if (createdAt != null) {
                        post.setCreatedAt(createdAt.toLocalDateTime());
                    } else {
                        post.setCreatedAt(LocalDateTime.now());
                    }
                } catch (SQLException e) {
                    post.setCreatedAt(LocalDateTime.now());
                }

                // User 정보는 기본값으로 설정
                User user = new User();
                user.setNickname(rs.getString("nickname"));
                user.setName(rs.getString("name"));
                post.setUser(user);
                
                posts.add(post);
            }

            model.addAttribute("posts", posts);
            model.addAttribute("search", search);
            
            if (search != null && !search.trim().isEmpty() && posts.isEmpty()) {
                model.addAttribute("searchMessage", "'" + search + "'에 대한 검색 결과가 없습니다.");
            }
            
            return "posts";

        } catch (SQLException e) {
            System.out.println("게시글 조회/검색 에러: " + e.getMessage());
            e.printStackTrace();
            model.addAttribute("error", "게시글을 불러오는 중 오류가 발생했습니다: " + e.getMessage());
            return "posts";
        }
    }

    @GetMapping("/posts/new")
    public String newPost(HttpSession session) {
        User user = (User) session.getAttribute("user");
        if (user == null) {
            return "redirect:/login";
        }
        return "post_form";
    }

    @PostMapping("/posts")
    public String createPost(@RequestParam String title,
                           @RequestParam String content,
                           @RequestParam("image") MultipartFile file,
                           HttpSession session, Model model) {
        User user = (User) session.getAttribute("user");
        if (user == null) {
            return "redirect:/login";
        }

        String imagePath = null;

        if (!file.isEmpty()) {
            try {
                // 취약점 1: 파일 확장자 검증 없음 - 모든 파일 타입 업로드 가능
                String originalFilename = file.getOriginalFilename();
                if (originalFilename == null || originalFilename.isEmpty()) {
                    model.addAttribute("error", "파일 이름을 확인할 수 없습니다.");
                    return "post_form";
                }

                // 경로가 포함된 경우 대비하여 순수 파일명만 추출
                String cleanFileName = Paths.get(originalFilename).getFileName().toString();

                File uploadDir = new File(UPLOAD_DIR);
                if (!uploadDir.exists()) {
                    uploadDir.mkdirs();
                }

                // 기본 파일명 설정 (원본 이름 사용)
                String fileName = cleanFileName;
                File destFile = new File(uploadDir, fileName);
                int count = 1;

                // 파일명이 중복되면 뒤에 번호를 붙여 고유한 이름 생성
                if (destFile.exists()) {
                    // 파일명과 확장자 분리
                    String baseName;
                    String ext = "";
                    int dotIndex = cleanFileName.lastIndexOf('.');
                    if (dotIndex != -1) {
                        baseName = cleanFileName.substring(0, dotIndex);
                        ext = cleanFileName.substring(dotIndex);  // ".png", ".txt" 등의 확장자 포함
                    } else {
                        baseName = cleanFileName;
                    }
                    // 중복되는 동안 숫자 붙여서 파일명 변경
                    while (destFile.exists()) {
                        fileName = baseName + "_" + count + ext;
                        destFile = new File(uploadDir, fileName);
                        count++;
                    }
                }

                // 파일 저장 (예: Files.write 또는 transferTo 사용)
                Files.write(destFile.toPath(), file.getBytes());
                imagePath = "/uploads/" + fileName;

                // 취약점 5: 업로드된 파일의 실행 권한 제거하지 않음
                // 웹쉘이 업로드되면 실행 가능

            } catch (IOException e) {
                model.addAttribute("error", "파일 업로드 중 오류가 발생했습니다.");
                return "post_form";
            }
        }

        try (Connection conn = dataSource.getConnection()) {
            // SQL Injection 취약점
            String sql = "INSERT INTO posts (title, content, image_path, user_id, created_at, updated_at) " +
                        "VALUES ('" + title + "', '" + content + "', " +
                        (imagePath != null ? "'" + imagePath + "'" : "NULL") +
                        ", " + user.getId() + ", NOW(), NOW())";

            Statement stmt = conn.createStatement();
            stmt.executeUpdate(sql);

            return "redirect:/posts";

        } catch (SQLException e) {
            model.addAttribute("error", "게시글 작성 중 오류가 발생했습니다.");
            return "post_form";
        }
    }

    @GetMapping("/posts/{id}")
    public String viewPost(@PathVariable Long id, Model model, HttpSession session) {
        try (Connection conn = dataSource.getConnection()) {
            // 조회수 증가
            String updateViewSql = "UPDATE posts SET view_count = view_count + 1 WHERE id = " + id;
            Statement updateStmt = conn.createStatement();
            updateStmt.executeUpdate(updateViewSql);

            // 게시글 조회
            String postSql = "SELECT p.*, u.nickname, u.name FROM posts p " +
                           "LEFT JOIN users u ON p.user_id = u.id WHERE p.id = " + id;

            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery(postSql);

            if (rs.next()) {
                Post post = new Post();
                post.setId(rs.getLong("id"));
                post.setTitle(rs.getString("title"));
                post.setContent(rs.getString("content"));
                post.setImagePath(rs.getString("image_path"));
                post.setViewCount(rs.getInt("view_count"));
                post.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());

                User postUser = new User();
                postUser.setNickname(rs.getString("nickname"));
                postUser.setName(rs.getString("name"));
                post.setUser(postUser);

                model.addAttribute("post", post);

                // 댓글과 대댓글을 계층적으로 조회
                Map<Long, Comment> commentMap = new HashMap<>();
                List<Comment> topLevelComments = new ArrayList<>();

                // 모든 댓글 조회 (부모 댓글과 대댓글 모두)
                String commentSql = "SELECT c.*, u.nickname FROM comments c " +
                                  "LEFT JOIN users u ON c.user_id = u.id " +
                                  "WHERE c.post_id = " + id + " ORDER BY " +
                                  "COALESCE(c.parent_comment_id, c.id), c.created_at ASC";

                ResultSet commentRs = stmt.executeQuery(commentSql);

                while (commentRs.next()) {
                    Comment comment = new Comment();
                    comment.setId(commentRs.getLong("id"));
                    comment.setContent(commentRs.getString("content"));
                    comment.setCreatedAt(commentRs.getTimestamp("created_at").toLocalDateTime());
                    
                    Long parentId = commentRs.getLong("parent_comment_id");
                    if (commentRs.wasNull()) {
                        parentId = null;
                    }

                    User commentUser = new User();
                    commentUser.setNickname(commentRs.getString("nickname"));
                    comment.setUser(commentUser);

                    comment.setReplies(new ArrayList<>());
                    commentMap.put(comment.getId(), comment);

                    if (parentId == null) {
                        // 최상위 댓글
                        topLevelComments.add(comment);
                    } else {
                        // 대댓글
                        Comment parentComment = commentMap.get(parentId);
                        if (parentComment != null) {
                            parentComment.getReplies().add(comment);
                        }
                    }
                }

                model.addAttribute("comments", topLevelComments);
                return "post_detail";
            } else {
                return "redirect:/posts";
            }

        } catch (SQLException e) {
            model.addAttribute("error", "게시글을 불러오는 중 오류가 발생했습니다.");
            return "redirect:/posts";
        }
    }

    @PostMapping("/posts/{postId}/comments")
    public String addComment(@PathVariable Long postId,
                           @RequestParam String content,
                           @RequestParam(required = false) Long parentCommentId,
                           HttpSession session) {
        User user = (User) session.getAttribute("user");
        if (user == null) {
            return "redirect:/login";
        }

        try (Connection conn = dataSource.getConnection()) {
            // SQL Injection 취약점 - 댓글/대댓글 작성
            String sql;
            if (parentCommentId != null) {
                // 대댓글 작성
                sql = "INSERT INTO comments (content, post_id, user_id, parent_comment_id, created_at) " +
                     "VALUES ('" + content + "', " + postId + ", " + user.getId() + 
                     ", " + parentCommentId + ", NOW())";
            } else {
                // 일반 댓글 작성
                sql = "INSERT INTO comments (content, post_id, user_id, created_at) " +
                     "VALUES ('" + content + "', " + postId + ", " + user.getId() + ", NOW())";
            }

            Statement stmt = conn.createStatement();
            stmt.executeUpdate(sql);

        } catch (SQLException e) {
            // 에러 처리
        }

        return "redirect:/posts/" + postId;
    }

    @PostMapping("/posts/{postId}/comments/{commentId}/reply")
    public String addReply(@PathVariable Long postId,
                          @PathVariable Long commentId,
                          @RequestParam String content,
                          HttpSession session) {
        User user = (User) session.getAttribute("user");
        if (user == null) {
            return "redirect:/login";
        }

        try (Connection conn = dataSource.getConnection()) {
            // SQL Injection 취약점 - 대댓글 작성
            String sql = "INSERT INTO comments (content, post_id, user_id, parent_comment_id, created_at) " +
                        "VALUES ('" + content + "', " + postId + ", " + user.getId() + 
                        ", " + commentId + ", NOW())";

            Statement stmt = conn.createStatement();
            stmt.executeUpdate(sql);

        } catch (SQLException e) {
            // 에러 처리
        }

        return "redirect:/posts/" + postId;
    }
}