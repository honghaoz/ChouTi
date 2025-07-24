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
    
    echo
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
    
    # Force update by removing Package.resolved
    if [ -f "$package_resolved_path" ]; then
        print_info "Removing $package_resolved_path..."
        rm "$package_resolved_path"
    fi

    # Clean derived data
    clean_derived_data "$project_path"
    
    # Run the update command to fetch latest versions
    print_info "Resolving package dependencies..."
    if xcodebuild -resolvePackageDependencies -project "$project_path" >/dev/null 2>&1; then
        print_success "Package update completed"
        return 0
    else
        print_error "Failed to resolve package dependencies"
        return 1
    fi
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
    
    # Force update by removing Package.resolved
    if [ -f "$package_level_resolved" ]; then
        print_info "Removing $package_level_resolved..."
        rm "$package_level_resolved"
    else
        print_info "$package_level_resolved not found"
    fi
    
    # Run the update command to fetch latest versions
    print_info "Updating package dependencies..."
    if swift package update >/dev/null 2>&1; then
        # copy package-level Package.resolved to workspace location
        local workspace_package_resolved="$project_path/xcshareddata/swiftpm/Package.resolved"
        print_info "Copying $package_level_resolved to $workspace_package_resolved..."
        cp "$package_level_resolved" "$workspace_package_resolved"
        print_success "Package update completed"
        cd "$original_dir"
        return 0
    else
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
    
    # Force update by removing Package.resolved
    if [ -f "$package_resolved_path" ]; then
        print_info "Removing $package_resolved_path..."
        rm "$package_resolved_path"
    fi
    
    # Run the update command to fetch latest versions
    print_info "Updating package dependencies..."
    if swift package update >/dev/null 2>&1; then
        # Check if Package.resolved was created (indicates remote dependencies)
        if [ -f "$package_resolved_path" ]; then
            print_success "Package update completed"
        else
            print_success "No Package.resolved found - This package may only have local path dependencies"
        fi
        cd "$original_dir"
        return 0
    else
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
    echo
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
                print_success "  $package: $old_version → $new_version"
                changes_found=true
            fi
        fi
    done < "$temp_old"
    
    # Also check for any new packages that weren't in the old file
    while IFS= read -r line; do
        local package=$(echo "$line" | cut -d: -f1)
        if ! grep -q "^$package:" "$temp_old" 2>/dev/null; then
            local new_version=$(echo "$line" | cut -d: -f2 | xargs)
            print_success "  $package: $new_version (new)"
            changes_found=true
        fi
    done < "$temp_new"
    
    if [ "$changes_found" = false ]; then
        print_info "  No changes - packages were already up to date"
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
