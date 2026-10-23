#!/usr/bin/env bash
# Recorre todos los labs.
#   bash scripts/test-all.sh validate   -> init (sin backend) + validate   (no necesita moto)
#   bash scripts/test-all.sh apply      -> init + apply + destroy contra moto/docker
set -uo pipefail
MODE="${1:-validate}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export TF_IN_AUTOMATION=1 TF_INPUT=0
export TF_PLUGIN_CACHE_DIR="${TF_PLUGIN_CACHE_DIR:-$HOME/.terraform.d/plugin-cache}"
mkdir -p "$TF_PLUGIN_CACHE_DIR"

# Orden importa: 06-00 crea el bucket/tabla que usan 06-01, 06-02 y 07-v2.
LABS=(
  03-resources/03-01-resource-behavior
  03-resources/03-02-depends-on
  03-resources/03-03-count
  03-resources/03-04-for-each/v1-for_each-maps
  03-resources/03-04-for-each/v2-for_each-toset
  03-resources/03-04-for-each/v3-count-vs-for_each
  03-resources/03-05-lifecycle/v1-create_before_destroy
  03-resources/03-05-lifecycle/v2-prevent_destroy
  03-resources/03-05-lifecycle/v3-ignore_changes
  04-variables/04-01-input-variables/v1-asignar-valores
  04-variables/04-01-input-variables/v2-prompt
  04-variables/04-01-input-variables/v3-tipos-y-validacion
  04-variables/04-01-input-variables/v4-sensitive
  04-variables/04-02-output-values
  04-variables/04-03-local-values
  05-datasources
  06-state/06-00-backend-bootstrap
  06-state/06-01-remote-state-locking
  06-state/06-02-state-commands
  07-workspaces/v1-local-backend
  07-workspaces/v2-remote-backend
  08-provisioners/08-01-file-provisioner
  08-provisioners/08-02-remote-exec-provisioner
  08-provisioners/08-03-local-exec-provisioner
  08-provisioners/08-04-null-resource
  08-provisioners/aws-ec2-reference
  09-modules/09-01-module-basics
  09-modules/09-02-build-a-module/v2-terraform-resources
  09-modules/09-02-build-a-module/v3-module
  10-gitops-github-actions/terraform-manifests
)

# Argumentos extra por lab (variables que en el lab se pasan a mano)
extra_args() {
  case "$1" in
    */v2-prompt) echo "-var=ec2_instance_type=t3.micro" ;;
    */v4-sensitive) echo "-var-file=secrets.tfvars.example" ;;
    10-gitops-github-actions/*) echo "-var=aws_region=us-east-1 -var=instance_type=t3.micro" ;;
  esac
}

FAILED=()
run() { echo "  \$ terraform $*"; terraform "$@" -no-color > /tmp/tf.log 2>&1 || { tail -25 /tmp/tf.log; return 1; }; }

for lab in "${LABS[@]}"; do
  echo "::group::$lab"
  cd "$ROOT/$lab" || exit 1
  args=$(extra_args "$lab")
  ok=true
  if [ "$MODE" = "validate" ]; then
    run init -backend=false && run validate || ok=false
  else
    case "$lab" in
      */aws-ec2-reference) run init -backend=false && run validate || ok=false ;; # SSH a EC2 real: solo validate
      *)
        bcfg=""; [ -f backend-moto.hcl ] && bcfg="-reconfigure -backend-config=backend-moto.hcl"
        run init $bcfg || ok=false
        $ok && { run apply -auto-approve $args || ok=false; }
        # prevent_destroy: el destroy DEBE fallar (es lo que enseña el lab)
        if [[ "$lab" == */v2-prevent_destroy ]]; then
          terraform destroy -auto-approve -no-color >/dev/null 2>&1 && ok=false
          echo "  (destroy bloqueado por prevent_destroy: OK)"
        elif [[ "$lab" != 06-state/06-00-backend-bootstrap ]]; then
          $ok && { run destroy -auto-approve $args || ok=false; }
        fi
        ;;
    esac
  fi
  $ok && echo "  ✅ $lab" || { echo "  ❌ $lab"; FAILED+=("$lab"); }
  echo "::endgroup::"
done

if [ "$MODE" = "apply" ]; then
  cd "$ROOT/06-state/06-00-backend-bootstrap" && run destroy -auto-approve || FAILED+=("06-00 destroy")
fi

echo
if [ ${#FAILED[@]} -eq 0 ]; then echo "✅ Todos los labs OK ($MODE)"; else printf '❌ Fallaron:\n'; printf '  - %s\n' "${FAILED[@]}"; exit 1; fi
