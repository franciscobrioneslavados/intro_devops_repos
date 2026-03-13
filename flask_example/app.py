from flask import Flask, jsonify, request

app = Flask(__name__)


@app.route("/")
def home():
    return "Hola desde Flask y Docker/Podman!"


def parse_arg(name):
    try:
        return float(request.args.get(name, 0))
    except (TypeError, ValueError):
        return 0.0


@app.route("/sum")
def sum_values():
    a = parse_arg("a")
    b = parse_arg("b")
    return jsonify(result=a + b)


@app.route("/subtract")
def subtract_values():
    a = parse_arg("a")
    b = parse_arg("b")
    return jsonify(result=a - b)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
