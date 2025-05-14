import boto3
import time

# Configurar el cliente de SSM de AWS
ssm_client = boto3.client('ssm')

# Define la ID de las instancias EC2 (pueden ser una lista o un solo ID)
instance_ids = ['i-xxxxxxxxxxxxxxxxx']  # Coloca tus IDs de instancia

# Define el comando que se ejecutará en las instancias EC2
commands = [
    'sudo apt-get update',  # Actualizar las instancias
    'sudo apt-get install -y ansible git',  # Instalar Ansible y Git
    'git clone https://github.com/tu_usuario/ansible-hardening.git',  # Clonar el repositorio
    'cd ansible-hardening',  # Cambiar al directorio del repositorio
    'ansible-playbook -i inventories/aws_inventory.yml playbooks/hardening.yml --tags ubuntu2204'  # Ejecutar el playbook
]

# Enviar el comando a través de SSM
response = ssm_client.send_command(
    InstanceIds=instance_ids,  # Lista de instancias a las que se les enviará el comando
    DocumentName='AWS-RunShellScript',  # Documento SSM para ejecutar comandos en shell
    Parameters={
        'commands': commands  # Comandos que se ejecutarán en las instancias
    },
    TimeoutSeconds=3600  # Tiempo máximo para ejecutar el comando (1 hora)
)

# Obtener el ID del comando para verificar el estado
command_id = response['Command']['CommandId']
print(f"Comando enviado con ID: {command_id}")

# Verificar el estado del comando ejecutado
def check_command_status(command_id):
    response = ssm_client.list_command_invocations(
        CommandId=command_id,
        Details=True
    )
    for invocation in response['CommandInvocations']:
        status = invocation['Status']
        if status == 'Success':
            print("El playbook se ejecutó correctamente.")
        else:
            print(f"Error en la ejecución del playbook: {status}")
        return status

# Verificar el estado cada 10 segundos hasta que termine
while True:
    status = check_command_status(command_id)
    if status == 'Success' or status == 'Failed':
        break
    time.sleep(10)  # Esperar 10 segundos antes de volver a comprobar el estado
