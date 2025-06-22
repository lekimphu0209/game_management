import psycopg2

def run_sql_file(cursor, filename):
    with open(filename, "r", encoding="utf-8") as f:
        sql = f.read()
        try:
            cursor.execute(sql)
        except Exception as e:
            print(f"Lỗi khi thực thi file SQL:\n{e}\n")

def get_connection():
    return psycopg2.connect(
        dbname="gamermanagement", user="postgres", password="020905", host="localhost"
    )

if __name__ == "__main__":
    conn = get_connection()
    cur = conn.cursor()
    run_sql_file(cur, "C:/Users/lekim/OneDrive/Desktop/python/project/data.sql")

    conn.commit()
    cur.close()
    conn.close()
