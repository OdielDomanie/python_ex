import importlib
import sys

def server():
    while (
        (path_b := receive_prefix(b'p'))
        and (mod_b := receive_prefix(b'm'))
        and (fun_b := receive_prefix(b'f'))
        and (arg_b := receive_prefix(b'a'))
    ):
        # Path to the module directory/egg/etc.
        path = path_b.decode()
        # Module name
        mod_s = mod_b.decode()
        # Function name
        fun_s = fun_b.decode()
        # Argument as bytes

        sys.path.append(path)
        module = importlib.import_module(mod_s)

        fun = module.__dict__[fun_s]

        result: bytes = fun(arg_b)

        result_enc = (len(result) + 1).to_bytes(4, 'big') + b"r" + result
        sys.stdout.buffer.write(result_enc)
        sys.stdout.buffer.flush()

def receive_prefix(type):
    match receive():
        case False:
            return False
        case (prefix, payload) if prefix == type:
            return payload
        case (prefix, _) if prefix != type:
            raise Exception(f"Expected prefix {type}, got {prefix}")

def receive():
    msg_len_b = sys.stdin.buffer.read(4)
    if not msg_len_b:
        return False
    msg_len = int.from_bytes(msg_len_b, byteorder='big')
    assert msg_len > 0, f"msg_len: {msg_len_b}"
    msg_type = sys.stdin.buffer.read(1)
    msg_payload = sys.stdin.buffer.read(msg_len-1)
    if sys.stdin.buffer.closed:
        return False
    return (msg_type, msg_payload)

if __name__ == "__main__":
    server()
    print("Python server closed.", file=sys.stderr)
