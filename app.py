from flask import Flask, request, jsonify
import subprocess

app = Flask(__name__)

@app.route('/generate', methods=['POST'])
def generate():
    data = request.get_json()
    code = data.get("code", "")
    language = data.get("language", "")

    try:
        result = subprocess.run(
            ["./codegen", language],
            input=code,
            capture_output=True,
            text=True
        )

        output = result.stdout
        error = result.stderr

        if error:
            return jsonify({"output": error})

        return jsonify({"output": output})

    except Exception as e:
        return jsonify({"output": str(e)})

if __name__ == "__main__":
    app.run(debug=True)
