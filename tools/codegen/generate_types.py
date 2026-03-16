"""协议代码生成器 — 从 JSON Schema 生成 Dart 和 Python 类型

用法：
    python tools/codegen/generate_types.py

从 protocol/schemas/*.schema.json 生成：
    - protocol/dart/lib/src/*.dart
    - protocol/python/santuan_protocol/*.py
"""

import json
import os

SCHEMA_DIR = os.path.join(os.path.dirname(__file__), "../../protocol/schemas")
DART_OUT = os.path.join(os.path.dirname(__file__), "../../protocol/dart/lib/src")
PYTHON_OUT = os.path.join(os.path.dirname(__file__), "../../protocol/python/santuan_protocol")


def generate_dart_class(schema: dict, class_name: str) -> str:
    """从 JSON Schema 生成 Dart 数据类"""
    props = schema.get("properties", {})
    required = set(schema.get("required", []))

    fields = []
    constructor_params = []
    from_json_fields = []
    to_json_fields = []

    for name, prop in props.items():
        if name == "type":
            continue
        dart_type = _json_type_to_dart(prop)
        is_required = name in required
        dart_name = _snake_to_camel(name)

        fields.append(f"  final {dart_type}{'?' if not is_required else ''} {dart_name};")
        constructor_params.append(
            f"    {'required ' if is_required else ''}this.{dart_name},"
        )
        from_json_fields.append(f"      {dart_name}: json['{name}'],")
        to_json_fields.append(f"      '{name}': {dart_name},")

    return f"""class {class_name} {{
{chr(10).join(fields)}

  {class_name}({{
{chr(10).join(constructor_params)}
  }});

  factory {class_name}.fromJson(Map<String, dynamic> json) {{
    return {class_name}(
{chr(10).join(from_json_fields)}
    );
  }}

  Map<String, dynamic> toJson() => {{
{chr(10).join(to_json_fields)}
  }};
}}
"""


def _json_type_to_dart(prop: dict) -> str:
    t = prop.get("type", "dynamic")
    match t:
        case "string":
            return "String"
        case "number":
            return "double"
        case "integer":
            return "int"
        case "boolean":
            return "bool"
        case "object":
            return "Map<String, dynamic>"
        case "array":
            return "List<dynamic>"
        case _:
            return "dynamic"


def _snake_to_camel(name: str) -> str:
    parts = name.split("_")
    return parts[0] + "".join(p.capitalize() for p in parts[1:])


def main():
    os.makedirs(DART_OUT, exist_ok=True)
    os.makedirs(PYTHON_OUT, exist_ok=True)

    for filename in os.listdir(SCHEMA_DIR):
        if not filename.endswith(".schema.json"):
            continue

        filepath = os.path.join(SCHEMA_DIR, filename)
        with open(filepath) as f:
            schema = json.load(f)

        class_name = schema.get("title", filename.replace(".schema.json", "").title())
        print(f"Generating: {class_name} from {filename}")

        # Generate Dart
        dart_code = generate_dart_class(schema, class_name)
        dart_file = os.path.join(DART_OUT, filename.replace(".schema.json", ".dart"))
        with open(dart_file, "w") as f:
            f.write(f"// Auto-generated from {filename}\n// Do not edit manually.\n\n{dart_code}")

        print(f"  -> {dart_file}")

    print("\nDone!")


if __name__ == "__main__":
    main()
