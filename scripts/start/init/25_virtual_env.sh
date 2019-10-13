#!/in/bash

info "Create default virtual env for user ${USERNAME}"

export VENV="odoo-12.0"
export VENV_PATH="${USER_HOME}/.local/share/virtualenvs/${VENV}"

sudo -u "$USERNAME" -H pew new "$VENV" -d
sudo -u "$USERNAME" -H pew in "$VENV" pip install -r /tmp/setup/odoo/requirements.txt

success "Virtual env $VENV created for ${USERNAME}"
