const MEMORY_PATH_PREFIX = "memories/";

/**
 * Extracts the coupleId from a Storage object path of the form
 * "memories/{coupleId}/{fileName}". Returns null for any path outside
 * that prefix.
 */
function parseCoupleIdFromMemoryPath(objectName) {
  if (typeof objectName !== "string" || !objectName.startsWith(MEMORY_PATH_PREFIX)) {
    return null;
  }
  const segments = objectName.split("/");
  return segments[1] || null;
}

/**
 * Decides whether a Storage onFinalize event for a file under memories/
 * should be counted toward the couple's usage total.
 *
 * compressImage re-encodes every image in place, producing a second
 * onFinalize event for the same path (tagged metadata.compressed === "true").
 * Counting both would double-count every photo, so the raw pre-compression
 * event is skipped; the compressed-echo event (or a video, which
 * compressImage never touches and so only ever fires once) is counted.
 */
function shouldCountFinalizeEvent({ contentType, alreadyCompressed }) {
  const isImage = typeof contentType === "string" && contentType.startsWith("image/");
  if (isImage && !alreadyCompressed) {
    return false;
  }
  return true;
}

function clampNonNegative(value) {
  return value < 0 ? 0 : value;
}

module.exports = {
  parseCoupleIdFromMemoryPath,
  shouldCountFinalizeEvent,
  clampNonNegative,
};
