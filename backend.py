import subprocess
from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route('/generate', methods=['POST'])
def generate():
    data = request.json
    code = data['code']
    lang = data['language']

    # Save input to file
    with open("input.txt", "w") as f:
        f.write(code)

    try:
        # Run your compiler
        result = subprocess.run(
            ["./codegen"],
            stdin=open("input.txt"),
            capture_output=True,
            text=True
        )

        output = result.stdout

    except Exception as e:
        output = str(e)

    return jsonify({"output": output})


if __name__ == "__main__":
    app.run(debug=True)
