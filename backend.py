from flask import Flask, request, jsonify
import subprocess
import os

app = Flask(__name__)

# Path to your compiled Lex/Yacc executable
COMPILER_PATH = "./codegen"   # make sure this file exists

@app.route('/generate', methods=['POST'])
def generate():
    data = request.get_json()

    pseudo_code = data.get("code", "")
    language = data.get("language", "")

    if not pseudo_code:
        return jsonify({"output": "No input provided"}), 400

    try:
        # Run your compiler and pass pseudo code as input
        result = subprocess.run(
            [COMPILER_PATH, language],   # pass language as argument
            input=pseudo_code,
            capture_output=True,
            text=True
        )

        # Capture output and errors
        output = result.stdout
        error = result.stderr

        if error:
            return jsonify({"output": f"Error:\n{error}"})

        return jsonify({"output": output})

    except FileNotFoundError:
        return jsonify({
            "output": "Compiler executable not found. Make sure './codegen' is built."
        })

    except Exception as e:
        return jsonify({"output": str(e)})


if __name__ == "__main__":
    app.run(debug=True)
