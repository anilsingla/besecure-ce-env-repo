#!/bin/bash

function __besman_install {
    # Checks if GitHub CLI is present or not.
    __besman_check_vcs_exist || return 1

    # checks whether the user github id has been populated or not under BESMAN_USER_NAMESPACE
    __besman_check_github_id || return 1

    # check if python3 is installed if not install it.
    if [[ -z $(which python3) ]]; then
        __besman_echo_white "Python3 is not installed. Installing python3..."
        sudo apt-get update
        sudo apt-get install python3 -y
        [[ -z $(which python3) ]] && __besman_echo_red "Python3 installation failed" && return 1
    fi

    __besman_repo_clone "$BESMAN_ORG" "PurpleLlama" "$BESMAN_TOOL_PATH" || return 1

    __besman_echo_white "Installing Cybersecurity Benchmarks..."
    python3 -m venv ~/.venvs/cyberseceval
    source ~/.venvs/cyberseceval/bin/activate
    cd "$BESMAN_TOOL_PATH" || { __besman_echo_red "Could not move to $BESMAN_TOOL_PATH" && return 1; }
    pip3 install -r CybersecurityBenchmarks/requirements.txt
    python3 -m pip install transformers torch boto3
    [[ $? -ne 0 ]] && __besman_echo_red "Failed to install CybersecurityBenchmarks" && return 1
    deactivate
    __besman_echo_no_colour ""
    __besman_echo_green "CybersecurityBenchmarks installed successfully"
    __besman_echo_no_colour ""
    __besman_echo_white "Installing codeshield"
    python3 -m venv ~/.venvs/codeshield_env
    source ~/.venvs/codeshield_env/bin/activate
    python3 -m pip install codeshield
    [[ $? -ne 0 ]] && __besman_echo_red "Failed to install codeshield" && return 1
    __besman_echo_no_colour ""
    __besman_echo_green "codeshield installed successfully"
    deactivate
    cd "$HOME"

    # Installing ollama
    __besman_echo_white "Installing ollama..."
    if [[ -z $(which ollama) ]]; then
        # Placeholder for actual ollama installation command.
        curl -sSL https://ollama.com/install | bash
        if [[ $? -ne 0 ]]; then
            __besman_echo_red "ollama installation failed" && return 1
        fi
    else
        __besman_echo_white "ollama is already installed."
    fi
    __besman_echo_green "ollama installed successfully"
}

function __besman_uninstall {

    __besman_echo_white "Uninstalling CybersecurityBenchmarks..."
    source ~/.venvs/cyberseceval/bin/activate
    cd "$BESMAN_TOOL_PATH" || { __besman_echo_red "Could not move to $BESMAN_TOOL_PATH" && return 1; }
    pip3 uninstall -y CybersecurityBenchmarks
    [[ $? -ne 0 ]] && __besman_echo_red "Failed to uninstall CybersecurityBenchmarks" && return 1
    deactivate
    __besman_echo_no_colour ""
    __besman_echo_green "CybersecurityBenchmarks uninstalled successfully"
    __besman_echo_no_colour ""
    __besman_echo_white "Uninstalling codeshield"
    source ~/.venvs/codeshield_env/bin/activate
    python3 -m pip uninstall -y codeshield
    [[ $? -ne 0 ]] && __besman_echo_red "Failed to uninstall codeshield" && return 1
    deactivate
    __besman_echo_no_colour ""
    __besman_echo_green "codeshield uninstalled successfully"
    __besman_echo_no_colour ""

    # Uninstalling ollama
    __besman_echo_white "Uninstalling ollama..."
    if [[ $(which ollama) ]]; then
        # Placeholder for actual ollama uninstallation command.
        sudo rm -f "$(which ollama)"
        if [[ $? -ne 0 ]]; then
            __besman_echo_red "ollama uninstallation failed" && return 1
        fi
    else
        __besman_echo_white "ollama is not installed."
    fi
    __besman_echo_green "ollama uninstalled successfully"
    __besman_echo_no_colour ""

    __besman_echo_white "Removing $BESMAN_TOOL_PATH"
    rm -rf "$BESMAN_TOOL_PATH"
    [[ $? -ne 0 ]] && __besman_echo_red "Failed to remove $BESMAN_TOOL_PATH" && return 1
    __besman_echo_no_colour ""
    __besman_echo_green "$BESMAN_TOOL_PATH removed successfully"
    __besman_echo_no_colour ""
    __besman_echo_green "Uninstallation completed successfully"
    [[ -d ~/.venvs/codeshield_env ]] && rm -rf ~/.venvs/codeshield_env
    [[ -d ~/.venvs/cyberseceval ]] && rm -rf ~/.venvs/cyberseceval
    cd "$HOME"
}

function __besman_update {
    __besman_echo_white "Updating CybersecurityBenchmarks..."
    cd "$BESMAN_TOOL_PATH" || { __besman_echo_red "Could not move to $BESMAN_TOOL_PATH" && return 1; }
    git pull origin main || { __besman_echo_red "Failed to update CybersecurityBenchmarks" && return 1; }
    __besman_echo_green "CybersecurityBenchmarks updated successfully"
    __besman_echo_no_colour ""
    __besman_echo_white "Updating codeshield..."
    source ~/.venvs/codeshield_env/bin/activate
    python3 -m pip install --upgrade codeshield || { __besman_echo_red "Failed to update codeshield" && return 1; }
    deactivate
    __besman_echo_green "codeshield updated successfully"
    __besman_echo_no_colour ""
    __besman_echo_white "Updating ollama..."
    # Placeholder for actual ollama update command.
    ollama update
    if [[ $? -ne 0 ]]; then
        __besman_echo_red "Failed to update ollama" && return 1
    fi
    __besman_echo_green "ollama updated successfully"
    cd "$HOME"
}

function __besman_validate {
    __besman_echo_white "Validating installations and folders..."
    # Validate Python3
    if [[ -z $(which python3) ]]; then
        __besman_echo_red "Python3 is not installed." && return 1
    fi

    # Validate CybersecurityBenchmarks venv folder
    if [[ ! -d ~/.venvs/cyberseceval ]]; then
        __besman_echo_red "CybersecurityBenchmarks venv folder missing." && return 1
    fi

    # Validate codeshield venv folder
    if [[ ! -d ~/.venvs/codeshield_env ]]; then
        __besman_echo_red "codeshield venv folder missing." && return 1
    fi

    # Validate BESMAN_TOOL_PATH folder
    if [[ ! -d "$BESMAN_TOOL_PATH" ]]; then
        __besman_echo_red "$BESMAN_TOOL_PATH does not exist." && return 1
    fi

    # Validate ollama installation
    if [[ -z $(which ollama) ]]; then
        __besman_echo_red "ollama is not installed." && return 1
    fi

    __besman_echo_green "Validation successful. All tools and folders are present."
}

function __besman_reset {
    __besman_echo_white "Resetting everything back to default..."
    __besman_uninstall
    __besman_install
    __besman_echo_green "Reset to default completed successfully."
}
