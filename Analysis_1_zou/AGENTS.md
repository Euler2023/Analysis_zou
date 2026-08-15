# 《数学分析》LaTeX 编辑规范

本规范适用于本仓库全部 `.tex` 源文件。目标是保持正文可直接阅读、方便逐段校对，并避免用临时封装掩盖内容边界或排版问题。

## 1. 正文必须直接写入章节文件

- 书中实际出现的正文、例题、定理、证明和习题，必须直接写在对应的 `tex/chapterNN.tex` 中。
- 不得为了临时整理、移动或隐藏大段原文而定义章节专用宏，例如：
  `\newcommand{\chapteronefinalexercises}{...}`，再在正文中调用该宏。
- 修改完成后，章节文件应当按最终阅读顺序完整呈现原文；校对者不应再跳到文件其他位置寻找被打包的内容。
- 只有可重复使用且确属版式功能的命令，才可放入模板或样式文件。一次性正文内容不得抽象成命令。

## 2. 习题环境边界

- 全书习题的标题、题号、独立框和题内分问层级，均以第一章现有习题排版为基准；校订后应保持同一套结构与视觉习惯。
- 每一道独立习题必须使用自己的一对环境：

  ```tex
  \begin{exercise}
    \item 题目正文
  \end{exercise}
  ```

- 不得用一个 `exercise` 环境包住多道连续习题。
- 一道题内部的分问使用 `enumerate`；分问不是新的 `exercise`。
- 题干中的“证明”“证明：”只是命令词，不得据此自动生成 `proof` 环境。只有原书确实给出证明正文时才使用 `proof`。
- `exercise` 不得跨越下一节、下一章或其他不属于该题的结构标题。

## 3. 原文校对与修改范围

- 以现有 LaTeX 成稿和原扫描 PDF 为校对依据；不得用旧的中间 Markdown 覆盖已经校订的 `.tex`。
- 只修正能由原书、上下文或明确排版规则确认的问题。无法确认的 OCR 残损应记录待核，不凭数学常识擅自补写后宣称完成。
- 修改结构时只移动必要内容，不顺带改写无关正文，并保留用户已有修改。

## 4. 公式与盒子排版

- 正文中的行间公式使用项目既有的统一间距，不为修复单个页面而在正文散布临时 `\vspace`。
- 盒子内公式间距由盒子样式统一控制；不要在每个公式前后手工补负间距。
- 当 `\item` 后直接以 `\[...\]`、`equation`、`align` 等行间公式作为该项的首个内容时，盒子样式必须保留约 `2pt` 的公式上间距；不得套用普通竖直模式下的负间距压缩，也不得让多套钩子重复调整同一公式。
- 需要跨页的例题、定义或习题框应使用项目现有的可分页环境设置，不用强制整框留在同一页。
- `align`、`align*`、`\[...\]` 等环境必须成对闭合，且不得通过宏封装来规避环境边界错误。

## 5. 引用与编号

- 定理、定义、例题等需要引用时，使用稳定且有语义的 `\label`，并通过项目已有引用命令引用。
- 不在正文中手写可能随编辑变化的编号；例如应写
  `\rthm{thm:countable-surjection-characterization}`，而不是直接把“定理 1.3.3”当作普通文字。
- 新增或移动标签后必须至少编译两遍，使交叉引用稳定。

## 6. 完成前检查

每次修改章节内容后，至少完成以下检查：

1. 搜索并确认没有残留的一次性正文宏及其调用。
2. 检查本次涉及的 `begin/end` 环境数量和嵌套关系，特别是 `exercise`、`proof`、`enumerate` 与公式环境。
3. 使用 XeLaTeX 连续编译两遍，确认没有致命错误、未定义引用或需要再次编译的警告。
4. 检查编译日志 `build/Analysis_1_zou.log` 里的排版告警，并按行号定位修复：
   - `Overfull \hbox (... too wide) detected at line NNN`：公式超出文本宽度，`NNN` 即源文件行号。明显超宽（约 30pt 以上）的公式应拆成多行（`\[...\]` 分段或 `aligned` 的 `\\` 断行），数学内容保持不变。
   - `Not in outer par mode`：`figure` 浮动体被放进了 `sourceexample`/`mythm`/`mydef*` 等 tcolorbox 框内；应把整个 `\begin{figure}...\end{figure}` 移到框外。
   - `Missing character: There is no ，("FF0C)...`：全角标点（如 `，`）混进了数学模式；应把它移到 `$...$`、`\(...\)`、`\[...\]` 之外。
5. 渲染并查看受影响的 PDF 页面，检查跨页、孤立标题、盒子边界、公式上下间距和题号连续性。
6. 交付时说明修改落在哪个章节文件、编译是否通过，以及仍需人工核对的内容。

## 7. 本章末习题的固定要求

- 第一章最后一节的 16 道习题必须直接位于 `tex/chapter01.tex` 最后的 `\subsection*{习 题}` 之后。
- 这 16 道题必须对应 16 对独立的 `\begin{exercise}` / `\end{exercise}`。
- 不得恢复 `\chapteronefinalexercises` 或任何功能相同的打包命令。

## 8. 本地 TeX Live 与 OCR 工具链

- 本仓库已确认可用的 TeX Live（Windows）工具路径为：
  - `D:\texlive\2023\bin\windows\pdflatex.exe`
  - `D:\texlive\2023\bin\windows\xelatex.exe`
  - `D:\texlive\2023\bin\windows\latexmk.exe`
  - `D:\texlive\2023\bin\windows\pdfimages.exe`
  - `D:\texlive\2023\bin\windows\pdftotext.exe`
  - `D:\texlive\2023\bin\windows\xdvipdfmx.exe`

- 其中 `pdfimages.exe` 用于从原始 PDF 提取内嵌图像用于 OCR 校对或对照：
  - `pdfimages [options] <PDF文件> <输出前缀>`
  - 常用：
    - `pdfimages -list <PDF文件>`：先列出图像列表
    - `pdfimages -all <PDF文件> <输出前缀>`：导出全部内嵌图像
    - `pdfimages -f <起始页> -l <结束页> -png <PDF文件> <输出前缀>`：按页码导出 PNG
    - `pdfimages -f <起始页> -l <结束页> -j <PDF文件> <输出前缀>`：按 JPEG 导出
    - `pdfimages -f <起始页> -l <结束页> -jp2 <PDF文件> <输出前缀>`：按 JPEG2000 导出

- `pdftotext.exe` 用于快速抽取 PDF 文本做定位与对照（非最终校对依据）：
  - `pdftotext [options] <PDF文件> <输出txt>`
  - 常用：
    - `pdftotext -layout <PDF文件> <输出txt>`：保留版面结构
    - `pdftotext -f <起始页> -l <结束页> -layout <PDF文件> <输出txt>`：按页码抽取

- 校对工作默认遵循“优先本地 PDF + TeX 工作流”进行，先核对结构与排版，再做内容修订。
- 建议工作流：
  1. 先用 `pdfimages -list` 定位有图页；
  2. 按页导出图像（通常 `-png`）；
  3. 用 OCR 工具逐页校对，再回写到对应 `tex/chapterNN.tex`；
  4. `pdftotext -layout` 仅作辅助检索与核对，不作为单独真值来源。

## 9. DSH 工作规范

- DSH 代理在本仓库的通用工作约定（图片提取/渲染的存放位置、OCR 视觉校对、沙盒外编译命令、前三章排版习惯等）见仓库根目录的 `DSH-WORKFLOW.md`。
- 每次开始任务前，先读 `DSH-WORKFLOW.md`。
