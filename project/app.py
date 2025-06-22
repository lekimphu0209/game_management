from flask import Flask, render_template, request, redirect, url_for, flash, session
from flask_sqlalchemy import SQLAlchemy
from flask_login import LoginManager, UserMixin, login_user, logout_user, login_required, current_user
from datetime import datetime
from werkzeug.security import generate_password_hash, check_password_hash
from sqlalchemy.orm import relationship


app = Flask(__name__, template_folder=r'C:\Users\lekim\OneDrive\Desktop\python\project\templates')

app.secret_key = 'secretkey'
app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql+psycopg2://postgres:020905@localhost:5432/gamermanagement'

app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)
login_manager = LoginManager(app)
login_manager.login_view = 'login'

# ----------------- DATABASE MODELS -----------------
class Player(UserMixin, db.Model):
    __tablename__ = 'players'
    player_id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(50), unique=True)
    email = db.Column(db.String(100), unique=True)
    password = db.Column(db.String(200))
    time_created = db.Column(db.DateTime, default=datetime.utcnow)
    highest_score = db.Column(db.Integer, default=0)

    def get_id(self):
        return str(self.player_id)

class GameSession(db.Model):
    __tablename__ = 'game_sessions'
    session_id = db.Column(db.Integer, primary_key=True)
    start_time = db.Column(db.DateTime)
    end_time = db.Column(db.DateTime)
    final_score = db.Column(db.Integer)
    boss_killed = db.Column(db.Boolean)
    boss_kill_time = db.Column(db.DateTime)
    player_id = db.Column(db.Integer, db.ForeignKey('players.player_id'))
    character_id = db.Column(db.Integer, db.ForeignKey('characters.character_id'))


    player = relationship('Player', backref='sessions')
    character = relationship('Character')


from sqlalchemy.orm import relationship

class Leaderboard(db.Model):
    __tablename__ = 'leaderboard'
    leaderboard_id = db.Column(db.Integer, primary_key=True)
    player_id = db.Column(db.Integer, db.ForeignKey('players.player_id'))
    rank = db.Column(db.Integer)
    highest_score = db.Column(db.Integer)
    last_updated = db.Column(db.DateTime, default=datetime.utcnow)

    # Thêm dòng này để truy cập player qua .player
    player = relationship('Player', backref='leaderboard_entries')

# Add other models: Character, Items, Achievements, etc...
class Character(db.Model):
    __tablename__ = 'characters'
    character_id = db.Column(db.Integer, primary_key=True)
    max_hp = db.Column(db.Integer, nullable=False)
    max_item_slots = db.Column(db.Integer, nullable=False)
    player_id = db.Column(db.Integer, db.ForeignKey('players.player_id'), nullable=False)

class Item(db.Model):
    __tablename__ = 'items'
    item_id = db.Column(db.Integer, primary_key=True, server_default=db.FetchedValue())
    name = db.Column(db.String(100), nullable=False)
    type = db.Column(db.String(50), nullable=False)
    damage = db.Column(db.Integer)
    rarity = db.Column(db.String(50))



class Monster(db.Model):
    __tablename__ = 'monsters'
    monster_id = db.Column(db.Integer, primary_key=True, autoincrement=True)  # ⚠️ THÊM autoincrement=True

    name = db.Column(db.String(100), nullable=False)
    hp = db.Column(db.Integer)
    point = db.Column(db.Integer)
    damage = db.Column(db.Integer)
    type = db.Column(db.String(50))
    speed = db.Column(db.Integer)





class Achievement(db.Model):
    __tablename__ = 'achievements'
    achievement_id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    description = db.Column(db.Text)
    condition_type = db.Column(db.String(50))
    condition_value = db.Column(db.Integer)

class SessionMonsterKill(db.Model):
    __tablename__ = 'session_monster_kills'
    session_id = db.Column(db.Integer, db.ForeignKey('game_sessions.session_id'), primary_key=True)
    monster_id = db.Column(db.Integer, db.ForeignKey('monsters.monster_id'), primary_key=True)
    kill_time = db.Column(db.DateTime)
    points_earned = db.Column(db.Integer)




from sqlalchemy.orm import relationship

class CharacterEquipment(db.Model):
    __tablename__ = 'character_equipment'
    character_id = db.Column(db.Integer, db.ForeignKey('characters.character_id'), primary_key=True)
    slot_number = db.Column(db.Integer, primary_key=True)
    item_id = db.Column(db.Integer, db.ForeignKey('items.item_id'))
    equipped_at = db.Column(db.DateTime, default=datetime.utcnow)

    item = relationship('Item')
    character = relationship('Character')


class Admin(db.Model, UserMixin):
    __tablename__ = 'admins'
    admin_id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password = db.Column(db.String(128), nullable=False)

    @property
    def is_admin(self):
        return True

    def get_id(self):
        return f"admin-{self.admin_id}"





@app.route('/admin-login', methods=['GET', 'POST'])
def admin_login():
    if request.method == 'POST':
        email = request.form['email']
        password = request.form['password']
        admin = Admin.query.filter_by(email=email).first()

        if admin and admin.password == password:  # nên mã hóa sau
            login_user(admin)
            return redirect(url_for('admin_dashboard'))

        flash("Sai thông tin quản trị.", "danger")
    return render_template('admin_login.html')

@login_manager.user_loader
def load_user(user_id):
    if user_id.startswith('admin-'):
        admin_id = int(user_id.split('-')[1])
        return Admin.query.get(admin_id)
    else:
        return Player.query.get(int(user_id))



@app.route('/admin')
@login_required
def admin_home():  # ✅ Đổi tên
    if not isinstance(current_user, Admin):
        flash("Bạn không có quyền truy cập!", "danger")
        return redirect(url_for('home'))
    return render_template('admin_dashboard.html')


@app.route('/admin/dashboard', methods=['GET', 'POST'])
@login_required
def admin_dashboard():
    if not current_user.is_admin:
        flash("Bạn không có quyền truy cập!", "danger")
        return redirect(url_for('home'))

    keyword = request.form.get('keyword', '')
    players = []

    if keyword:
        players = Player.query.filter(Player.username.ilike(f"%{keyword}%")).all()
    else:
        players = Player.query.all()

    return render_template('admin_dashboard.html', players=players, keyword=keyword)


@app.route('/admin/sessions/<int:pid>')
@login_required
def admin_view_sessions(pid):
    if not current_user.is_admin:
        flash("Bạn không có quyền truy cập!", "danger")
        return redirect(url_for('home'))

    sessions = db.session.execute(text("""
        SELECT 
    gs.session_id,
    gs.start_time,
    gs.end_time,
    gs.final_score,
    i.name AS weapon_name
FROM game_sessions gs
LEFT JOIN characters c ON c.character_id = gs.character_id
LEFT JOIN character_equipment ce ON ce.character_id = c.character_id AND ce.slot_number = 1
LEFT JOIN items i ON i.item_id = ce.item_id
WHERE gs.player_id = :pid
ORDER BY gs.start_time DESC;

    """), {'pid': pid}).fetchall()

    player = Player.query.get(pid)

    return render_template('admin_sessions.html', sessions=sessions, player=player)







@app.route('/')
def home():
    if current_user.is_authenticated:
        if hasattr(current_user, 'is_admin') and current_user.is_admin:
            return redirect(url_for('admin_dashboard'))
        return redirect(url_for('dashboard'))
    return render_template('home.html')


@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        email = request.form['email']
        password = request.form['password']
        print(f"Trying to login with email: {email}")

        player = Player.query.filter_by(email=email).first()
        print(f"Found user: {player.username if player else 'None'}")
        
        if player:
            print(f"Password from form: {password}")
            print(f"Password in DB: {player.password}")
            if player.password == password:  # Chỉ dùng nếu mật khẩu chưa hash
                login_user(player)
                return redirect(url_for('dashboard'))

        flash('Sai thông tin đăng nhập.', 'danger')

    return render_template('login.html')



@app.route('/admin/player/delete/<int:pid>', methods=['POST'])
@login_required
def delete_player(pid):
    if not current_user.is_admin:
        flash("Bạn không có quyền thực hiện thao tác này.", "danger")
        return redirect(url_for('admin_dashboard'))

    player = Player.query.get_or_404(pid)

    # Xoá tất cả dữ liệu liên quan nếu cần, ví dụ: sessions, characters...
    GameSession.query.filter_by(player_id=pid).delete()
    Character.query.filter_by(player_id=pid).delete()
    Leaderboard.query.filter_by(player_id=pid).delete()

    db.session.delete(player)
    db.session.commit()
    flash('Đã xóa người chơi thành công.', 'success')
    return redirect(url_for('admin_dashboard'))


@app.route('/admin/player/edit/<int:pid>', methods=['GET', 'POST'])
@login_required
def edit_player(pid):
    if not current_user.is_admin:
        flash("Bạn không có quyền thực hiện thao tác này.", "danger")
        return redirect(url_for('home'))

    player = Player.query.get_or_404(pid)

    if request.method == 'POST':
        new_email = request.form['email']
        new_password = request.form['password']

        player.email = new_email
        if new_password:
            player.password = new_password  # Nếu muốn mã hóa thì dùng generate_password_hash(new_password)

        db.session.commit()
        flash("Cập nhật người chơi thành công.", "success")
        return redirect(url_for('admin_dashboard'))

    return render_template('admin_edit_player.html', player=player)


@app.route('/admin/weapons', methods=['GET', 'POST'])
@login_required
def admin_weapons():
    if not current_user.is_admin:
        flash("Bạn không có quyền truy cập!", "danger")
        return redirect(url_for('home'))

    if request.method == 'POST':
        name = request.form['name']
        type_ = request.form['type']
        damage = request.form['damage']
        rarity = request.form['rarity']

        new_item = Item(name=name, type=type_, damage=damage, rarity=rarity)
        db.session.add(new_item)
        db.session.commit()
        flash('Đã thêm vũ khí mới!', 'success')
        return redirect(url_for('admin_weapons'))

    view_mode = request.args.get('view', 'all')

    if view_mode == 'used':
        # Thống kê số lần item được dùng trong session_items
        usage_data = db.session.execute(text("""
            SELECT i.item_id, i.name, i.type, i.rarity, COUNT(si.session_id) AS usage_count
            FROM items i
            JOIN session_items si ON i.item_id = si.item_id
            GROUP BY i.item_id, i.name, i.type, i.rarity
            ORDER BY usage_count DESC
        """)).fetchall()
        usage_stats = [dict(row._mapping) for row in usage_data]

        return render_template('admin_weapons.html',
                               view_mode=view_mode,
                               usage_stats=usage_stats)
    else:
        all_items = Item.query.all()
        return render_template('admin_weapons.html',
                               view_mode=view_mode,
                               all_items=all_items)




@app.route('/admin/weapons/edit/<int:item_id>', methods=['GET', 'POST'])
@login_required
def edit_weapon(item_id):
    if not current_user.is_admin:
        flash("Bạn không có quyền truy cập!", "danger")
        return redirect(url_for('home'))

    item = Item.query.get_or_404(item_id)

    if request.method == 'POST':
        item.name = request.form['name']
        item.type = request.form['type']
        item.damage = request.form['damage']
        item.rarity = request.form['rarity']

        db.session.commit()
        flash('Đã cập nhật vũ khí thành công!', 'success')
        return redirect(url_for('admin_weapons'))  # hoặc trang quản lý danh sách

    return render_template('edit_weapon.html', item=item)


@app.route('/admin/achievements', methods=['GET', 'POST'])
def admin_achievements():
    if request.method == 'POST':
        name = request.form.get('name')
        description = request.form.get('description')
        condition_type = request.form.get('condition_type')
        condition_value = request.form.get('condition_value')

        if all([name, condition_type, condition_value]):
            new_achievement = Achievement(
                name=name,
                description=description,
                condition_type=condition_type,
                condition_value=int(condition_value)
            )
            db.session.add(new_achievement)
            db.session.commit()
            flash("Đã thêm thành tựu mới.")

        return redirect(url_for('admin_achievements'))

    achievements = Achievement.query.all()
    return render_template('admin_achievements.html', achievements=achievements)


from sqlalchemy.sql import text

@app.route('/admin/characters')
def admin_characters():
    used_characters = db.session.execute(text("""
        SELECT c.character_id, c.max_hp, c.max_item_slots, c.player_id, COUNT(gs.session_id) AS usage_count
        FROM characters c
        JOIN game_sessions gs ON c.character_id = gs.character_id
        GROUP BY c.character_id, c.max_hp, c.max_item_slots, c.player_id
        ORDER BY usage_count DESC
    """)).fetchall()

    return render_template("admin_characters.html", used_characters=used_characters)




@app.route('/monsters', methods=['GET', 'POST'])
def admin_monsters():
    monster = None

    if request.method == 'POST':
        mid = request.form.get('id')
        name = request.form.get('name')
        hp = request.form.get('hp')
        damage = request.form.get('damage')
        point = request.form.get('point')
        type_ = request.form.get('type')
        speed = request.form.get('speed')

        # Nếu có đầy đủ dữ liệu -> lưu
        if all([name, hp, damage, point, type_, speed]):
            if mid:
                monster = Monster.query.get(mid)
                if monster:
                    monster.name = name
                    monster.hp = hp
                    monster.damage = damage
                    monster.point = point
                    monster.type = type_
                    monster.speed = speed
            else:
                new_monster = Monster(
                    name=name,
                    hp=hp,
                    damage=damage,
                    point=point,
                    type=type_,
                    speed=speed
                )
                db.session.add(new_monster)

            db.session.commit()
            flash("Đã lưu thông tin quái vật.")
            return redirect(url_for('admin_monsters'))

        # Nếu chỉ nhấn nút "Sửa", hiển thị lại dữ liệu
        if mid:
            monster = Monster.query.get(mid)

    monsters = Monster.query.all()
    return render_template('admin_monsters.html', monsters=monsters, monster=monster)



##################--PLAYER--################################

@app.route('/dashboard')
@login_required
def dashboard():
    return render_template('dashboard.html')


@app.route('/leaderboard')
@login_required
def leaderboard():
    top_players = Leaderboard.query.order_by(Leaderboard.highest_score.desc()).limit(10).all()
    return render_template('leaderboard_table.html', top_players=top_players)



@app.route('/history')
@login_required
def history():
    sessions = GameSession.query.filter_by(player_id=current_user.player_id).all()
    return render_template('session_table.html', sessions=sessions)

from sqlalchemy import text

from sqlalchemy import text

@app.route('/session/<int:session_id>/monster_stats')
@login_required
def monster_stats(session_id):
    sql = text("""
        SELECT
            m.name AS monster_name,
            COUNT(*) AS kill_count,
            SUM(sm.points_earned) AS total_points
        FROM session_monster_kills sm
        JOIN monsters m ON sm.monster_id = m.monster_id
        WHERE sm.session_id = :session_id
        GROUP BY m.name
        ORDER BY total_points DESC
    """)
    
    results = db.session.execute(sql, {'session_id': session_id}).fetchall()
    total_score = sum(row.total_points for row in results)

    return render_template('monster_stats.html',
                           session_id=session_id,
                           stats=results,
                           total_score=total_score)



@app.route('/weapons')
@login_required
def weapons():
    results = db.session.execute(text("""
        SELECT 
            p.username,
            c.character_id,
            i.name AS weapon_name,
            i.type AS weapon_type,
            i.rarity,
            ce.slot_number,
            ce.equipped_at
        FROM players p
        JOIN game_sessions gs ON gs.player_id = p.player_id
        JOIN characters c ON c.character_id = gs.character_id
        JOIN character_equipment ce ON ce.character_id = c.character_id
        JOIN items i ON i.item_id = ce.item_id
        WHERE p.player_id = :pid
    """), {'pid': current_user.player_id})

    weapons = results.fetchall()
    return render_template('equip_table.html', weapons=weapons)


from sqlalchemy import text

@app.route('/achievements')
@login_required
def achievements():
    sql = text("""
        SELECT a.achievement_id, a.name, a.description
        FROM session_achievements sa
        JOIN achievements a ON sa.achievement_id = a.achievement_id
        JOIN game_sessions gs ON sa.session_id = gs.session_id
        WHERE gs.player_id = :pid
        GROUP BY a.achievement_id, a.name, a.description
    """)
    
    results = db.session.execute(sql, {'pid': current_user.player_id}).fetchall()

    return render_template('achievements.html', achievements=results)





@app.route('/logout')
@login_required
def logout():
    is_admin = current_user.is_authenticated and getattr(current_user, 'is_admin', False)
    logout_user()
    flash('Bạn đã đăng xuất.', 'info')
    
    if is_admin:
        return redirect(url_for('admin_login'))
    else:
        return redirect(url_for('login'))



if __name__ == "__main__":
    app.run(debug=True)