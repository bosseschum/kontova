import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["input", "list", "noFiles"];

  connect() {
    this.selectedFiles = [];
  }

  openFilePicker() {
    this.inputTarget.click();
  }

  filesSelected() {
    const newFiles = Array.from(this.inputTarget.files);
    if (newFiles.length === 0) return;

    this.selectedFiles = [...this.selectedFiles, ...newFiles];
    this.syncInput();
    this.renderFileList();
  }

  removeFile(event) {
    const index = parseInt(event.params.index);
    this.selectedFiles.splice(index, 1);
    this.syncInput();
    this.renderFileList();
  }

  syncInput() {
    const dt = new DataTransfer();
    this.selectedFiles.forEach((file) => dt.items.add(file));
    this.inputTarget.files = dt.files;
  }

  renderFileList() {
    if (!this.hasListTarget) return;

    if (this.selectedFiles.length === 0) {
      this.listTarget.innerHTML = "";
      if (this.hasNoFilesTarget) this.noFilesTarget.classList.remove("hidden");
      return;
    }

    if (this.hasNoFilesTarget) this.noFilesTarget.classList.add("hidden");

    this.listTarget.innerHTML = this.selectedFiles
      .map((file, index) => this.fileListItem(file, index))
      .join("");
  }

  fileListItem(file, index) {
    const isImage = file.type.startsWith("image/");
    const size = this.formatSize(file.size);
    const icon = isImage
      ? `<img src="${URL.createObjectURL(file)}" alt="${file.name}" class="w-10 h-10 object-cover rounded">`
      : `<div class="w-10 h-10 bg-purple-700 rounded flex items-center justify-center text-xs text-white font-medium">PDF</div>`;

    return `
      <li class="flex items-center gap-3 bg-gray-800 rounded-lg px-3 py-2">
        ${icon}
        <div class="flex-1 min-w-0">
          <p class="text-sm text-gray-200 truncate">${this.escapeHtml(file.name)}</p>
          <p class="text-xs text-gray-500">${size}</p>
        </div>
        <button type="button"
                data-action="file-upload#removeFile"
                data-file-upload-index-param="${index}"
                class="text-gray-500 hover:text-red-400 text-lg leading-none">&times;</button>
      </li>
    `;
  }

  formatSize(bytes) {
    if (bytes < 1024) return `${bytes} B`;
    if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`;
    return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
  }

  escapeHtml(str) {
    const div = document.createElement("div");
    div.textContent = str;
    return div.innerHTML;
  }
}
