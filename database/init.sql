-- 데이터베이스 생성
CREATE DATABASE IF NOT EXISTS pet_community DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE pet_community;

-- 사용자 테이블 생성
CREATE TABLE IF NOT EXISTS users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    nickname VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'USER',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_nickname (nickname)
);

-- 게시글 테이블 생성
CREATE TABLE IF NOT EXISTS posts (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    content TEXT,
    image_path VARCHAR(500),
    user_id BIGINT NOT NULL,
    view_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_created_at (created_at)
);

-- 댓글 테이블 생성
CREATE TABLE IF NOT EXISTS comments (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    content TEXT NOT NULL,
    post_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    parent_comment_id BIGINT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (parent_comment_id) REFERENCES comments(id) ON DELETE CASCADE,
    INDEX idx_post_id (post_id),
    INDEX idx_user_id (user_id),
    INDEX idx_parent_comment_id (parent_comment_id)
);

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

-- 다양한 게시글 데이터
INSERT INTO posts (title, content, user_id, view_count, created_at) VALUES 
('우리 골든 리트리버 몽이 소개해요! 🐕', '안녕하세요! 저희 집 골든 리트리버 몽이를 소개합니다. 올해로 3살이 된 남아이고요, 정말 활발하고 사람을 좋아해요. 산책을 하루에 두 번씩 하는데 매번 신나게 뛰어다닙니다. 특히 물놀이를 좋아해서 여름에는 강가에 자주 데려가요!', 2, 150, DATE_SUB(NOW(), INTERVAL 30 DAY)),

('고양이 간식 추천해주세요 🐱', '저희 집 페르시안 고양이 나비가 요즘 입맛이 까다로워졌어요. 예전에 잘 먹던 간식도 이제 안 먹네요. 혹시 고양이가 좋아하는 맛있는 간식 추천해주실 수 있나요? 건강에도 좋았으면 해요!', 3, 120, DATE_SUB(NOW(), INTERVAL 25 DAY)),

('강아지 훈련 팁 공유합니다 📚', '저희 비글 초코를 키우면서 터득한 훈련 노하우를 공유해요!\n\n1. 일관성이 가장 중요해요\n2. 보상은 즉시 주세요\n3. 짧고 자주 반복하세요\n4. 인내심을 가지세요\n\n특히 비글은 후각이 발달해서 냄새에 집중하느라 말을 잘 안 들을 때가 있어요. 그럴 때는 관심을 끌 수 있는 소리를 활용하면 좋아요!', 4, 200, DATE_SUB(NOW(), INTERVAL 20 DAY)),

('햄스터 케이지 세팅 후기 🐹', '드워프 햄스터 콩이를 위해 새로 케이지를 세팅했어요. 60cm 크기의 케이지에 톱밥을 깔고, 휠, 급수기, 먹이그릇, 숨을 곳을 배치했습니다. 콩이가 정말 좋아하네요! 특히 터널을 뚫고 다니는 모습이 너무 귀여워요.', 5, 90, DATE_SUB(NOW(), INTERVAL 15 DAY)),

('우리 말티즈의 하루 루틴 ⏰', '말티즈 구름이의 하루를 소개해요!\n\n오전 7시: 기상 및 아침 산책\n오전 8시: 아침 식사\n오전 10시: 놀이 시간\n오후 12시: 낮잠\n오후 6시: 저녁 산책 및 식사\n오후 8시: 가족과 함께 시간\n오후 10시: 취침\n\n매일 규칙적으로 생활하니까 구름이도 건강하고 행복해 보여요!', 6, 180, DATE_SUB(NOW(), INTERVAL 12 DAY)),

('고양이 장난감 DIY 만들기 🎨', '집에서 쉽게 만들 수 있는 고양이 장난감을 소개해요!\n\n1. 종이상자 + 구멍 뚫기 = 숨바꼭질 장난감\n2. 빈 화장지 심 + 간식 = 퍼즐 장난감\n3. 털실 + 막대 = 낚싯대 장난감\n\n우리 러시안블루 은이가 특히 빈 상자를 좋아해서 택배 올 때마다 상자는 은이 차지예요', 7, 140, DATE_SUB(NOW(), INTERVAL 10 DAY)),

('강아지 미용 후기 ✂️', '포메라니안 복숭아 미용을 다녀왔어요! 여름이라 짧게 깎았는데 너무 시원해하네요. 미용사님이 정말 꼼꼼하게 해주셔서 만족해요. 발가락 사이 털까지 깨끗하게 정리해주셨어요. 집에서는 브러싱만 열심히 해줘야겠어요.', 8, 110, DATE_SUB(NOW(), INTERVAL 8 DAY)),

('토끼 건초 추천해주세요 🌾', '네덜란드 드워프 토끼 토리를 키우고 있어요. 건초를 바꿔보고 싶은데 어떤 브랜드가 좋을까요? 현재는 티모시 건초를 주고 있는데 토리가 잘 먹긴 하지만 다양한 건초를 줘보고 싶어요. 추천해주세요!', 9, 85, DATE_SUB(NOW(), INTERVAL 7 DAY)),

('강아지와 함께하는 캠핑 팁 🏕️', '시베리안 허스키 눈이와 캠핑을 다녀온 후기예요!\n\n준비물:\n- 강아지용 침낭\n- 충분한 물과 사료\n- 목줄과 하네스\n- 배변봉투\n- 응급약품\n\n허스키라서 추위는 전혀 안 타더라고요. 오히려 시원한 밤공기를 좋아했어요. 다른 캠퍼분들도 눈이를 보고 다들 좋아하셔서 기분 좋았네요!', 10, 220, DATE_SUB(NOW(), INTERVAL 6 DAY)),

('고양이 중성화 수술 후기 🏥', '브리티시 쇼트헤어 먹구름이 중성화 수술을 받았어요. 수술 전에는 정말 걱정이 많았는데 무사히 잘 마쳤습니다. 수술 후 관리 방법도 자세히 알려주셔서 도움이 많이 됐어요. 이제 회복 중이라 조용히 쉬고 있어요.', 11, 95, DATE_SUB(NOW(), INTERVAL 5 DAY)),

('앵무새 말 가르치기 도전! 🦜', '코카투 코코 말하기 도전 중이에요! 아직 "안녕"밖에 못하는데 "사랑해"도 가르치려고 해요. 매일 반복해서 말해주고 있는데 언제쯤 따라할까요? 앵무새 키우시는 분들 조언 부탁드려요!', 12, 75, DATE_SUB(NOW(), INTERVAL 4 DAY)),

('강아지 산책 필수템 리스트 🚶‍♀️', '웰시코기 단팥이와 산책할 때 꼭 챙기는 필수템들이에요!\n\n1. 물통과 접이식 그릇\n2. 배변봉투\n3. 간식\n4. LED 목걸이 (밤 산책용)\n5. 응급처치용 물티슈\n6. 여분의 목줄\n\n특히 여름에는 발가락 보호를 위해 신발도 신겨요. 처음엔 싫어했지만 이제 익숙해졌어요!', 13, 160, DATE_SUB(NOW(), INTERVAL 3 DAY)),

('고양이 털 빠짐 해결법 💫', '장모종 고양이 솜이 때문에 집안이 털투성이예요. 빗질을 매일 해주는데도 털이 너무 많이 빠져요. 혹시 털 빠짐을 줄일 수 있는 좋은 방법 있나요? 사료나 영양제 추천해주시면 감사하겠어요!', 14, 130, DATE_SUB(NOW(), INTERVAL 2 DAY)),

('강아지 치아 관리 중요해요! 🦷', '닥스훈트 소시지 치석 제거를 받고 왔어요. 마취하고 스케일링 받았는데 정말 깨끗해졌어요! 앞으로는 매일 양치질 해줘야겠어요. 강아지 치아 건강 정말 중요하다는 걸 깨달았습니다. 여러분도 정기검진 꼭 받으세요!', 15, 105, DATE_SUB(NOW(), INTERVAL 1 DAY)),

('반려동물과 함께하는 여행 후기 ✈️', '요크셔테리어 까미와 제주도 여행을 다녀왔어요! 펜션에서 머물렀는데 까미가 너무 좋아했어요. 바닷가 산책도 하고 맛있는 것도 많이 먹었어요. 반려동물 동반 가능한 곳들이 생각보다 많더라고요. 다음엔 어디로 갈까요?', 16, 190, NOW()),

('새끼 고양이 입양 후기 🐱', '길고양이였던 새끼 고양이 3마리를 입양했어요. 처음에는 사람을 무서워했지만 이제는 제법 친근해졌어요. 병원 검진도 받고 예방접종도 완료했습니다. 이름은 나비, 꿀이, 별이로 지었어요!', 17, 180, DATE_SUB(NOW(), INTERVAL 40 DAY)),

('강아지 사회화 교육 중요성', '퍼피 클래스에 참여한 후기입니다. 사회화 교육이 정말 중요하다는 걸 느꼈어요. 다른 강아지들과 어울리는 법, 사람들과 인사하는 법 등을 배우고 있어요. 조기 교육의 중요성을 다시 한번 느꼈습니다.', 18, 150, DATE_SUB(NOW(), INTERVAL 35 DAY)),

('반려동물 응급처치 알아두세요!', '우리 강아지가 초콜릿을 먹어서 응급실에 갔던 경험을 공유해요. 다행히 빨리 발견해서 큰 문제없이 넘어갔지만 정말 무서웠어요. 반려동물에게 위험한 음식들과 응급처치법을 미리 알아두시길 바라요.', 19, 200, DATE_SUB(NOW(), INTERVAL 30 DAY)),

('시니어 강아지 케어법', '13살 노령견을 키우고 있어요. 요즘 계단 오르내리기를 힘들어하고 잠도 많이 자네요. 시니어 강아지를 위한 특별한 케어법이나 주의사항이 있을까요? 경험 있으신 분들 조언 부탁드려요.', 20, 170, DATE_SUB(NOW(), INTERVAL 25 DAY));

-- 댓글 데이터 (먼저 최상위 댓글들)
INSERT INTO comments (content, post_id, user_id, parent_comment_id, created_at) VALUES 
-- 골든 리트리버 게시글 댓글
('정말 귀엽네요! 골든 리트리버 최고에요', 1, 3, NULL, DATE_SUB(NOW(), INTERVAL 29 DAY)),
('저희도 골든 리트리버 키우는데 사람을 좋아하죠!', 1, 4, NULL, DATE_SUB(NOW(), INTERVAL 28 DAY)),
('물놀이 하는 모습 보고 싶어요!', 1, 5, NULL, DATE_SUB(NOW(), INTERVAL 27 DAY)),

-- 고양이 간식 게시글 댓글
('츄르는 어떠세요? 대부분 고양이들이 좋아해요!', 2, 6, NULL, DATE_SUB(NOW(), INTERVAL 24 DAY)),
('프리즈 드라이 간식 추천드려요. 영양가도 좋아요', 2, 7, NULL, DATE_SUB(NOW(), INTERVAL 23 DAY)),
('우리 고양이도 간식 고르는 재미가 있어요', 2, 8, NULL, DATE_SUB(NOW(), INTERVAL 22 DAY)),

-- 강아지 훈련 게시글 댓글
('정말 유용한 정보네요! 저장해둘게요', 3, 9, NULL, DATE_SUB(NOW(), INTERVAL 19 DAY)),
('비글 키우는데 정말 후각이 발달해서 산책할 때 냄새만 맡고 다녀요', 3, 10, NULL, DATE_SUB(NOW(), INTERVAL 18 DAY)),
('인내심이 정말 중요하죠. 저도 경험했어요', 3, 11, NULL, DATE_SUB(NOW(), INTERVAL 17 DAY)),

-- 햄스터 게시글 댓글
('햄스터도 터널 파는 게 본능이군요!', 4, 12, NULL, DATE_SUB(NOW(), INTERVAL 14 DAY)),
('케이지 사진도 올려주세요!', 4, 13, NULL, DATE_SUB(NOW(), INTERVAL 13 DAY)),

-- 말티즈 루틴 게시글 댓글
('규칙적인 생활이 정말 중요하죠', 5, 14, NULL, DATE_SUB(NOW(), INTERVAL 11 DAY)),
('말티즈 구름이라는 이름이 너무 예뻐요!', 5, 15, NULL, DATE_SUB(NOW(), INTERVAL 10 DAY)),

-- 고양이 장난감 DIY 게시글 댓글
('DIY 장난감 정보 감사해요! 한번 만들어봐야겠어요', 6, 16, NULL, DATE_SUB(NOW(), INTERVAL 9 DAY)),
('고양이는 비싼 장난감보다 박스를 더 좋아하죠', 6, 17, NULL, DATE_SUB(NOW(), INTERVAL 8 DAY)),

-- 더 많은 댓글들
('포메 미용 후 사진 보고 싶어요!', 7, 18, NULL, DATE_SUB(NOW(), INTERVAL 7 DAY)),
('여름엔 짧게 깎아주는 게 좋죠', 7, 19, NULL, DATE_SUB(NOW(), INTERVAL 6 DAY)),
('옥스보우 브랜드 추천해요!', 8, 20, NULL, DATE_SUB(NOW(), INTERVAL 5 DAY)),
('허스키와 캠핑이라니! 정말 멋지네요', 9, 21, NULL, DATE_SUB(NOW(), INTERVAL 3 DAY)),
('수술 잘 받아서 다행이에요', 10, 22, NULL, DATE_SUB(NOW(), INTERVAL 1 DAY)),
('앵무새 말 가르치는 건 시간이 오래 걸려요', 11, 23, NULL, NOW()),
('산책 필수템 리스트 정말 도움돼요', 12, 24, NULL, NOW()),
('오메가3 영양제가 털 빠짐에 도움된다고 해요', 13, 25, NULL, NOW()),
('치아 관리 정말 중요해요!', 14, 26, NULL, NOW()),
('제주도 반려동물 동반 여행 정보 더 알려주세요!', 15, 27, NULL, NOW());

-- 대댓글 데이터 (위에서 생성된 댓글 ID들을 참조)
INSERT INTO comments (content, post_id, user_id, parent_comment_id, created_at) VALUES 
-- 첫 번째 댓글에 대한 여러 답글들
('정말요! 우리 골든도 물놀이 광인이에요', 1, 5, 1, DATE_SUB(NOW(), INTERVAL 28 DAY)),
('몽이 사진 더 올려주세요!', 1, 8, 1, DATE_SUB(NOW(), INTERVAL 27 DAY)),
('골든 리트리버는 정말 천사견이에요', 1, 12, 1, DATE_SUB(NOW(), INTERVAL 26 DAY)),

-- 두 번째 댓글에 대한 답글들  
('어떤 골든 키우세요? 수컷인가요 암컷인가요?', 1, 15, 2, DATE_SUB(NOW(), INTERVAL 25 DAY)),
('저희도 3살 골든 키워요! 나이가 똑같네요', 1, 18, 2, DATE_SUB(NOW(), INTERVAL 24 DAY)),

-- 고양이 간식 게시글 답글들
('저희 고양이도 츄르만 먹어요', 2, 20, 4, DATE_SUB(NOW(), INTERVAL 23 DAY)),
('츄르 너무 많이 주면 안 좋다던데...', 2, 22, 4, DATE_SUB(NOW(), INTERVAL 22 DAY)),
('적당히 주면 괜찮아요! 하루 1-2개 정도', 2, 25, 4, DATE_SUB(NOW(), INTERVAL 21 DAY)),

('프리즈 드라이가 뭔가요?', 2, 28, 5, DATE_SUB(NOW(), INTERVAL 20 DAY)),
('동결건조 간식이에요. 영양 손실이 적어서 좋아요', 2, 30, 5, DATE_SUB(NOW(), INTERVAL 19 DAY)),

-- 강아지 훈련 게시글 답글들
('특히 4번이 정말 중요한 것 같아요', 3, 32, 7, DATE_SUB(NOW(), INTERVAL 18 DAY)),
('저도 이 방법으로 훈련했어요!', 3, 34, 7, DATE_SUB(NOW(), INTERVAL 17 DAY)),

('비글은 정말 코로 사는 견종이죠', 3, 35, 8, DATE_SUB(NOW(), INTERVAL 16 DAY)),
('냄새 따라가다 길 잃을 뻔한 적 많아요', 3, 37, 8, DATE_SUB(NOW(), INTERVAL 15 DAY)),
('그래서 하네스가 필수에요!', 3, 39, 8, DATE_SUB(NOW(), INTERVAL 14 DAY)),

-- 햄스터 게시글 답글들
('햄스터 키우고 싶어져요!', 4, 25, 10, DATE_SUB(NOW(), INTERVAL 13 DAY)),
('터널 만들어주는 영상도 올려주세요', 4, 28, 10, DATE_SUB(NOW(), INTERVAL 12 DAY)),

('사진 기대할게요!', 4, 30, 11, DATE_SUB(NOW(), INTERVAL 11 DAY)),
('콩이 너무 귀여운 이름이에요', 4, 32, 11, DATE_SUB(NOW(), INTERVAL 10 DAY)),

-- 말티즈 루틴 게시글 답글들
('우리도 이렇게 규칙적으로 해봐야겠어요', 5, 35, 12, DATE_SUB(NOW(), INTERVAL 9 DAY)),
('말티즈도 이렇게 체계적으로 관리하는군요', 5, 37, 12, DATE_SUB(NOW(), INTERVAL 8 DAY)),
('낮잠 시간이 있다니 부럽네요', 5, 39, 12, DATE_SUB(NOW(), INTERVAL 7 DAY)),

-- DIY 장난감 게시글 답글들
('저도 만들어봤는데 고양이가 정말 좋아해요', 6, 25, 14, DATE_SUB(NOW(), INTERVAL 8 DAY)),
('화장지 심 아이디어 너무 좋네요!', 6, 28, 14, DATE_SUB(NOW(), INTERVAL 7 DAY)),

('맞아요! 택배 상자만 있으면 고양이 천국이죠', 6, 30, 15, DATE_SUB(NOW(), INTERVAL 6 DAY));

-- 추가 인덱스 생성
ALTER TABLE posts ADD INDEX idx_title (title);
ALTER TABLE posts ADD INDEX idx_view_count (view_count);
ALTER TABLE comments ADD INDEX idx_created_at (created_at);

-- 취약점 테스트용 관리자 계정
INSERT INTO users (name, nickname, email, password, role) VALUES 
('테스트관리자', 'testadmin', 'test@admin.com', 'admin', 'ADMIN');

-- 통계 확인 쿼리 (선택적 실행)
/*
SELECT 
    '전체 사용자 수' as 항목, 
    COUNT(*) as 개수 
FROM users
UNION ALL
SELECT 
    '일반 사용자 수', 
    COUNT(*) 
FROM users WHERE role = 'USER'
UNION ALL
SELECT 
    '관리자 수', 
    COUNT(*) 
FROM users WHERE role = 'ADMIN'
UNION ALL
SELECT 
    '전체 게시글 수', 
    COUNT(*) 
FROM posts
UNION ALL
SELECT 
    '전체 댓글 수', 
    COUNT(*) 
FROM comments
UNION ALL
SELECT 
    '최상위 댓글 수', 
    COUNT(*) 
FROM comments WHERE parent_comment_id IS NULL
UNION ALL  
SELECT 
    '대댓글 수', 
    COUNT(*) 
FROM comments WHERE parent_comment_id IS NOT NULL;
*/

-- 대댓글 구조 확인 쿼리 (선택적 실행)
/*
-- 특정 게시글의 댓글 계층구조 확인
SELECT 
    p.title as 게시글제목,
    c1.content as 댓글내용,
    c1.created_at as 댓글작성일,
    u1.nickname as 댓글작성자,
    c2.content as 대댓글내용,
    c2.created_at as 대댓글작성일,
    u2.nickname as 대댓글작성자
FROM posts p
JOIN comments c1 ON p.id = c1.post_id AND c1.parent_comment_id IS NULL
LEFT JOIN comments c2 ON c1.id = c2.parent_comment_id  
LEFT JOIN users u1 ON c1.user_id = u1.id
LEFT JOIN users u2 ON c2.user_id = u2.id
WHERE p.id = 1  -- 첫 번째 게시글의 댓글 구조 확인
ORDER BY c1.created_at, c2.created_at;
*/

-- 인기 게시글 조회 쿼리 (선택적 실행)
/*
SELECT 
    p.title as 제목,
    u.nickname as 작성자,
    p.view_count as 조회수,
    COUNT(c.id) as 댓글수,
    p.created_at as 작성일
FROM posts p
LEFT JOIN users u ON p.user_id = u.id
LEFT JOIN comments c ON p.id = c.post_id
GROUP BY p.id, p.title, u.nickname, p.view_count, p.created_at
ORDER BY p.view_count DESC
LIMIT 10;
*/

-- 최근 활동 조회 쿼리 (선택적 실행)
/*
SELECT 
    '게시글' as 활동타입,
    p.title as 내용,
    u.nickname as 사용자,
    p.created_at as 시간
FROM posts p
JOIN users u ON p.user_id = u.id
UNION ALL
SELECT 
    '댓글' as 활동타입,
    CONCAT(SUBSTRING(c.content, 1, 50), '...') as 내용,
    u.nickname as 사용자,
    c.created_at as 시간
FROM comments c
JOIN users u ON c.user_id = u.id
ORDER BY 시간 DESC
LIMIT 20;
*/