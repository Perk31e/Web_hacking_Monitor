-- 문자셋 설정 (한글 깨짐 방지)
SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;

-- 데이터베이스 생성
CREATE DATABASE IF NOT EXISTS pet_community DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE pet_community;

-- 사용자 테이블 생성 (NOT NULL 제약조건 강화)
CREATE TABLE IF NOT EXISTS users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    nickname VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'USER',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_nickname (nickname)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 게시글 테이블 생성 (NOT NULL 제약조건 강화)
CREATE TABLE IF NOT EXISTS posts (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    content TEXT,
    image_path VARCHAR(500),
    user_id BIGINT NOT NULL,
    view_count INT DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_created_at (created_at),
    INDEX idx_title (title),
    INDEX idx_view_count (view_count)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 댓글 테이블 생성 (NOT NULL 제약조건 강화)
CREATE TABLE IF NOT EXISTS comments (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    content TEXT NOT NULL,
    post_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    parent_comment_id BIGINT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (parent_comment_id) REFERENCES comments(id) ON DELETE CASCADE,
    INDEX idx_post_id (post_id),
    INDEX idx_user_id (user_id),
    INDEX idx_parent_comment_id (parent_comment_id),
    INDEX idx_created_at (created_at)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 관리자 계정 생성
INSERT INTO users (name, nickname, email, password, role) VALUES 
('관리자', 'admin', 'admin@petcommunity.com', 'admin123', 'ADMIN');

-- 대량 사용자 데이터
INSERT INTO users (name, nickname, email, password, role) VALUES 
('김철수', '철수', 'cheolsu@example.com', 'password123', 'USER'),
('이영희', '영희', 'younghee@example.com', 'password123', 'USER'),
('박민수', '민수', 'minsu@example.com', 'password123', 'USER'),
('최지현', '지현', 'jihyun@example.com', 'password123', 'USER'),
('정하늘', '하늘', 'sky@example.com', 'password123', 'USER'),
('강바다', '바다', 'sea@example.com', 'password123', 'USER'),
('윤별님', '별님', 'star@example.com', 'password123', 'USER'),
('임달님', '달님', 'moon@example.com', 'password123', 'USER'),
('한소리', '소리', 'sound@example.com', 'password123', 'USER'),
('오빛님', '빛님', 'light@example.com', 'password123', 'USER'),
('신구름', '구름', 'cloud@example.com', 'password123', 'USER'),
('전바람', '바람', 'wind@example.com', 'password123', 'USER'),
('황푸른', '푸른', 'blue@example.com', 'password123', 'USER'),
('서초록', '초록', 'green@example.com', 'password123', 'USER'),
('남빨강', '빨강', 'red@example.com', 'password123', 'USER'),
('문노랑', '노랑', 'yellow@example.com', 'password123', 'USER'),
('배보라', '보라', 'purple@example.com', 'password123', 'USER'),
('조주황', '주황', 'orange@example.com', 'password123', 'USER'),
('위분홍', '분홍', 'pink@example.com', 'password123', 'USER'),
('표하양', '하양', 'white@example.com', 'password123', 'USER'),
('강사랑', '사랑이', 'love@example.com', 'password123', 'USER'),
('김희망', '희망이', 'hope@example.com', 'password123', 'USER'),
('이기쁨', '기쁨이', 'joy@example.com', 'password123', 'USER'),
('박행복', '행복이', 'happy@example.com', 'password123', 'USER'),
('최평화', '평화', 'peace@example.com', 'password123', 'USER'),
('정자유', '자유', 'freedom@example.com', 'password123', 'USER'),
('윤건강', '건강이', 'health@example.com', 'password123', 'USER'),
('한성공', '성공이', 'success@example.com', 'password123', 'USER'),
('오도전', '도전이', 'challenge@example.com', 'password123', 'USER'),
('신노력', '노력이', 'effort@example.com', 'password123', 'USER'),
('전지혜', '지혜', 'wisdom@example.com', 'password123', 'USER'),
('황용기', '용기', 'courage@example.com', 'password123', 'USER'),
('서진실', '진실', 'truth@example.com', 'password123', 'USER'),
('남정의', '정의', 'justice@example.com', 'password123', 'USER'),
('문겸손', '겸손', 'humble@example.com', 'password123', 'USER'),
('배친절', '친절', 'kind@example.com', 'password123', 'USER'),
('조성실', '성실', 'sincere@example.com', 'password123', 'USER'),
('위인내', '인내', 'patience@example.com', 'password123', 'USER'),
('표열정', '열정', 'passion@example.com', 'password123', 'USER'),
('강창의', '창의', 'creative@example.com', 'password123', 'USER');

-- 게시글 데이터
INSERT INTO posts (title, content, user_id, view_count, created_at, updated_at) VALUES 
('우리 골든 리트리버 몽이 소개해요!', '안녕하세요! 저희 집 골든 리트리버 몽이를 소개합니다. 올해로 3살이 된 남아이고요, 정말 활발하고 사람을 좋아해요. 산책을 하루에 두 번씩 하는데 매번 신나게 뛰어다닙니다. 특히 물놀이를 좋아해서 여름에는 강가에 자주 데려가요!', 2, 150, DATE_SUB(NOW(), INTERVAL 30 DAY), DATE_SUB(NOW(), INTERVAL 30 DAY)),
('고양이 간식 추천해주세요', '저희 집 페르시안 고양이 나비가 요즘 입맛이 까다로워졌어요. 예전에 잘 먹던 간식도 이제 안 먹네요. 혹시 고양이가 좋아하는 맛있는 간식 추천해주실 수 있나요? 건강에도 좋았으면 해요!', 3, 120, DATE_SUB(NOW(), INTERVAL 25 DAY), DATE_SUB(NOW(), INTERVAL 25 DAY)),
('강아지 훈련 팁 공유합니다', '저희 비글 초코를 키우면서 터득한 훈련 노하우를 공유해요! 일관성이 가장 중요해요. 보상은 즉시 주세요. 짧고 자주 반복하세요. 인내심을 가지세요. 특히 비글은 후각이 발달해서 냄새에 집중하느라 말을 잘 안 들을 때가 있어요.', 4, 200, DATE_SUB(NOW(), INTERVAL 20 DAY), DATE_SUB(NOW(), INTERVAL 20 DAY)),
('햄스터 케이지 세팅 후기', '드워프 햄스터 콩이를 위해 새로 케이지를 세팅했어요. 60cm 크기의 케이지에 톱밥을 깔고, 휠, 급수기, 먹이그릇, 숨을 곳을 배치했습니다. 콩이가 정말 좋아하네요!', 5, 90, DATE_SUB(NOW(), INTERVAL 15 DAY), DATE_SUB(NOW(), INTERVAL 15 DAY)),
('우리 말티즈의 하루 루틴', '말티즈 구름이의 하루를 소개해요! 오전 7시 기상 및 아침 산책, 오전 8시 아침 식사, 오전 10시 놀이 시간, 오후 12시 낮잠, 오후 6시 저녁 산책 및 식사, 오후 8시 가족과 함께 시간, 오후 10시 취침. 매일 규칙적으로 생활하니까 구름이도 건강하고 행복해 보여요!', 6, 180, DATE_SUB(NOW(), INTERVAL 12 DAY), DATE_SUB(NOW(), INTERVAL 12 DAY)),
('고양이 장난감 DIY 만들기', '집에서 쉽게 만들 수 있는 고양이 장난감을 소개해요! 종이상자 + 구멍 뚫기 = 숨바꼭질 장난감, 빈 화장지 심 + 간식 = 퍼즐 장난감, 털실 + 막대 = 낚싯대 장난감. 우리 러시안블루 은이가 특히 빈 상자를 좋아해요.', 7, 140, DATE_SUB(NOW(), INTERVAL 10 DAY), DATE_SUB(NOW(), INTERVAL 10 DAY)),
('강아지 미용 후기', '포메라니안 복숭아 미용을 다녀왔어요! 여름이라 짧게 깎았는데 너무 시원해하네요. 미용사님이 정말 꼼꼼하게 해주셔서 만족해요.', 8, 110, DATE_SUB(NOW(), INTERVAL 8 DAY), DATE_SUB(NOW(), INTERVAL 8 DAY)),
('토끼 건초 추천해주세요', '네덜란드 드워프 토끼 토리를 키우고 있어요. 건초를 바꿔보고 싶은데 어떤 브랜드가 좋을까요?', 9, 85, DATE_SUB(NOW(), INTERVAL 7 DAY), DATE_SUB(NOW(), INTERVAL 7 DAY)),
('강아지와 함께하는 캠핑 팁', '시베리안 허스키 눈이와 캠핑을 다녀온 후기예요! 강아지용 침낭, 충분한 물과 사료, 목줄과 하네스, 배변봉투, 응급약품을 준비했어요.', 10, 220, DATE_SUB(NOW(), INTERVAL 6 DAY), DATE_SUB(NOW(), INTERVAL 6 DAY)),
('고양이 중성화 수술 후기', '브리티시 쇼트헤어 먹구름이 중성화 수술을 받았어요. 수술 전에는 정말 걱정이 많았는데 무사히 잘 마쳤습니다.', 11, 95, DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_SUB(NOW(), INTERVAL 5 DAY));

-- 댓글 데이터
INSERT INTO comments (content, post_id, user_id, parent_comment_id, created_at) VALUES 
('정말 귀엽네요! 골든 리트리버 최고에요', 1, 3, NULL, DATE_SUB(NOW(), INTERVAL 29 DAY)),
('저희도 골든 리트리버 키우는데 사람을 좋아하죠!', 1, 4, NULL, DATE_SUB(NOW(), INTERVAL 28 DAY)),
('물놀이 하는 모습 보고 싶어요!', 1, 5, NULL, DATE_SUB(NOW(), INTERVAL 27 DAY)),
('츄르는 어떠세요? 대부분 고양이들이 좋아해요!', 2, 6, NULL, DATE_SUB(NOW(), INTERVAL 24 DAY)),
('프리즈 드라이 간식 추천드려요. 영양가도 좋아요', 2, 7, NULL, DATE_SUB(NOW(), INTERVAL 23 DAY)),
('우리 고양이도 간식 고르는 재미가 있어요', 2, 8, NULL, DATE_SUB(NOW(), INTERVAL 22 DAY)),
('정말 유용한 정보네요! 저장해둘게요', 3, 9, NULL, DATE_SUB(NOW(), INTERVAL 19 DAY)),
('비글 키우는데 정말 후각이 발달해서 산책할 때 냄새만 맡고 다녀요', 3, 10, NULL, DATE_SUB(NOW(), INTERVAL 18 DAY)),
('인내심이 정말 중요하죠. 저도 경험했어요', 3, 11, NULL, DATE_SUB(NOW(), INTERVAL 17 DAY)),
('햄스터도 터널 파는 게 본능이군요!', 4, 12, NULL, DATE_SUB(NOW(), INTERVAL 14 DAY)),
('케이지 사진도 올려주세요!', 4, 13, NULL, DATE_SUB(NOW(), INTERVAL 13 DAY)),
('규칙적인 생활이 정말 중요하죠', 5, 14, NULL, DATE_SUB(NOW(), INTERVAL 11 DAY)),
('말티즈 구름이라는 이름이 너무 예뻐요!', 5, 15, NULL, DATE_SUB(NOW(), INTERVAL 10 DAY)),
('DIY 장난감 정보 감사해요! 한번 만들어봐야겠어요', 6, 16, NULL, DATE_SUB(NOW(), INTERVAL 9 DAY)),
('고양이는 비싼 장난감보다 박스를 더 좋아하죠', 6, 17, NULL, DATE_SUB(NOW(), INTERVAL 8 DAY)),
('포메 미용 후 사진 보고 싶어요!', 7, 18, NULL, DATE_SUB(NOW(), INTERVAL 7 DAY)),
('여름엔 짧게 깎아주는 게 좋죠', 7, 19, NULL, DATE_SUB(NOW(), INTERVAL 6 DAY)),
('옥스보우 브랜드 추천해요!', 8, 20, NULL, DATE_SUB(NOW(), INTERVAL 5 DAY)),
('허스키와 캠핑이라니! 정말 멋지네요', 9, 21, NULL, DATE_SUB(NOW(), INTERVAL 3 DAY)),
('수술 잘 받아서 다행이에요', 10, 22, NULL, DATE_SUB(NOW(), INTERVAL 1 DAY));

-- 대댓글 데이터
INSERT INTO comments (content, post_id, user_id, parent_comment_id, created_at) VALUES 
('정말요! 우리 골든도 물놀이 광인이에요', 1, 5, 1, DATE_SUB(NOW(), INTERVAL 28 DAY)),
('몽이 사진 더 올려주세요!', 1, 8, 1, DATE_SUB(NOW(), INTERVAL 27 DAY)),
('골든 리트리버는 정말 천사견이에요', 1, 12, 1, DATE_SUB(NOW(), INTERVAL 26 DAY)),
('어떤 골든 키우세요? 수컷인가요 암컷인가요?', 1, 15, 2, DATE_SUB(NOW(), INTERVAL 25 DAY)),
('저희도 3살 골든 키워요! 나이가 똑같네요', 1, 18, 2, DATE_SUB(NOW(), INTERVAL 24 DAY)),
('저희 고양이도 츄르만 먹어요', 2, 20, 4, DATE_SUB(NOW(), INTERVAL 23 DAY)),
('츄르 너무 많이 주면 안 좋다던데...', 2, 22, 4, DATE_SUB(NOW(), INTERVAL 22 DAY)),
('적당히 주면 괜찮아요! 하루 1-2개 정도', 2, 25, 4, DATE_SUB(NOW(), INTERVAL 21 DAY)),
('프리즈 드라이가 뭔가요?', 2, 28, 5, DATE_SUB(NOW(), INTERVAL 20 DAY)),
('동결건조 간식이에요. 영양 손실이 적어서 좋아요', 2, 30, 5, DATE_SUB(NOW(), INTERVAL 19 DAY)),
('특히 4번이 정말 중요한 것 같아요', 3, 32, 7, DATE_SUB(NOW(), INTERVAL 18 DAY)),
('저도 이 방법으로 훈련했어요!', 3, 34, 7, DATE_SUB(NOW(), INTERVAL 17 DAY)),
('비글은 정말 코로 사는 견종이죠', 3, 35, 8, DATE_SUB(NOW(), INTERVAL 16 DAY)),
('냄새 따라가다 길 잃을 뻔한 적 많아요', 3, 37, 8, DATE_SUB(NOW(), INTERVAL 15 DAY)),
('그래서 하네스가 필수에요!', 3, 39, 8, DATE_SUB(NOW(), INTERVAL 14 DAY)),
('햄스터 키우고 싶어져요!', 4, 25, 10, DATE_SUB(NOW(), INTERVAL 13 DAY)),
('터널 만들어주는 영상도 올려주세요', 4, 28, 10, DATE_SUB(NOW(), INTERVAL 12 DAY)),
('사진 기대할게요!', 4, 30, 11, DATE_SUB(NOW(), INTERVAL 11 DAY)),
('콩이 너무 귀여운 이름이에요', 4, 32, 11, DATE_SUB(NOW(), INTERVAL 10 DAY)),
('우리도 이렇게 규칙적으로 해봐야겠어요', 5, 35, 12, DATE_SUB(NOW(), INTERVAL 9 DAY)),
('말티즈도 이렇게 체계적으로 관리하는군요', 5, 37, 12, DATE_SUB(NOW(), INTERVAL 8 DAY)),
('낮잠 시간이 있다니 부럽네요', 5, 39, 12, DATE_SUB(NOW(), INTERVAL 7 DAY)),
('저도 만들어봤는데 고양이가 정말 좋아해요', 6, 25, 14, DATE_SUB(NOW(), INTERVAL 8 DAY)),
('화장지 심 아이디어 너무 좋네요!', 6, 28, 14, DATE_SUB(NOW(), INTERVAL 7 DAY)),
('맞아요! 택배 상자만 있으면 고양이 천국이죠', 6, 30, 15, DATE_SUB(NOW(), INTERVAL 6 DAY));

-- 테스트용 관리자 계정
INSERT INTO users (name, nickname, email, password, role) VALUES 
('테스트관리자', 'testadmin', 'test@admin.com', 'admin123', 'ADMIN');