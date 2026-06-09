#!/bin/bash

set -euo pipefail

# Script to update Swift Package dependencies
# Supports Xcode projects (.xcodeproj) and Xcode workspaces (.xcworkspace) and Swift packages (Package.swift)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Global temp file for cleanup
TEMP_STATE_FILE=""

# Cleanup function for temp files
cleanup_temp_files() {
    if [ -n "$TEMP_STATE_FILE" ] && [ -f "$TEMP_STATE_FILE" ]; then
        rm -f "$TEMP_STATE_FILE"
    fi
}

# Function to detect project type
detect_project_type() {
    local project_path="$1"

    if [[ "$project_path" == *.xcodeproj ]] && [ -d "$project_path" ]; then
        echo "xcode"
    elif [[ "$project_path" == *.xcworkspace ]] && [ -d "$project_path" ]; then
        echo "xcworkspace"
    elif [ -f "$project_path/Package.swift" ]; then
        echo "swift-package"
    else
        echo "unknown"
    fi
}

# Function to get Package.resolved path based on project type
get_package_resolved_path() {
    local project_path="$1"
    local project_type="$2"

    case "$project_type" in
        "xcode")
            echo "$project_path/project.xcworkspace/xcshareddata/swiftpm/Package.resolved"
            ;;
        "xcworkspace")
            echo "$project_path/xcshareddata/swiftpm/Package.resolved"
            ;;
        "swift-package")
            echo "$project_path/Package.resolved"
            ;;
        *)
            echo ""
            ;;
    esac
}

# Function to show current package versions
show_current_versions() {
    local package_resolved_path="$1"
    local project_type="$2"

    if ! command -v jq &> /dev/null; then
        print_warning "jq not available, skipping version display"
        return 1
    fi

    print_info "Current package versions:"

    case "$project_type" in
        "xcode"|"xcworkspace"|"swift-package")
            jq -r '.pins[] | "  \(.identity): \(.state.revision[:8]) (\(.state.branch // .state.version // "commit"))"' "$package_resolved_path"
            ;;
    esac

    return 0
}

# Function to save current state for comparison
save_current_state() {
    local package_resolved_path="$1"
    local project_type="$2"

    if ! command -v jq &> /dev/null; then
        echo ""
        return
    fi

    local temp_file=$(mktemp)

    case "$project_type" in
        "xcode"|"xcworkspace"|"swift-package")
            jq -r '.pins[] | "\(.identity): \(.state.revision[:8])"' "$package_resolved_path" | sort > "$temp_file"
            ;;
    esac

    TEMP_STATE_FILE="$temp_file"
    echo "$temp_file"
}

clean_derived_data() {
    local derived_data="$HOME/Library/Developer/Xcode/DerivedData"
    local project_path="$1"

    # Check if DerivedData directory exists
    if [ ! -d "$derived_data" ]; then
        return 0
    fi

    # Extract project name from path (remove directory path and extension)
    local project_name=$(basename "$project_path")

    # Remove .xcodeproj or .xcworkspace extension if present
    project_name="${project_name%.xcodeproj}"
    project_name="${project_name%.xcworkspace}"

    print_info "Cleaning derived data for project: $project_name"

    # Find and remove folders that start with the project name followed by a dash
    local removed_count=0
    for folder in "$derived_data"/"$project_name"-*; do
        if [ -d "$folder" ]; then
            # print_info "Removing: $(basename "$folder")"
            rm -rf "$folder"
            removed_count=$((removed_count + 1))
        fi
    done

    # if [ $removed_count -eq 0 ]; then
    #     print_info "No derived data folders found for project: $project_name"
    # else
    #     print_success "Removed $removed_count derived data folder(s) for project: $project_name"
    # fi
}

# Reconstruct the canonical Package.resolved from a resolved DerivedData workspace-state.json.
#
# `xcodebuild -resolvePackageDependencies` resolves remote packages into
# DerivedData/<project>-*/SourcePackages/workspace-state.json but, for projects
# that reference local Swift packages by folder, does NOT write the canonical
# project.xcworkspace/xcshareddata/swiftpm/Package.resolved (only the Xcode IDE
# does). This rebuilds that pin file from workspace-state.json's remote
# source-control dependencies, preserving the passed-in originHash (which depends
# on the declared dependency graph, not the resolved revisions).
#
# Args: <project_path> <dest_package_resolved> <origin_hash>
# Returns 0 and writes dest on success; non-zero if no workspace-state.json or
# no remote pins were found (e.g. python3 missing, or local-only dependencies).
regenerate_package_resolved() {
    local project_path="$1"
    local dest="$2"
    local origin_hash="$3"

    if ! command -v python3 &> /dev/null; then
        echo "python3 is not installed"
        return 1
    fi

    # Find the newest DerivedData workspace-state.json for this project.
    local project_name=$(basename "$project_path")
    project_name="${project_name%.xcodeproj}"
    project_name="${project_name%.xcworkspace}"
    local derived_data="$HOME/Library/Developer/Xcode/DerivedData"
    local ws_state=""
    local candidate
    for candidate in $(ls -dt "$derived_data/$project_name"-*/SourcePackages/workspace-state.json 2>/dev/null); do
        ws_state="$candidate"
        break
    done
    if [ -z "$ws_state" ] || [ ! -f "$ws_state" ]; then
        return 1
    fi

    mkdir -p "$(dirname "$dest")"
    python3 - "$ws_state" "$dest" "$origin_hash" <<'PY'
import json, sys
ws, dest, origin_hash = sys.argv[1], sys.argv[2], sys.argv[3]
state = json.load(open(ws))
pins = []
for dep in state.get('object', {}).get('dependencies', []):
    ref = dep.get('packageRef', {})
    kind = ref.get('kind')
    if kind == 'fileSystem':
        continue  # local packages are not pinned
    cs = dep.get('state', {}).get('checkoutState', {})
    st = {}
    if cs.get('branch'):
        st['branch'] = cs['branch']
    if cs.get('version'):
        st['version'] = cs['version']
    if 'revision' in cs:
        st['revision'] = cs['revision']
    pins.append({
        'identity': ref.get('identity'),
        'kind': kind,
        'location': ref.get('location'),
        'state': st,
    })
if not pins:
    sys.exit(2)  # nothing to pin (local-only dependencies)
out = {}
if origin_hash:
    out['originHash'] = origin_hash
out['pins'] = pins
# version 3 is the originHash-bearing format (Xcode 16+); version 2 predates it.
out['version'] = 3 if origin_hash else 2
# Match SwiftPM/Xcode's Package.resolved formatting: alphabetically sorted keys,
# a space on both sides of the colon, and a trailing newline.
with open(dest, 'w') as f:
    json.dump(out, f, indent=2, separators=(',', ' : '), sort_keys=True)
    f.write('\n')
PY
}

write_empty_package_resolved() {
    local dest="$1"
    local origin_hash="$2"

    mkdir -p "$(dirname "$dest")"
    if [ -n "$origin_hash" ]; then
        cat > "$dest" <<EOF
{
  "originHash" : "$origin_hash",
  "pins" : [

  ],
  "version" : 3
}
EOF
    else
        cat > "$dest" <<'EOF'
{
  "pins" : [

  ],
  "version" : 2
}
EOF
    fi
}

package_resolved_has_pins() {
    local package_resolved_path="$1"

    if [ ! -f "$package_resolved_path" ]; then
        return 1
    fi

    if command -v jq &> /dev/null; then
        jq -e '(.pins // []) | length > 0' "$package_resolved_path" >/dev/null 2>&1
        return $?
    fi

    if command -v python3 &> /dev/null; then
        python3 - "$package_resolved_path" <<'PY'
import json, sys
try:
    with open(sys.argv[1]) as f:
        data = json.load(f)
    sys.exit(0 if len(data.get("pins") or []) > 0 else 1)
except Exception:
    sys.exit(1)
PY
        return $?
    fi

    grep -q '"identity"' "$package_resolved_path"
}

# Function to update Xcode project packages
update_xcode_project() {
    local project_path="$1"
    local package_resolved_path="$2"

    # Check if xcodebuild is available
    if ! command -v xcodebuild &> /dev/null; then
        print_error "xcodebuild is required but not found. Make sure Xcode Command Line Tools are installed."
        return 1
    fi

    print_info "Updating Xcode project packages..."

    # Back up the committed Package.resolved and remember its originHash.
    # `xcodebuild -resolvePackageDependencies` preserves existing pins when the
    # file is present, but can write into a local package's Package.resolved when
    # the file is missing. Seed this project's own Package.resolved with an empty
    # valid file so Xcode updates the intended artifact.
    local backup=""
    local origin_hash=""
    if [ -f "$package_resolved_path" ]; then
        backup="$(mktemp)"
        cp "$package_resolved_path" "$backup"
        print_info "Backed up $package_resolved_path to $backup"
        if command -v python3 &> /dev/null; then
            origin_hash=$(python3 -c "import json,sys;print(json.load(open(sys.argv[1])).get('originHash',''))" "$backup" 2>/dev/null)
        fi
    fi
    print_info "Resetting $package_resolved_path for package update..."
    write_empty_package_resolved "$package_resolved_path" "$origin_hash"

    # Clean derived data
    clean_derived_data "$project_path"

    # Run the update command to fetch latest versions.
    #
    # Note: `xcodebuild -resolvePackageDependencies` crashes intermittently with "Abort trap: 6" inside Xcode's own
    # SwiftPM integration (IDESwiftPackageCore), so retry a few times before treating it as a real failure.
    print_info "Resolving package dependencies..."
    local max_attempts=3
    local attempt=1
    local resolved=false
    while [ $attempt -le $max_attempts ]; do
        if xcodebuild -resolvePackageDependencies -project "$project_path" >/dev/null 2>&1; then
            resolved=true
            break
        fi
        if [ $attempt -lt $max_attempts ]; then
            print_info "Resolve failed (attempt $attempt/$max_attempts), retrying..."
            sleep 2
        fi
        attempt=$((attempt + 1))
    done

    if [ "$resolved" != true ]; then
        # Restore the backup so a failed resolve never leaves pins deleted.
        if [ -n "$backup" ]; then
            cp "$backup" "$package_resolved_path"
        else
            # no backup file, means there's no Package.resolved before, remove the empty generated file
            rm -f "$package_resolved_path"
        fi
        rm -f "$backup"
        print_error "Failed to resolve package dependencies after $max_attempts attempts"
        return 1
    fi

    # If xcodebuild didn't populate the seeded canonical pin file, rebuild it from
    # the resolved DerivedData state so the committed file matches what Xcode
    # resolved. Fall back to restoring the backup if regeneration isn't possible.
    if [ ! -f "$package_resolved_path" ] || ! package_resolved_has_pins "$package_resolved_path"; then
        if regenerate_package_resolved "$project_path" "$package_resolved_path" "$origin_hash"; then
            print_info "Regenerated $package_resolved_path from resolved dependencies."
        elif [ -n "$backup" ]; then
            cp "$backup" "$package_resolved_path"
            print_warning "Could not update Package.resolved, restored existing Package.resolved (Open in Xcode to manually update)."
        else
            rm -f "$package_resolved_path"
            print_warning "Package.resolved still has no pins after resolution; removed the empty generated file."
        fi
    fi
    rm -f "$backup"
    return 0
}

# Function to update Xcode workspace packages
update_xcworkspace() {
    local project_path="$1"
    local package_resolved_path="$2"

    # Check if Package.resolved exists
    if [ ! -f "$package_resolved_path" ]; then
        print_info "Package.resolved not found at $package_resolved_path"
        return 1
    fi

    # Check if swift is available
    if ! command -v swift &> /dev/null; then
        print_error "swift command is required but not found. Make sure Swift is installed."
        return 1
    fi

    print_info "Updating Xcode workspace packages..."

    local workspace_dir=$(dirname "$project_path")

    # Change to workspace directory (which should be the package directory)
    local original_dir=$(pwd)
    cd "$workspace_dir"

    # The package-level Package.resolved path
    local package_level_resolved="$workspace_dir/Package.resolved"
    local package_level_backup=""
    if [ -f "$package_level_resolved" ]; then
        package_level_backup="$(mktemp)"
        cp "$package_level_resolved" "$package_level_backup"
        print_info "Backed up $package_level_resolved to $package_level_backup"
    fi

    # Run the update command to fetch latest versions
    print_info "Updating package dependencies..."
    if swift package update >/dev/null 2>&1; then
        # copy package-level Package.resolved to workspace location
        local workspace_package_resolved="$project_path/xcshareddata/swiftpm/Package.resolved"
        print_info "Copying $package_level_resolved to $workspace_package_resolved..."
        cp "$package_level_resolved" "$workspace_package_resolved"
        # print_success "Package update completed"
        cd "$original_dir"
        rm -f "$package_level_backup"
        return 0
    else
        if [ -n "$package_level_backup" ]; then
            cp "$package_level_backup" "$package_level_resolved"
            rm -f "$package_level_backup"
        fi
        cd "$original_dir"
        print_error "Failed to resolve package dependencies"
        return 1
    fi
}

# Function to update Swift package dependencies
update_swift_package() {
    local project_path="$1"
    local package_resolved_path="$2"

    # Check if swift is available
    if ! command -v swift &> /dev/null; then
        print_error "swift command is required but not found. Make sure Swift is installed."
        return 1
    fi

    print_info "Updating Swift package dependencies..."

    # Change to project directory
    local original_dir=$(pwd)
    cd "$project_path"

    local backup=""
    if [ -f "$package_resolved_path" ]; then
        backup="$(mktemp)"
        cp "$package_resolved_path" "$backup"
    fi

    # Run the update command to fetch latest versions
    print_info "Updating package dependencies..."
    if swift package update >/dev/null 2>&1; then
        # Check if Package.resolved was created (indicates remote dependencies)
        # if [ -f "$package_resolved_path" ]; then
        #     print_success "Package update completed"
        # else
        #     print_success "No Package.resolved found - This package may only have local path dependencies"
        # fi
        cd "$original_dir"
        rm -f "$backup"
        return 0
    else
        if [ -n "$backup" ]; then
            cp "$backup" "$package_resolved_path"
            rm -f "$backup"
        fi
        cd "$original_dir"
        print_error "Failed to resolve package dependencies"
        return 1
    fi
}

# Function to show package changes
show_package_changes() {
    local package_resolved_path="$1"
    local project_type="$2"
    local temp_old="$3"

    if ! command -v jq &> /dev/null || [ ! -f "$temp_old" ]; then
        return
    fi

    print_info "Updated package versions:"

    case "$project_type" in
        "xcode"|"xcworkspace"|"swift-package")
            jq -r '.pins[] | "  \(.identity): \(.state.revision[:8]) (\(.state.branch // .state.version // "commit"))"' "$package_resolved_path"
            ;;
    esac

    # Show what changed
    print_info "Changes:"
    local temp_new=$(mktemp)

    case "$project_type" in
        "xcode"|"xcworkspace"|"swift-package")
            jq -r '.pins[] | "\(.identity): \(.state.revision[:8])"' "$package_resolved_path" | sort > "$temp_new"
            ;;
    esac

    # Check if any packages actually changed
    local changes_found=false
    while IFS= read -r line; do
        local package=$(echo "$line" | cut -d: -f1)
        local old_version=$(echo "$line" | cut -d: -f2 | xargs)
        local new_line=$(grep "^$package:" "$temp_new" || echo "")
        if [ -n "$new_line" ]; then
            local new_version=$(echo "$new_line" | cut -d: -f2 | xargs)
            if [ "$old_version" != "$new_version" ]; then
                echo "  $package: $old_version → $new_version"
                changes_found=true
            fi
        fi
    done < "$temp_old"

    # Also check for any new packages that weren't in the old file
    while IFS= read -r line; do
        local package=$(echo "$line" | cut -d: -f1)
        if ! grep -q "^$package:" "$temp_old" 2>/dev/null; then
            local new_version=$(echo "$line" | cut -d: -f2 | xargs)
            echo "  $package: $new_version (new)"
            changes_found=true
        fi
    done < "$temp_new"

    if [ "$changes_found" = false ]; then
        echo "  No changes - packages were already up to date"
    fi

    rm -f "$temp_new"
}

# Main function
main() {
    # Check if project path is provided
    if [ $# -eq 0 ]; then
        print_error "Usage: $0 <path>"
        print_info "Examples:"
        print_info "  $0 /path/to/MyApp.xcodeproj     # Update Xcode project packages"
        print_info "  $0 /path/to/MyApp.xcworkspace   # Update Xcode workspace packages"
        print_info "  $0 /path/to/MyPackage           # Update Swift package dependencies"
        exit 1
    fi

    print_info "Updating Swift packages..."

    local project_path=$(realpath "$1")
    print_info "Path: $project_path"
    local temp_old=""

    # Setup cleanup trap for temp files
    trap cleanup_temp_files EXIT

    # Validate project path
    if [ ! -e "$project_path" ]; then
        print_error "Project path does not exist: $project_path"
        exit 1
    fi

    # Detect project type
    local project_type=$(detect_project_type "$project_path")
    if [ "$project_type" = "unknown" ]; then
        print_error "Unknown project type. Expected .xcodeproj, .xcworkspace, or directory with Package.swift"
        exit 1
    fi

    # print_info "Type: $project_type"

    # Get Package.resolved path
    local package_resolved_path=$(get_package_resolved_path "$project_path" "$project_type")

    # Check if package dependencies exist or can be resolved
    local has_dependencies=false

    case "$project_type" in
        "xcode")
            # For xcode projects, Package.resolved may not exist if using local packages or if the project hasn't resolved dependencies yet
            has_dependencies=true
            if [ ! -f "$package_resolved_path" ]; then
                print_info "No Package.resolved found - dependencies will be resolved"
            fi
            ;;
        "xcworkspace")
            # For workspaces, Package.resolved is required
            if [ ! -f "$package_resolved_path" ]; then
                print_error "Package.resolved not found at $package_resolved_path"
                exit 1
            fi
            ;;
        "swift-package")
            # For Swift packages, check if Package.swift exists and has dependencies
            if [ -f "$project_path/Package.swift" ]; then
                # Check if Package.swift contains any dependencies
                if grep -q "dependencies:" "$project_path/Package.swift"; then
                    has_dependencies=true
                    if [ ! -f "$package_resolved_path" ]; then
                        print_info "No Package.resolved found - dependencies will be resolved for the first time"
                    fi
                else
                    print_info "Package has no dependencies to update"
                    exit 0
                fi
            else
                print_error "Package.swift not found at: $project_path/Package.swift"
                exit 1
            fi
            ;;
    esac

    # Show current versions and save state (only if Package.resolved exists)
    if [ -f "$package_resolved_path" ] && show_current_versions "$package_resolved_path" "$project_type"; then
        temp_old=$(save_current_state "$package_resolved_path" "$project_type")
    fi

    # Update packages based on project type
    case "$project_type" in
        "xcode")
            if ! update_xcode_project "$project_path" "$package_resolved_path"; then
                exit 1
            fi
            ;;
        "xcworkspace")
            if ! update_xcworkspace "$project_path" "$package_resolved_path"; then
                exit 1
            fi
            ;;
        "swift-package")
            if ! update_swift_package "$project_path" "$package_resolved_path"; then
                exit 1
            fi
            ;;
    esac

    # Show changes
    if [ -n "$temp_old" ] && [ -f "$package_resolved_path" ]; then
        show_package_changes "$package_resolved_path" "$project_type" "$temp_old"
    elif [ -f "$package_resolved_path" ]; then
        # If we don't have old state but now have Package.resolved, show new packages
        print_info "Newly resolved package versions:"
        case "$project_type" in
            "xcode"|"xcworkspace"|"swift-package")
                if command -v jq &> /dev/null; then
                    jq -r '.pins[] | "  \(.identity): \(.state.revision[:8]) (\(.state.branch // .state.version // "commit"))"' "$package_resolved_path"
                fi
                ;;
        esac
    else
        # No Package.resolved file means local-only dependencies
        case "$project_type" in
            "swift-package")
                print_info "This package may only have local path dependencies"
                ;;
        esac
    fi

    print_success "Package update completed!"
}

# Run main function
main "$@"
