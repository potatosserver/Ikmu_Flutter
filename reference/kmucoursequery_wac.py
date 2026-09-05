import csv
import io
import re
import requests

# 節次與時間對照表 (完全依據您提供的時段定義)
PERIOD_MAP = [
    ("1", "08:10-09:00"),
    ("2", "09:10-10:00"),
    ("3", "10:10-11:00"),
    ("4", "11:10-12:00"),
    ("5", "13:10-14:00"),
    ("6", "14:10-15:00"),
    ("7", "15:10-16:00"),
    ("8", "16:10-17:00"),
    ("9", "17:10-18:00"),
    ("A", "18:10-19:00"),
    ("B", "19:10-20:00"),
    ("C", "20:10-21:00"),
    ("D", "21:10-22:00"),
]

PERIOD_KEYS = [p[0] for p in PERIOD_MAP]


class KMUCourseQuery:

    def __init__(self, syear="115", sem="1"):
        self.syear = syear
        self.sem = sem
        self.courses = []
        self.fetch_all_courses()

    def fetch_all_courses(self):
        """一次性下載全校課表資料"""
        url = "https://wac.kmu.edu.tw/qur/qurq0006.php"

        headers = {
            "Content-Type": "application/x-www-form-urlencoded",
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)",
        }

        payload = (
            f"_CD_SYEAR={self.syear}&_CD_SEM={self.sem}&_CD_DEPTNO=&_CD_GRADE=%25"
            "&_CD_SEQNO=&_CD_CHINESECO=&_CD_TEA=&_CD_ROOMNO=&_CD_CSK=&_CD_CLWEEK="
            "&_CD_LANG=&_CD_OPENYN=Y"
            "&m_SQR_FD%5B%5D=SYEAR&m_SQR_FD%5B%5D=SEM&m_SQR_FD%5B%5D=SEQNO"
            "&m_SQR_FD%5B%5D=DEPTNO&m_SQR_FD%5B%5D=MASTER&m_SQR_FD%5B%5D=SECNAM"
            "&m_SQR_FD%5B%5D=ACADNO&m_SQR_FD%5B%5D=CONO&m_SQR_FD%5B%5D=OPENYN"
            "&m_SQR_FD%5B%5D=NETYN&m_SQR_FD%5B%5D=CHOOSEMAN&m_SQR_FD%5B%5D=GRADE"
            "&m_SQR_FD%5B%5D=CLASSCODE&m_SQR_FD%5B%5D=SECQTY&m_SQR_FD%5B%5D=CHINESECO"
            "&m_SQR_FD%5B%5D=SM&m_SQR_FD%5B%5D=CREDIT&m_SQR_FD%5B%5D=CSK"
            "&m_SQR_FD%5B%5D=TEAFNAM&m_SQR_FD%5B%5D=COKIND&m_SQR_FD%5B%5D=CLWEEK"
            "&m_SQR_FD%5B%5D=BCL&m_SQR_FD%5B%5D=ECL&m_SQR_FD%5B%5D=ROOMNO&m_SQR_FD%5B%5D=RMK"
            "&m_SQR_OD1=&m_SQR_OD2=&m_SQR_OD3=&m_SQR_OD4=&m_SQR_OD5="
            "&m_Action=%BF%E9%A5X%C2%B2%B3t%AA%ED%28csv%29"
            "&m_CurRec=0&m_UPDMode=&m_InSearch=&m_SearchSQL=&m_InsSussTime=0&_CD_EMIYN=&lang=zh"
        )

        print(
            f"⏳ 正在載入高醫 {self.syear} 學年度第 {self.sem} 學期全校課表..."
        )

        try:
            response = requests.post(url, headers=headers, data=payload, timeout=15)
            if response.status_code == 200:
                raw_bytes = response.content
                csv_text = None

                for enc in ["utf-8-sig", "cp950", "utf-8", "big5"]:
                    try:
                        csv_text = raw_bytes.decode(enc)
                        break
                    except (UnicodeDecodeError, TypeError):
                        continue

                if not csv_text:
                    csv_text = raw_bytes.decode("utf-8", errors="ignore")

                f = io.StringIO(csv_text)
                reader = csv.DictReader(f)

                for row in reader:
                    clean_row = {}
                    for k, v in row.items():
                        if k is not None:
                            clean_k = k.strip().lstrip("\ufeff")
                            clean_v = v.strip() if v else ""
                            clean_row[clean_k] = clean_v
                    self.courses.append(clean_row)

                print(
                    f"✅ 課表載入成功！共載入 {len(self.courses)} 筆課程資料。"
                )
            else:
                print(f"❌ 載入失敗，HTTP 狀態碼：{response.status_code}")
        except Exception as e:
            print(f"❌ 連線發生錯誤：{e}")

    def clean_html(self, text):
        """清理 HTML 標籤（如將 <a href="...">IR503</a> 轉為單純 IR503）"""
        return re.sub(r"<[^>]+>", "", text)

    def get_period_range(self, bcl, ecl):
        """將起始節次 (如 5) 與結束節次 (如 7) 展開為連續清單 ['5', '6', '7']"""
        if not bcl or not ecl:
            return []
        bcl, ecl = bcl.upper(), ecl.upper()
        if bcl in PERIOD_KEYS and ecl in PERIOD_KEYS:
            idx1 = PERIOD_KEYS.index(bcl)
            idx2 = PERIOD_KEYS.index(ecl)
            if idx1 <= idx2:
                return PERIOD_KEYS[idx1 : idx2 + 1]
        return [bcl]

    def display_timetable(self, matched_courses, query_str):
        """繪製表格化週課表 (週一 ~ 週五，1~D節)"""
        days = [
            ("1", "星期一"),
            ("2", "星期二"),
            ("3", "星期三"),
            ("4", "星期四"),
            ("5", "星期五"),
        ]

        # 初始化課表網格: grid[period_key][day_code] = list_of_course_info
        grid = {
            p_code: {d_code: [] for d_code, _ in days} for p_code, _ in PERIOD_MAP
        }
        unscheduled = []
        seen = set()

        for c in matched_courses:
            seqno = c.get("開課序號", "")
            name = c.get("科目名稱", "")
            teacher = c.get("教師姓名", "")
            week = c.get("星期", "")
            bcl = c.get("節次", "")
            ecl = c.get("節次迄", "")
            room = self.clean_html(c.get("教室", ""))

            # 相同的 (課號, 星期, 節次, 教室) 去重
            key = (seqno, week, bcl, ecl, room)
            if key in seen:
                continue
            seen.add(key)

            periods = self.get_period_range(bcl, ecl)
            cell_text = f"{name}\n({room if room else '無教室'}/{teacher})"

            if week in [d[0] for d in days] and periods:
                for p in periods:
                    if p in grid and week in grid[p]:
                        grid[p][week].append(cell_text)
            else:
                unscheduled.append((seqno, name, teacher, room))

        print(
            f"\n=========================================================================="
        )
        print(f" 🗓️  [{query_str}] 週課表網格檢視（學期 115-1）")
        print(
            f"=========================================================================="
        )

        # 輸出表頭
        header = f"{'節次':<4} | {'時間':<11} | " + " | ".join(
            [f"{d[1]:<14}" for d in days]
        )
        print(header)
        print("-" * len(header) * 2)

        # 輸出 1 ~ D 節次內容
        for p_code, p_time in PERIOD_MAP:
            row_cells = []
            for d_code, _ in days:
                cell_courses = grid[p_code][d_code]
                if cell_courses:
                    # 取第一門課顯示簡短版
                    c_info = cell_courses[0].replace("\n", " ")
                    if len(c_info) > 14:
                        c_info = c_info[:13] + "…"
                    row_cells.append(f"{c_info:<14}")
                else:
                    row_cells.append(" " * 14)

            row_str = f"{p_code:<4} | {p_time:<11} | " + " | ".join(row_cells)
            print(row_str)

        print(
            f"=========================================================================="
        )

        # 顯示非固定時段課程（如大學入門等）
        if unscheduled:
            print("\n📌 無固定節次 / 體驗 / 實習課程：")
            for seqno, name, teacher, room in unscheduled:
                print(
                    f"  • [{seqno}] {name} （教師：{teacher} | 教室：{room if room else '無'}）"
                )

    def search(self, query_str):
        query_str = query_str.strip()
        if not query_str:
            return

        matched = []
        for c in self.courses:
            seqno = c.get("開課序號", "")
            name = c.get("科目名稱", "")
            teacher = c.get("教師姓名", "")

            if (
                query_str == seqno
                or query_str in seqno
                or query_str.lower() in name.lower()
                or query_str in teacher
            ):
                matched.append(c)

        if not matched:
            print(f"\n⚠️ 未找到與 [{query_str}] 相關的課程，請確認後重試。")
            return

        # 印出表格化課表
        self.display_timetable(matched, query_str)


if __name__ == "__main__":
    print("=========================================")
    print(" 高雄醫學大學 課程時間表格查詢系統 (Python)")
    print("=========================================")

    app = KMUCourseQuery(syear="115", sem="1")

    if app.courses:
        while True:
            code = input(
                "\n請輸入【開課序號/科目名稱/教師姓名】(例如 9961214, 9961228, 呂怡緯，輸入 q 離開): "
            ).strip()
            if code.lower() == "q":
                print("👋 已離開程式。")
                break
            if code:
                app.search(code)