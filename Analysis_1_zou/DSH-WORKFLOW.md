# DSH 工作规范（本仓库）

本文件是本仓库针对 DSH（DeepSeek Harness）代理的工作约定，用于规范代理在本仓库的行为，
尤其是从扫描 PDF 提取/渲染图片、OCR 校对与编译的流程。**每次开始任务前先读本文件。**

## 1. 提取/渲染的图片存放位置（重要）

从 `ref/` 下的扫描 PDF（或编译后 PDF）用 `pdftoppm` / `pdfimages` 提取、渲染、裁剪出来的**工作用图片**，
统一放到：

```
work/images/<用途>/<文件名>
```

- 用途子目录示例：`work/images/ch4s1/`（第 4 章第 1 节 OCR 页图）、`work/images/verify-ch4s1/`（编译后核对页图）。
- 文件名清晰即可，例如 `p135-135.png`（原书第 135 页）、`fig4-5-crop.jpeg`。
- **不要**散落到系统临时目录（`%TEMP%`）、`build/` 根或 `work/` 根：
  系统临时目录跨子代理不可见、会被清理，子代理沙盒也读不到；`build/` 是编译产物目录。
- 最终要进入正文的图，仍放 `figure/`（`\graphicspath{{figure/}}` 的既定位置），例如 `figure/_page_143_Figure_0.jpeg`。

## 2. 关键路径

- 主文件：`Analysis_1_zou.tex`（XeLaTeX + Qbook 模板）。
- 章节源码：`tex/chapterNN.tex`。
- 原扫描 PDF：`ref/数学分析,.上册,.邹应,.1995.pdf`（568 页，正文无文本层，需 OCR）。
- 校对报告：`work/fidelity-*.md`、`work/source-ledger.md`、`work/ocr-risk-report.md`。
- TeX Live 工具（Windows）：`D:\texlive\2023\bin\windows\`（`latexmk`/`xelatex`/`pdftoppm`/`pdfimages`/`pdftotext`…）。

## 3. 编译

沙盒外编译（用户约定）：

```
D:\texlive\2023\bin\windows\latexmk.exe -xelatex -halt-on-error -interaction=nonstopmode -g -auxdir=build Analysis_1_zou.tex
```

- 改结构/编号后至少连编两遍，使交叉引用稳定。
- 编译后检查 `build/Analysis_1_zou.log`：无 `Missing character`、无 `Fatal error`/`Emergency stop`、无未定义引用；对 `Overfull \hbox`（公式超宽）等排版告警按行号定位并拆行修复（详见 `AGENTS.md` §6）。

## 4. OCR / 视觉校对

- 本仓库主模型无视觉；需要看图时用视觉模型 **kimi-k2.6**（provider `moonshotai-cn`，model `kimi-k2.6`，比 k3 便宜约 3 倍）。
- 调用方式：workflow 的 `agent(..., { provider: "moonshotai-cn", model: "kimi-k2.6" })`（可 `parallel` 批量）。
- 先渲染源页到 `work/images/<章节>/`，再让 kimi-k2.6 用 `read_image` 读**工作区内的路径**（不要用 `%TEMP%` 路径）。

## 5. 排版约定（前三章习惯）

- 例题整段（含解答/证明，如“事实上/由于/因此…”）放在 `sourceexample` 框内；只有**定理**的证明才用独立的 `proof` 环境（放在定理框外）。
- 习题每题一对 `\begin{exercise}...\end{exercise}`，题内分问用 `enumerate`。
- 句末用「。」；开区间用 `]a,b[`；去心邻域用 `\mathring{B}`；实数集用 `\R`（`\Q`、`\N` 同理）。
- 定义/定理用 `mydef*` / `mythm{}{label}`；交叉引用用 `\rthm{}`、`\rfig{}`、`\rdef{}` 等——它们自带“定理/图/定义”前缀，正文里不要再重复写“定理/图/定义”字。
- 扫描件里原书的句末点常被 OCR 成 `・`(U+30FB)；统一按前三章习惯改为 `。`（U+3002）。

## 6. 大段章节校对的编辑方式（重要）

校对/重排一整节（乃至一整章）时，不要对 `tex/chapterNN.tex` 逐段反复 `edit`：同一文件连续多次 `edit` 会触发 "file changed since it was read" 并因空白/字符匹配失败而反复重试。

改为：

1. 把这一节**新的完整内容**先写到一个临时文件，例如 `work/ch8_s1_tail.tex`（用 `write` 工具）。
2. 用一段 pwsh 脚本**一次性整体替换**到章节文件的对应节区间：先备份，再用 `[System.IO.File]::ReadAllText` 读原文，用 `IndexOf` 定位节首与下一节标题两个锚点，`Substring` 拼接「节前 + 临时文件内容 + 下一节标题起」，`WriteAllText` 回写（UTF-8 无 BOM）。锚点优先用 ASCII 片段（如 `\begin{mythm*}{8`）避免 `·` 等字符的编码问题。
3. 替换后 `grep` 复核 `\section` / `mythm` / `exercise` 等结构标记的行号与配对。

节区间锚点即各 `\section{...}` 标题（§1 `函数的局部比较`、§2 `函数的限定展开`、§3 `函数限定展开的一般法则`、§4 `函数限定展开的推广`、§5 `函数限定展开的应用`）。
