import json
import os
import shutil


def get_files_to_remove(trigger_type: str) -> list[str]:
    """Get list of files to remove based on trigger type"""
    src_path = "src"
    interfaces_path = os.path.join(src_path, "interfaces")
    dto_path = os.path.join(interfaces_path, "dtos", "greeting")
    test_unit_path = os.path.join("tests", "unit", "interfaces")

    gcp_function_name = "{{ cookiecutter.gcp_function_name }}"

    files_map = {
        "http": [
            os.path.join(interfaces_path, "pubsub"),
            os.path.join(interfaces_path, "cli"),
            os.path.join(dto_path, "greeting_message.py"),
            os.path.join(dto_path, "greeting_cli_args.py"),
            os.path.join(test_unit_path, f"test_{gcp_function_name}_pubsub.py"),
        ],
        "pubsub": [
            os.path.join(interfaces_path, "http"),
            os.path.join(interfaces_path, "cli"),
            os.path.join(dto_path, "greeting_http_request.py"),
            os.path.join(dto_path, "greeting_http_response.py"),
            os.path.join(dto_path, "greeting_cli_args.py"),
            os.path.join(test_unit_path, f"test_{gcp_function_name}_http.py"),
        ],
        "cli": [
            os.path.join(interfaces_path, "http"),
            os.path.join(interfaces_path, "pubsub"),
            os.path.join(dto_path, "greeting_message.py"),
            os.path.join(dto_path, "greeting_http_request.py"),
            os.path.join(dto_path, "greeting_http_response.py"),
            os.path.join(test_unit_path, f"test_{gcp_function_name}_http.py"),
            os.path.join(test_unit_path, f"test_{gcp_function_name}_pubsub.py"),
        ],
    }

    return files_map.get(trigger_type, [])


def remove_file_or_directory(path: str) -> None:
    """Safely remove a file or directory if it exists"""
    if not os.path.exists(path):
        return

    if os.path.isdir(path):
        shutil.rmtree(path)
    else:
        os.remove(path)


def cleanup_unused_files() -> None:
    """Remove files/directories based on trigger type"""
    interface_type = "{{ cookiecutter.interface_type }}"

    files_to_remove = get_files_to_remove(interface_type)

    for file_path in files_to_remove:
        try:
            remove_file_or_directory(file_path)
        except Exception as e:
            print(f"Error removing {file_path}: {str(e)}")


def setup_trigger_config():
    """Setup trigger-specific configurations"""
    # interface_type = "{{ cookiecutter.interface_type }}"
    project_id = "{{ cookiecutter.gcp_project_id }}"
    project_number = "{{ cookiecutter.gcp_project_number }}"
    environment = "{{ cookiecutter.environment }}"

    # Create base .env file with server and basic settings
    with open(".env", "w") as f:
        f.write("# Server Settings\n")
        f.write("SERVER_SETTINGS__PORT=8080\n")
        f.write("SERVER_SETTINGS__LOG_LEVEL=debug\n")
        f.write("# Basic Settings\n")
        f.write(f"BASIC_SETTINGS__ENVIRONMENT={environment}\n")
        f.write(f"BASIC_SETTINGS__GCP_PROJECT_ID={project_id}\n")
        f.write(f"BASIC_SETTINGS__GCP_PROJECT_NUMBER={project_number}\n")
        f.write(
            f"BASIC_SETTINGS__APP_CONFIG_BUCKET=app-config-{project_number}-{environment}\n"
        )
        f.write(
            "BASIC_SETTINGS__GCP_SERVICE_NAME=say_hello_config\n"
        )


def main():
    cleanup_unused_files()
    setup_trigger_config()


if __name__ == "__main__":
    main()
