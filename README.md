# Affinity Windows 繁體中文獨立語系

適用：官方 EXE／MSI 安裝的 Affinity **3.3.3.5004、Windows x64**。這是非官方語言包。

本包新增「中文(繁體)」，保留原本「中文(简体)」。安裝後直接使用一般 Affinity 圖示，不需要額外啟動器。

## 下載

[下載繁體中文語言包 ZIP](Affinity-3.3.3.5004-Windows-x64-zh-Hant.zip?raw=true)

請先解壓縮，再依下方說明安裝。僅適用指定版本的 EXE／MSI 安裝。

## 切換語言

安裝本語言包後，直接開啟桌面或開始功能表中的 **Affinity**。

要切換語言，按 **Ctrl + ,** 開啟「設定」，選「一般」，向下捲到「語言」，選擇 **中文(繁體)** 或 **中文(简体)**，再重新啟動 Affinity。

## 安裝語言包

1. 將整個 ZIP 解壓縮，保留檔案與 `payload` 的相對位置。
2. 關閉 Affinity。
3. 以系統管理員身分開啟 PowerShell，切換到本資料夾，執行：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Install-Language.ps1
```

此參數只作用於這一次 PowerShell 程序，不會修改系統的執行原則。安裝預設路徑是 `C:\Program Files\Affinity\Affinity`。若使用自訂安裝位置，附加 `-AppPath '你的 Affinity 程式資料夾'`。

安裝程式會校驗版本、原始簡中資源與繁中資源；若版本不符或已存在繁中資料夾，會停止，不會覆寫。此包不適用 MSIX／WindowsApps 安裝。

## 校驗與移除

校驗已安裝的 24 個繁中檔案與未變動的簡中資源：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Install-Language.ps1 -Mode Verify
```

移除前，先在 Affinity 選擇簡體中文或英文，重新啟動確認後關閉程式。以系統管理員身分執行：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Install-Language.ps1 -Mode Remove
```

移除程式只刪除與本包雜湊相符的 24 個繁中資源檔案。若檔案已變動會停止；不刪除使用者文件、設定或原始語言。

## 範圍與限制

- 新增三個 .NET 語言資源 DLL 與 21 個 `.strings` 檔案，不修改 Affinity 主程式。
- 2026-11-16 已在官方 MSI 版確認繁中主選單、一般設定與簡繁選項並列。
- 共處理 31,045 個字串項目；28,921 項依 Mac 語言包鍵值、原文或快速鍵配對，2,124 項使用 OpenCC 台灣用語轉換補足。這是來源分類，不代表人工審校率。
- 尚未逐一人工驗證全部對話框與譯文。線上內容、部分產品名稱可能仍是英文。
- 軟體更新可能移除語言檔或改變資源格式；請勿將此包強行套用到其他版本。
- 本 ZIP 只含語言資源、校驗清單、翻譯稽核資料與安裝腳本，不包含帳號、登入資料或個人設定備份。

## 來源與授權

繁中譯文參考使用者提供的 `Affinity 3.3.3 正體中文語系.pkg`，原作者為 **麥金塔正體中文套件製作所**：<https://vocus.cc/salon/zhtw_patch_field>。

本 Windows 移植版本並非原作者或 Canva 官方發行、認證或背書。原作者版權與使用條件完整保留於「原作者版權聲明.rtf」；散布時請一併保留。`translation-audit.json` 保留逐項來源與轉換紀錄。
