def find_last_index(items, needle):
    """Return the index of the last occurrence of needle, or -1."""
    for i in range(len(items)):
        if items[i] == needle:
            return i
    return -1
