# AI Student Growth Platform 项目规划

日期：2026-06-26

## 1. 一句话定义

你们要做的不是一个普通 AI career chatbot，也不是一个简历工具，而是一个面向加拿大高中生、大学生和早期求职者的长期 Student Growth OS。

更准确的定义：

> 一个基于长期学生档案、加拿大本地职业知识库、个性化路线图、项目执行系统和成长 dashboard 的 AI 学生成长与职业规划平台。

它帮助学生完成一条连续链路：

> 从迷茫到方向，从方向到项目，从项目到作品集，从作品集到申请，从申请到反馈与长期成长。

## 2. 核心判断

这个项目值得做，但第一版不能做成“大而全教育平台”。第一版必须验证一个最小闭环：

1. 学生填写背景和目标。
2. 系统生成 Student Growth Profile。
3. AI 推荐 3 条 career path。
4. 学生选择 1 条主路径。
5. 系统生成 4 周计划和 3/6/12 个月路线。
6. 系统推荐第一个 portfolio project。
7. 学生进入 Project Builder 完成第一个步骤。
8. Dashboard 更新 readiness。
9. AI Advisor 根据 profile、roadmap、project progress 和知识库继续回答问题。

第一版的成功不是“功能很多”，而是证明学生愿意反复回来，因为平台真的帮他从不确定变成可执行。

## 3. 目标用户优先级

第一优先级：全加拿大有专业/职业规划需求的高中生、大学生、新毕业生和 early-career explorers。

原因：

- 用户共同需求不是某个年级，而是专业/职业方向不清晰、项目证据不足、需要长期成长路线。
- 高中生可能在做专业/大学方向选择，大学生可能在做职业/实习方向选择，新毕业生可能在补项目证据和方向判断。
- 只要核心需求是方向、技能、项目和长期成长路线，就适合 Student Growth OS。
- 如果用户只需要自动投递或 job board，则不是第一版重点。
- 适合验证长期 dashboard 和 project builder。

第一版方向先聚焦：

- Economics
- Commerce
- Business
- Statistics
- CS
- Data Science
- Cognitive Systems
- International Relations
- undecided

第二优先级：国际学生身份标签，以及已经进入密集求职阶段的用户。

原因：

- 国际学生痛点强，尤其是加拿大 hiring norm、简历、项目、networking、面试。
- 已经进入密集求职阶段的用户可能付费意愿更强，但需求会偏 application tracker、auto-apply、面试工具。
- 第一版可以服务他们的方向、项目和成长路线需求，但不优先做纯求职工具。

第三优先级：家长。

原因：

- 家长可能付费。
- 但家长端会增加隐私、焦虑表达和权限设计复杂度。
- 第一版先给学生本人使用，不做家长 dashboard。

第一版建议锁定的 ICP：

> 全加拿大有专业/职业规划需求的学生和 early-career explorers，他们正在 Economics、Commerce、Business、Statistics、CS、Data Science、Cognitive Systems、International Relations 或 undecided 之间探索，不知道专业和职业怎么对应，也不知道应该做什么项目来验证兴趣和证明能力。

## 4. 产品定位

不要对外说：

- replace human agency
- guarantee offer
- AI decides your future
- immigration / visa advisor

建议对外说：

- AI-powered student growth advisor
- personalized academic and career planning platform
- project-based career readiness platform
- long-term growth dashboard for students

更适合 pitch 的表述：

> We productize the standardized, repetitive, and information-intensive parts of academic and career advising, while preserving human review for high-risk decisions.

中文表达：

> 我们把传统升学和职业顾问服务中高度重复、信息密集、可结构化的部分产品化，让学生获得更低成本、更长期、更可追踪的成长支持。

## 5. MVP 范围

第一版保留 7 个模块，但每个模块都做薄版本。

### 5.1 Student Profile

V1 必做：

- 结构化 onboarding。
- 学生类型：高中生、大学生、毕业求职者。
- 年级、学校、专业或目标专业。
- 兴趣、喜欢/不喜欢的科目。
- 技能自评：Excel、Python、SQL、writing、presentation、research、finance、design。
- 目标：探索职业、选专业、做项目、找实习、提升简历、准备面试。
- 每周可投入时间。
- AI profile summary。

V1 不做：

- 强制 transcript 上传。
- 学校系统集成。
- 精确 GPA 收集，先用 GPA range。
- 大量心理测评。

关键指标：

- 70% 以上注册用户完成 profile。
- onboarding 控制在 10-15 分钟内。
- 用户认为 AI 对自己的理解准确。

### 5.2 Career Path Explorer

V1 必做 12 条职业路径：

1. Data Analyst
2. Business Analyst
3. Software Engineer
4. Product Manager
5. AI Product Manager
6. Consultant
7. Investment Banking Analyst
8. Marketing / Growth
9. UX Designer
10. Entrepreneur
11. Policy Analyst
12. Sustainability Analyst

每条 path 固定结构：

- 这份工作做什么。
- 适合什么类型学生。
- 不适合或需要适应的地方。
- 需要哪些技能。
- 推荐课程和项目。
- 加拿大 entry-level 岗位关键词。
- 高中生如何探索。
- 大学生如何准备。
- 风险和替代路径。

关键指标：

- 50% 完成 onboarding 的学生保存一个 career path。
- 用户能清楚说出为什么选择这个 path。

### 5.3 Personalized Roadmap

V1 必做：

- 4-week plan。
- 3-month plan。
- 6-month plan。
- 12-month direction。
- 每周任务。
- 任务状态：not started, in progress, done, blocked, need help。

Roadmap 不能让 LLM 自由发挥，应该是模板加 LLM 个性化：

- 先为每个 career path 建 baseline roadmap。
- LLM 根据 student profile 调整顺序、难度、项目和每周任务。
- 每次项目进度更新后，roadmap 可重新生成或调整。

关键指标：

- 40% 激活用户生成 roadmap。
- 30% 激活用户 7 天内完成第一个 roadmap task。

### 5.4 Project Builder

这是第一版最重要的差异化模块。普通 ChatGPT 给 advice，你们要带学生做出 evidence。

V1 先做 6 个高质量项目模板：

1. Vancouver Housing Affordability Dashboard
2. Local Small Business AI Adoption ROI Case
3. AI Student Growth Platform PRD
4. Canadian Bank Valuation Mini Model
5. Market Entry Case for a Canadian Startup
6. Personal Career Tracker Web App

每个项目固定结构：

- 项目目标。
- 适合职业路径。
- 难度。
- 预计时间。
- 需要技能。
- 步骤。
- 每一步 expected output。
- AI help prompt。
- rubric。
- final outputs：portfolio page、resume bullet、LinkedIn post、interview story。

V1 project flow：

1. 选择项目。
2. Step 1 定义问题。
3. Step 2 找数据或资料。
4. Step 3 产出初版 artifact。
5. AI review。
6. Dashboard 更新 project readiness。

关键指标：

- 30% 激活用户开始第一个项目。
- 20% 激活用户 30 天内完成项目前 3 步。

### 5.5 AI Advisor

AI Advisor 不是通用聊天框，它必须读取：

- Student profile。
- Career path。
- Roadmap。
- Project progress。
- Knowledge base。
- Safety rules。

回答必须推动下一步行动。建议固定输出结构：

- Based on your profile。
- My current recommendation。
- Why。
- What to test next。
- Suggested next action。
- Confidence / uncertainty。
- Sources or internal basis。

V1 安全边界：

- 可以回答职业探索、技能建议、项目建议、简历表达、面试准备、官方资源导航。
- 不做移民法律建议、心理治疗、医疗建议、财务投资建议、保证 offer、保证录取。
- 高风险问题必须转 official resource 或 human advisor。

关键指标：

- AI 回答能引用用户 profile。
- 用户从 chat 跳转到 roadmap/project。
- 高风险问题被正确标记和转介。

### 5.6 Growth Dashboard

V1 指标：

1. Career Clarity
2. Skill Readiness
3. Project Readiness
4. Resume Readiness
5. Networking Readiness
6. Interview Readiness
7. Execution Consistency

Dashboard 不能制造焦虑。不要写：

> You are only 35% ready.

要写：

> Your strongest area is career clarity. Your next growth opportunity is portfolio building.

关键指标：

- 25% 用户第 7 天回来查看 dashboard 或更新进度。
- 用户能理解自己下一步该做什么。

### 5.7 Insight Library / Knowledge Base

V1 内容类型：

- Career path guides。
- Skill trees。
- Project templates。
- Canadian labour market notes。
- Student success guides。
- International student career adaptation guides。
- AI literacy guides。

来源分级：

- Green：原创内容、StatCan、O*NET、开放许可数据、授权内容、采访整理 insight。
- Yellow：YouTube、博客、GitHub、公司 career guide，只放链接和摘要，不入库全文。
- Red：付费课、盗版题库、无 license GitHub 内容、学校内部课件、别人的完整 notebook。

必须建立 Source Registry：

- source name
- url
- source type
- license
- can store text
- attribution required
- risk level
- last checked

## 6. 推荐技术架构

第一版推荐：

- Frontend：Next.js + Tailwind + shadcn/ui。
- Backend：Next.js API routes 或 Supabase Edge Functions。
- Auth / DB / Storage / Vector：Supabase。
- Database：PostgreSQL + pgvector。
- AI：LLM API + structured outputs。
- Hosting：Vercel。

为什么推荐 Next.js + Supabase：

- 认证、数据库、文件、向量检索可以快速搭起来。
- 两人团队不适合一开始维护复杂 backend。
- 适合先验证用户闭环。

后续再考虑：

- FastAPI service for AI workflows。
- Redis queue。
- More advanced eval pipeline。
- Institution admin console。

## 7. 数据模型第一版

核心表：

- users
- student_profiles
- profile_events
- career_paths
- skills
- career_path_skills
- roadmaps
- roadmap_milestones
- project_templates
- project_steps
- user_projects
- project_progress
- advisor_sessions
- advisor_messages
- knowledge_sources
- knowledge_chunks
- dashboard_metrics
- recommendations
- consent_records
- audit_logs

第一版不要把所有信息塞进 users 表。用户档案、项目进度、AI 推荐、知识库来源、同意记录必须分开，否则后期无法做 dashboard、RAG 和合规。

## 8. AI 服务拆分

不要用一个巨大 prompt 做所有事。拆成小服务：

1. Profile Summarizer
2. Career Path Matcher
3. Roadmap Generator
4. Project Recommender
5. Project Step Assistant
6. Output Reviewer
7. Advisor Chat RAG
8. Dashboard Scoring Engine
9. Weekly Update Generator

所有 AI 服务尽量输出 JSON，前端再负责展示。这样更稳定，也更容易 debug。

## 9. 合规和信任层

从 MVP 就要做：

- 明确 consent。
- GPA 用区间，不收过细隐私。
- transcript / resume 可选上传。
- 数据删除、导出、修改入口。
- 不默认把用户数据用于训练模型。
- 高中生单独隐私说明。
- 未满 13 岁不允许独立注册，需家长/监护人同意。
- AI answer risk level。
- 来源引用。
- human escalation。
- audit logs。
- breach playbook 草稿。

如果未来卖给 BC 公立学校、大学或 college，要准备：

- PIA 支持材料。
- Privacy Management Program 对接说明。
- service-provider obligations。
- cross-border data assessment。
- data retention policy。
- vendor list and subprocessors。

## 10. Go-to-market 路线

不建议一开始纯 B2C 投广告，也不建议一开始直接卖全国大学 SaaS。

建议路径：

### Stage 1：B2C + 学生手动验证

- 找全加拿大有专业/职业规划需求的高中生、大学生和 early-career explorers。
- 可以从 UBC/SFU/BC 访谈开始获客，但产品范围不局限于 BC/Vancouver。
- 做 30-50 个访谈。
- 手动生成 10 份 Student Growth Report。
- 测试学生是否愿意按 roadmap 做项目。
- 建 landing page + waitlist。

### Stage 2：B2B2C 小试点

- 学生社团。
- international office。
- career club。
- newcomer / youth employment nonprofit。
- small cohort workshop。

卖的不是 software seat，而是：

> AI career clarity + project readiness cohort。

### Stage 3：Institution pilot

- career centre。
- co-op office。
- high school program。
- education agency backend。

这时需要 counselor dashboard、cohort report、privacy package。

## 11. 商业模式

第一阶段可测试：

### B2C

- Free：profile + 1 career recommendation + limited roadmap。
- Pro：CAD 79-99/year。
- Monthly：CAD 9-19/month。
- Guided project plan：CAD 29-99/project。

### B2B2C

- Student club / nonprofit / school pilot：CAD 5K-25K per cohort。
- Institution pilot：CAD 25K-100K/year，取决于功能和服务范围。

### Agency backend

- 给升学/职业咨询机构做 AI backend。
- 按顾问 seat 或学生数收费。
- 这是很现实的早期商业路线，因为它不要求你马上替代机构，而是提升机构效率。

## 12. 90 天执行计划

### 第 1-2 周：定义和访谈

目标：确认谁真的痛、痛在哪里、愿不愿意行动。

任务：

- 锁定 2 个 ICP。
- 访谈 30 个学生。
- 每类至少 10 人：大学低年级、国际学生/新毕业生、高中高年级。
- 做 10 份手动 Student Growth Report。
- 确认 12 条 career path。
- 写 6 个项目模板的初版。

验收：

- 至少 10 个学生愿意二次跟进。
- 至少 5 个学生愿意开始一个项目。
- 至少 5 个用户愿意加入 beta waitlist。

### 第 3-4 周：Clickable Prototype

目标：让用户感觉这是一个平台，不是聊天框。

Figma 页面：

- Onboarding。
- Profile summary。
- Career path recommendation。
- Roadmap。
- Project Builder。
- Dashboard。
- AI Advisor。

验收：

- 20 个用户看 prototype。
- 记录每一步是否理解。
- 看用户最想点哪里。
- 确认第一版最强闭环。

### 第 5-10 周：Web MVP

目标：做出可以真实使用的最小产品。

必做：

- 登录。
- Student Profile onboarding。
- 12 career paths。
- Career path recommendation。
- Roadmap generator。
- 6 project templates。
- Project step tracking。
- AI Advisor basic RAG。
- Growth Dashboard。
- Source Registry。
- Consent and deletion basics。

不做：

- 学校系统集成。
- 家长端。
- 雇主端。
- 自动投简历。
- 完整职业库。
- 移民建议。
- 复杂社交功能。

### 第 11-13 周：Beta 和试点

目标：验证留存和付费/合作意愿。

任务：

- 招 100-300 个学生测试。
- 跑 1-2 个 project cohort。
- 找 3-5 个潜在机构/社团/非营利组织试点。
- 开始付费测试。
- 整理 case studies。

关键指标：

- 40%+ 完整激活：profile + path + first-week plan。
- 25%+ Week 4 retention。
- 30%+ 完成第一个项目 milestone。
- 5-10 个明确 willingness-to-pay 信号。

## 13. 团队分工

CS 同学负责：

- Next.js / Supabase 技术实现。
- 数据库结构。
- RAG pipeline。
- AI service prompts and structured outputs。
- Project Builder state machine。
- Dashboard scoring。
- 安全、日志、部署。

Commerce/Econ 负责人负责：

- 用户访谈。
- ICP 和市场定位。
- career path 内容。
- project template 内容。
- 加拿大本地 insight。
- source registry。
- pricing 和商业模式。
- 校园、社团、机构合作。
- pitch deck 和 demo script。

你的角色不应该只是 business。更准确是：

> Career Insight Architect。

你负责把学生痛点、职业路径、项目模板、加拿大本地资源和真实案例变成结构化知识资产。

## 14. 现在最该做的 10 件事

1. 确定第一批用户为全加拿大有专业/职业规划需求的高中生、大学生、新毕业生和 early-career explorers，方向先聚焦 Economics、Commerce、Business、Statistics、CS、Data Science、Cognitive Systems、International Relations 或 undecided。
2. 写 30 个访谈问题。
3. 访谈 30-50 个学生。
4. 手动做 10 份 Student Growth Report。
5. 敲定 12 条 career path 的 schema。
6. 写 6 个 project templates 的 step-by-step 版本。
7. 搭 Notion/Airtable 内容库。
8. 做 Figma clickable prototype。
9. 搭 Next.js + Supabase MVP。
10. 招募 100 个 beta users，跑第一个 4 周 project cohort。

## 15. 最关键的取舍

第一版不要做：

- 全职业数据库。
- 完整高中升学规划。
- 家长 dashboard。
- 学校 admin console。
- 雇主 marketplace。
- 自动投递。
- 社交社区。
- 移民/签证建议。
- 复杂 AI agent。

第一版必须做强：

- 学生档案。
- 3 条职业推荐。
- 4 周路线。
- 第一个项目。
- 项目前 3 步。
- Dashboard 下一步建议。
- AI Advisor 基于档案回答。
- 来源和风险标记。

## 16. 最终建议

你们现在的项目方向是成立的，但需要从“大愿景”压成一个非常具体的第一战场：

> Career Path + Project Roadmap for Canadian students who are unsure what career fits them and what project they should build next.

第一版只要证明一个学生可以从：

> 我不知道自己适合什么方向。

变成：

> 我知道 3 条可能路径，选择了 1 条主路径，有 4 周行动计划，开始了第一个项目，并且每周能看到成长进度。

这就已经和普通 ChatGPT 拉开差距。

## 17. 当前材料和官方校准来源

本规划基于：

- `AI Project.pdf`
- `AI_Student_Platform_Canada_Research_Report_EN.pdf`
- `pasted-text.txt`

已快速校准的官方来源：

- Canada AI for All strategy: https://ised-isde.canada.ca/site/ised/en/canadas-national-artificial-intelligence-strategy-ai-all
- Statistics Canada postsecondary enrolments and graduates 2023/2024: https://www150.statcan.gc.ca/n1/daily-quotidien/251120/dq251120e-eng.htm
- Statistics Canada Labour Force Survey May 2026: https://www150.statcan.gc.ca/n1/daily-quotidien/260605/dq260605a-eng.htm
- OPC meaningful consent guidance: https://www.priv.gc.ca/en/privacy-topics/business-privacy/collecting-personal-information/consent/gl_omc_201805/
- BC FIPPA privacy breach notifications: https://www2.gov.bc.ca/gov/content/governments/services-for-government/policies-procedures/foippa-manual/privacy-breach-notifications
- BC disclosure outside Canada guidance: https://www2.gov.bc.ca/gov/content/governments/services-for-government/information-management-technology/privacy/privacy-impact-assessments/guidance-on-disclosures-outside-of-canada
- Statistics Canada Open Licence: https://www.statcan.gc.ca/en/terms-conditions/open-licence
- O*NET Database: https://www.onetcenter.org/database.html
