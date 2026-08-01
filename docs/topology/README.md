# Network Topology

This directory holds the source and rendered output of the network topology diagram,
built with [D2](https://d2lang.com).

## Files

| File | Description |
|------|-------------|
| `topology.d2` | D2 source — version-controlled, text-diffable. |
| `topology.svg` | Rendered SVG — embedded in `README.md`, displays natively on GitHub. |

## Rendering / regenerating the SVG

The committed `topology.svg` is generated from `topology.d2`. To regenerate it after
editing the source:

### 1. Install D2

Download the standalone binary for your platform from the
[D2 releases page](https://github.com/terrastruct/d2/releases), or install via Homebrew:

```bash
brew install d2
```

On Debian/Ubuntu you can download the tarball and extract `bin/d2` into your `PATH`.

### 2. Render

From the repository root:

```bash
d2 --layout=elk docs/topology/topology.d2 docs/topology/topology.svg
```

This requires the [ELK](https://www.eclipse.org/elk/) layout engine, which is bundled
with the D2 binary (`--layout=elk`).

### 3. Validate

Open `docs/topology/topology.svg` in a browser or image viewer to verify the output,
then commit both `topology.d2` and `topology.svg`.

## Editing the diagram

- Edit `topology.d2` and re-run the render command above.
- Do **not** edit `topology.svg` directly — it is generated output.
- Keep `.d2` and `.svg` in sync; commit them together.