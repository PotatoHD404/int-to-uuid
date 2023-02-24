from uuid import UUID

from Crypto.Cipher import AES


def int2uuid(value: int, key: bytes) -> str:
    cipher = AES.new(key, AES.MODE_ECB)
    v = int.to_bytes(value, 8, 'big')
    print(v)
    a = cipher.encrypt(v)
    uid = UUID(bytes=a)
    return str(uid)


def uuid2int(value: str, key: bytes) -> int:
    cipher = AES.new(key, AES.MODE_ECB)
    b = UUID(value).bytes
    c = cipher.decrypt(b)
    return int.from_bytes(c, 'big')


def main():
    value = 2 ** 33
    print(value)
    key = bytes.fromhex('00000000000000000000000000000000')
    uid = int2uuid(value, key)
    print(uid)
    print(uuid2int(uid, key))


if __name__ == '__main__':
    main()
