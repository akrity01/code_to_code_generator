from flask import Flask, request, jsonify

app = Flask(__name__)

def generate_code(pseudo, lang):
    pseudo = pseudo.lower()

    # VERY BASIC LOGIC (you will later replace with compiler output)

    if "print" in pseudo:
        value = pseudo.split("print")[1].strip()

        if lang == "python":
            return f"print({value})"

        elif lang == "java":
            return f"System.out.println({value});"

        elif lang == "cpp":
            return f"#include<iostream>\nusing namespace std;\nint main(){{\n cout << {value};\n return 0;\n}}"

        elif lang == "c":
            return f"#include<stdio.h>\nint main(){{\n printf(\"%d\", {value});\n return 0;\n}}"

    return "Invalid or unsupported pseudo code"


@app.route('/generate', methods=['POST'])
def generate():
    data = request.json
    code = data['code']
    lang = data['language']

    output = generate_code(code, lang)
    return jsonify({"output": output})


if __name__ == "__main__":
    app.run(debug=True)
