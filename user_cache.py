cache = {}

def get_user(uid):
    if uid in cache:
        return cache[uid]
    user = load_user(uid)
    cache[uid] = user
    return user
