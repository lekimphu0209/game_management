sessions = db.session.execute(text("""
        SELECT 
            gs.session_id, gs.start_time, gs.end_time, gs.final_score,
            i.name AS weapon_name
        FROM game_sessions gs
        LEFT JOIN character_equipment ce ON ce.character_id = gs.character_id
        LEFT JOIN items i ON i.item_id = ce.item_id
        WHERE gs.player_id = :pid
        ORDER BY gs.start_time DESC
    """), {'pid': pid}).fetchall()

    player = Player.query.get(pid)

    return render_template('admin_sessions.html', sessions=sessions, player=player)
