# Ranger devicons plugin - adds file type icons
# Requires a Nerd Font to display icons properly

import os
import ranger.api
from ranger.core.linemode import LinemodeBase

# File extension to icon mapping
ICONS = {
    # Folders
    'folder': '',
    'folder_open': '',
    'folder_git': '',
    'folder_node': '',
    'folder_src': '',

    # Git
    '.git': '',
    '.gitignore': '',
    '.gitmodules': '',

    # Programming
    '.py': '',
    '.pyc': '',
    '.js': '',
    '.jsx': '',
    '.ts': '',
    '.tsx': '',
    '.vue': '',
    '.go': '',
    '.rs': '',
    '.rb': '',
    '.php': '',
    '.java': '',
    '.c': '',
    '.cpp': '',
    '.h': '',
    '.hpp': '',
    '.cs': '',
    '.lua': '',
    '.sh': '',
    '.bash': '',
    '.zsh': '',
    '.fish': '',
    '.vim': '',
    '.swift': '',
    '.kt': '',
    '.scala': '',
    '.r': '',
    '.pl': '',
    '.ex': '',
    '.exs': '',
    '.erl': '',
    '.hs': '',
    '.clj': '',
    '.lisp': '',
    '.el': '',

    # Web
    '.html': '',
    '.htm': '',
    '.css': '',
    '.scss': '',
    '.sass': '',
    '.less': '',
    '.svg': '',
    '.wasm': '',

    # Data/Config
    '.json': '',
    '.yaml': '',
    '.yml': '',
    '.toml': '',
    '.xml': '',
    '.csv': '',
    '.sql': '',
    '.db': '',
    '.sqlite': '',
    '.ini': '',
    '.conf': '',
    '.cfg': '',
    '.env': '',

    # Documents
    '.md': '',
    '.markdown': '',
    '.txt': '',
    '.pdf': '',
    '.doc': '',
    '.docx': '',
    '.xls': '',
    '.xlsx': '',
    '.ppt': '',
    '.pptx': '',
    '.odt': '',
    '.ods': '',
    '.odp': '',
    '.rtf': '',
    '.tex': '',
    '.org': '',
    '.rst': '',

    # Images
    '.png': '',
    '.jpg': '',
    '.jpeg': '',
    '.gif': '',
    '.bmp': '',
    '.ico': '',
    '.webp': '',
    '.tiff': '',
    '.psd': '',
    '.ai': '',
    '.xcf': '',

    # Audio
    '.mp3': '',
    '.wav': '',
    '.flac': '',
    '.aac': '',
    '.ogg': '',
    '.m4a': '',
    '.wma': '',

    # Video
    '.mp4': '',
    '.mkv': '',
    '.avi': '',
    '.mov': '',
    '.wmv': '',
    '.flv': '',
    '.webm': '',
    '.m4v': '',

    # Archives
    '.zip': '',
    '.tar': '',
    '.gz': '',
    '.bz2': '',
    '.xz': '',
    '.7z': '',
    '.rar': '',
    '.deb': '',
    '.rpm': '',

    # Executables
    '.exe': '',
    '.msi': '',
    '.bin': '',
    '.app': '',
    '.dmg': '',
    '.appimage': '',

    # Misc
    '.lock': '',
    '.log': '',
    '.bak': '',
    '.tmp': '',
    '.cache': '',
    'Dockerfile': '',
    'docker-compose.yml': '',
    'docker-compose.yaml': '',
    'Makefile': '',
    'CMakeLists.txt': '',
    'package.json': '',
    'package-lock.json': '',
    'yarn.lock': '',
    'pnpm-lock.yaml': '',
    'Cargo.toml': '',
    'Cargo.lock': '',
    'go.mod': '',
    'go.sum': '',
    'requirements.txt': '',
    'Pipfile': '',
    'Pipfile.lock': '',
    'pyproject.toml': '',
    'setup.py': '',
    '.editorconfig': '',
    '.prettierrc': '',
    '.eslintrc': '',
    'LICENSE': '',
    'README': '',
    'README.md': '',
    'CHANGELOG': '',
    'CHANGELOG.md': '',
}

# Special folder names
FOLDER_ICONS = {
    '.git': '',
    'node_modules': '',
    'src': '',
    'lib': '',
    'bin': '',
    'build': '',
    'dist': '',
    'out': '',
    'target': '',
    'vendor': '',
    'public': '',
    'static': '',
    'assets': '',
    'images': '',
    'img': '',
    'docs': '',
    'doc': '',
    'test': '',
    'tests': '',
    '__tests__': '',
    'spec': '',
    '.config': '',
    'config': '',
    '.cache': '',
    'cache': '',
    '.local': '',
    'tmp': '',
    'temp': '',
    'logs': '',
    'log': '',
    'backup': '',
    'backups': '',
    '.vscode': '',
    '.idea': '',
    'scripts': '',
    'hooks': '',
    'plugins': '',
    'templates': '',
    'components': '',
    'pages': '',
    'views': '',
    'models': '',
    'controllers': '',
    'utils': '',
    'helpers': '',
    'services': '',
    'api': '',
    'styles': '',
    'css': '',
}

def get_icon(fobj):
    """Get icon for a file object."""
    if fobj.is_directory:
        # Check for special folder names
        name = fobj.relative_path.lower()
        if name in FOLDER_ICONS:
            return FOLDER_ICONS[name]
        # Check if it's a git repo (only for top-level dirs under ~ or /)
        parent = os.path.dirname(fobj.path)
        home = os.path.expanduser('~')
        if parent in (home, '/'):
            if os.path.isdir(os.path.join(fobj.path, '.git')):
                return ''
        return ''

    # Check exact filename first
    name = fobj.relative_path
    if name in ICONS:
        return ICONS[name]

    # Check extension
    ext = fobj.extension.lower() if fobj.extension else ''
    if ext:
        ext_key = '.' + ext
        if ext_key in ICONS:
            return ICONS[ext_key]

    # Default file icon
    return ''

@ranger.api.register_linemode
class DevIconsLinemode(LinemodeBase):
    name = "devicons"
    uses_metadata = False

    def filetitle(self, fobj, metadata):
        icon = get_icon(fobj)
        return f"{icon} {fobj.relative_path}"

@ranger.api.register_linemode
class DevIconsWithInfoLinemode(LinemodeBase):
    name = "devicons_info"
    uses_metadata = False

    def filetitle(self, fobj, metadata):
        icon = get_icon(fobj)
        return f"{icon} {fobj.relative_path}"

    def infostring(self, fobj, metadata):
        return ""
