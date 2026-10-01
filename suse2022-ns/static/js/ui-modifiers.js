const { origin, pathname } = window.location;
const releaseNotesMatch = pathname.match(/\/releasenotes\//);
const htmlMatch = pathname.match(/\/(single-html|html)\//);

let result;

if (releaseNotesMatch) {
  const langMatch = pathname.match(/^\/([a-z]{2}-[a-z]{2})\//);
  const langPrefix = langMatch ? "/" + langMatch[1] : "";
  result = origin + langPrefix + "/?tab=release-notes";
} else if (htmlMatch) {
  const basePath = pathname.slice(0, htmlMatch.index);
  result = origin + (basePath || "/") + "/";
} else {
  result = origin + pathname;
}

document.addEventListener("DOMContentLoaded", () => {
  const crumb = document.querySelector(".index-page-crumb");
  if (crumb) {
    crumb.setAttribute("href", result);
  }
});
