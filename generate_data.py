import json

json_path = r"C:\Users\Web\AppData\Local\Pub\Cache\git\csc_picker-eb9647649279577a72eab7c4e64ddede3fde9e66\lib\assets\country.json"
output_path = r"c:\Users\Web\.gemini\antigravity\scratch\blantons\lib\core\constants\country_state_data.dart"

try:
    with open(json_path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    result = {}
    for country in data:
        country_name = country.get('name')
        if not country_name:
            continue
        states = country.get('state', [])
        state_names = []
        for state in states:
            state_name = state.get('name')
            if state_name:
                state_names.append(state_name)
        # Sort state names
        state_names.sort()
        result[country_name] = state_names

    # Write to Dart file
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write("// Generated file. Do not edit manually.\n\n")
        f.write("const Map<String, List<String>> countryStateData = {\n")
        # Sort countries by name
        for country in sorted(result.keys()):
            states_list = result[country]
            # Escape strings if necessary
            safe_states = [s.replace('\\', '\\\\').replace('"', '\\"') for s in states_list]
            states_str = ", ".join([f'"{s}"' for s in safe_states])
            safe_country = country.replace('\\', '\\\\').replace('"', '\\"')
            f.write(f'  "{safe_country}": [{states_str}],\n')
        f.write("};\n")

    print("SUCCESS: Generated countryStateData in Dart.")
except Exception as e:
    print("ERROR:", e)
