package com.petcommunity.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.servlet.view.RedirectView;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.File;
import java.nio.file.Files;
import java.nio.file.Paths;

@Controller
public class FileAccessController {
    
    @GetMapping("/uploads/{filename:.+}")
    public Object accessUploadedFile(@PathVariable String filename, 
                                   HttpServletRequest request, 
                                   HttpServletResponse response) {
        try {
            String filePath = "src/main/webapp/uploads/" + filename;
            File file = new File(filePath);
            
            if (!file.exists()) {
                response.setStatus(404);
                return null;
            }
            
            // JSP 파일인 경우 JSP 엔진으로 처리
            if (filename.toLowerCase().endsWith(".jsp")) {
                // JSP 파일 내용을 직접 include하여 실행
                request.getRequestDispatcher("/webapp/uploads/" + filename)
                       .include(request, response);
                return null;
            }
            
            // 일반 파일은 기존 방식으로 처리
            return new RedirectView("/webapp/uploads/" + filename);
            
        } catch (Exception e) {
            response.setStatus(500);
            return null;
        }
    }
}