from uuid import UUID

from Crypto.Cipher import AES


def int_to_uuid(value: int, key=b'0' * 16) -> str:
    cipher = AES.new(key, AES.MODE_ECB)
    v = int.to_bytes(value, 16, 'big')
    a = cipher.encrypt(v)
    uid = UUID(bytes=a)
    return str(uid)


def uuid_to_int(value: str, key=b'0' * 16) -> int:
    cipher = AES.new(key, AES.MODE_ECB)
    b = UUID(value).bytes
    c = cipher.decrypt(b)
    return int.from_bytes(c, 'big')


def main():
    value = 2 ** 33
    print(value)
    uid = int_to_uuid(value)
    print(uid)
    print(uuid_to_int(uid))


if __name__ == '__main__':
    main()
