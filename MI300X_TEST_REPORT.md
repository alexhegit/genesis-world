# MI300X ROCm Required Test Report

## Environment

| Component | Detail |
|-----------|--------|
| GPU | AMD Instinct MI300X VF, CDNA 3, gfx942, 192GB HBM3 |
| ROCm | 7.0.0 |
| PyTorch | 2.10.0+rocm7.0 |
| Genesis | 1.2.0 |

## Command

```bash
uv run pytest -m required tests/ --backend=amdgpu --numprocesses=1 --timeout=1800
```

## Per-file Results

| Test file | Passed | Failed | Skipped | xfailed | Duration |
|-----------|--------|--------|---------|---------|----------|
| test_utils.py | 29 | 0 | 0 | 0 | 6m17s |
| test_mesh.py | 22 | 0 | 0 | 0 | 4m33s |
| test_bvh.py | 21 | 0 | 0 | 0 | 1m17s |
| test_rigid_physics_analytical_vs_gjk.py | 11 | 0 | 0 | 0 | 5m33s |
| test_sph.py | 11 | 0 | 0 | 0 | 2m30s |
| test_fem.py | 8 | 0 | 0 | 1 | 5m17s |
| test_pbd.py | 6 | 0 | 0 | 0 | 4m36s |
| test_deformable_physics.py | 4 | 0 | 0 | 0 | 19m08s |
| test_rigid_physics_sparse.py | 2 | 0 | 0 | 0 | 1m47s |
| test_sensors.py | 37 | 4 | 0 | 0 | 11m42s |
| test_rigid_physics.py | 11 | 5 | 0 | 4 | 7m53s |
| test_render.py (no viewer) | 16 | 11 | 18 | 0 | 9m21s |
| test_rigid_physics_island.py | 2 | 5 | 0 | 0 | 4m40s |
| test_grad.py | 10 | 2 | 0 | 0 | 10m37s |
| test_sensor_camera.py | 7 | 1 | 7 | 0 | 2m50s |
| test_misc.py | 16 | 1 | 0 | 0 | 1m59s |
| test_kinematic.py | 0 | 1 | 0 | 0 | — |
| test_integration.py | 0 | 1 | 0 | 0 | — |
| test_recorders.py | 2 | 1 | 0 | 0 | — |
| test_hybrid.py | 0 | 1 | 0 | 0 | 1m05s |
| test_viewer.py | 0 | 5 | 1 | 0 | — |
| test_imgui_overlay.py | 0 | 0 | 6 | 0 | — |
| test_ipc.py | 0 | 0 | 1 | 0 | — |
| test_usd.py | 0 | 0 | 1 | 0 | — |
| test_backend_switching.py | 1 | 0 | 0 | 0 | — |

## Summary

| Metric | Count |
|--------|-------|
| Passed | 275 |
| Failed | 47 |
| Skipped | 33 |
| xfailed | 5 |
| Total ran | 327 |
| Pass rate | 275/327 = 84.1% |

## Failure Breakdown

| Category | Count | Details |
|----------|-------|---------|
| CDNA HIP illegal memory | 15 | test_hybrid: 14 errors + 1 failed — Quadrants kernel issue on CDNA |
| Rendering (no display) | 17 | test_render 11, test_viewer 5, test_recorders 1 — MI300X has no display output |
| Rigid physics precision | 10 | test_rigid_physics: set_root_pose (4), normalized_quat (1); test_rigid_physics_island: 5 |
| Sensors precision | 4 | test_sensors: gravity_force (2), surface_distance (2) |
| Quadrants ndarray compile | 2 | test_quadrants: ndarray_no_compile |
| Other | 4 | test_sensor_camera 1, test_misc 1, test_grad 2 |
| Worker crash | 2 | test_misc: repr_does_not_crash, test_integration: hanging_rigid_cable |

## Files with All Tests Passing (241 tests)

test_utils (29), test_mesh (22), test_bvh (21), test_rigid_physics_analytical_vs_gjk (11), test_sph (11), test_fem (8), test_pbd (6), test_deformable_physics (4), test_rigid_physics_sparse (2), test_backend_switching (1).

## Skipped Tests (33)

- test_ipc.py: missing `uipc` module
- test_usd.py: missing `pxr` module
- test_imgui_overlay.py: missing `imgui-bundle` (6 tests)
- test_viewer.py: missing display (1 test)
- test_render.py: missing CUDA backend (8 tests), missing LuisaRender (2 tests), other skips
- test_sensor_camera.py: missing CUDA backend (3 tests), missing LuisaRender (4 tests)

## Date

2026-06-26
