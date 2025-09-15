package com.petcommunity.entity;

import javax.persistence.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "comments")
public class Comment {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String content;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "post_id")
    private Post post;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private User user;

    // 대댓글 기능을 위한 부모 댓글 참조
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "parent_comment_id")
    private Comment parentComment;

    // 자식 댓글들 (대댓글들) - 초기화를 통해 NullPointerException 방지
    @OneToMany(mappedBy = "parentComment", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Comment> replies = new ArrayList<>();

    @Column(name = "created_at")
    private LocalDateTime createdAt = LocalDateTime.now();

    @Column(name = "updated_at")
    private LocalDateTime updatedAt = LocalDateTime.now();

    // 댓글 깊이 (0: 최상위 댓글, 1: 대댓글)
    @Column(name = "depth")
    private Integer depth = 0;

    // Constructors
    public Comment() {
    }

    public Comment(String content, Post post, User user) {
        this.content = content;
        this.post = post;
        this.user = user;
        this.depth = 0;
    }

    public Comment(String content, Post post, User user, Comment parentComment) {
        this.content = content;
        this.post = post;
        this.user = user;
        this.parentComment = parentComment;
        this.depth = 1; // 대댓글
    }

    // Getters and Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
        this.updatedAt = LocalDateTime.now();
    }

    public Post getPost() {
        return post;
    }

    public void setPost(Post post) {
        this.post = post;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public Comment getParentComment() {
        return parentComment;
    }

    public void setParentComment(Comment parentComment) {
        this.parentComment = parentComment;
        if (parentComment != null) {
            this.depth = 1;
        } else {
            this.depth = 0;
        }
    }

    public List<Comment> getReplies() {
        if (replies == null) {
            replies = new ArrayList<>();
        }
        return replies;
    }

    public void setReplies(List<Comment> replies) {
        this.replies = replies != null ? replies : new ArrayList<>();
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    public Integer getDepth() {
        return depth;
    }

    public void setDepth(Integer depth) {
        this.depth = depth;
    }

    // 헬퍼 메서드들
    
    /**
     * 최상위 댓글인지 확인하는 메서드
     */
    public boolean isTopLevel() {
        return parentComment == null && (depth == null || depth == 0);
    }

    /**
     * 대댓글인지 확인하는 메서드
     */
    public boolean isReply() {
        return parentComment != null && depth != null && depth > 0;
    }

    /**
     * 답글을 추가하는 메서드
     */
    public void addReply(Comment reply) {
        if (replies == null) {
            replies = new ArrayList<>();
        }
        replies.add(reply);
        reply.setParentComment(this);
    }

    /**
     * 답글을 제거하는 메서드
     */
    public void removeReply(Comment reply) {
        if (replies != null) {
            replies.remove(reply);
            reply.setParentComment(null);
        }
    }

    /**
     * 총 답글 개수를 반환하는 메서드
     */
    public int getReplyCount() {
        return replies != null ? replies.size() : 0;
    }

    /**
     * 댓글이 수정되었는지 확인하는 메서드
     */
    public boolean isModified() {
        return updatedAt != null && createdAt != null && 
               updatedAt.isAfter(createdAt.plusMinutes(1));
    }

    /**
     * 댓글 내용의 요약을 반환하는 메서드 (XSS 방지를 위한 HTML 태그 제거)
     */
    public String getContentSummary(int maxLength) {
        if (content == null) return "";
        
        // HTML 태그 제거 (간단한 방법)
        String cleanContent = content.replaceAll("<[^>]*>", "");
        
        if (cleanContent.length() <= maxLength) {
            return cleanContent;
        }
        return cleanContent.substring(0, maxLength) + "...";
    }

    /**
     * 댓글 트리 구조를 위한 정렬 키 생성
     */
    public String getSortKey() {
        if (isTopLevel()) {
            return String.format("%010d", id);
        } else {
            return String.format("%010d_%010d", parentComment.getId(), id);
        }
    }

    @Override
    public String toString() {
        return "Comment{" +
                "id=" + id +
                ", content='" + (content != null ? content.substring(0, Math.min(content.length(), 50)) : "null") + '\'' +
                ", depth=" + depth +
                ", isTopLevel=" + isTopLevel() +
                ", replyCount=" + getReplyCount() +
                ", createdAt=" + createdAt +
                '}';
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof Comment)) return false;
        Comment comment = (Comment) o;
        return id != null && id.equals(comment.getId());
    }

    @Override
    public int hashCode() {
        return getClass().hashCode();
    }
}