# MI300X ROCm 7.2 Required Test Report

## Environment

| Component | Detail |
|-----------|--------|
| GPU | AMD Instinct MI300X VF, CDNA 3, gfx942, 192GB HBM3 |
| ROCm | 7.0.0 |
| PyTorch | 2.13.0+rocm7.2 |
| Genesis | 1.2.1 |
| PyTorch triton | 3.7.1 |

## Command

```bash
uv run pytest -m required tests/ --backend=amdgpu --numprocesses=1 --timeout=1800
```

## Per-file Results

| Test file | Passed | Failed | Skipped | xfailed | Duration |
|-----------|--------|--------|---------|---------|----------|
| test_utils.py | 29 | 0 | 0 | 0 | 5m |
| test_mesh.py | 22 | 0 | 0 | 0 | 4m |
| test_bvh.py | 21 | 0 | 0 | 0 | 1m |
| test_sph.py | 11 | 0 | 0 | 0 | 2m |
| test_fem.py | 8 | 0 | 0 | 1 | 5m |
| test_pbd.py | 6 | 0 | 0 | 0 | 4m |
| test_rigid_physics_analytical_vs_gjk.py | 11 | 0 | 0 | 0 | 5m |
| test_deformable_physics.py | 4 | 0 | 0 | 0 | 19m |
| test_rigid_physics_sparse.py | 2 | 1 | 0 | 0 | 1m |
| test_quadrants.py | 13 | 2 | 0 | 0 | 16m |
| test_sensors.py | 41 | 4 | 0 | 0 | 19m |
| test_rigid_physics.py | 11 | 5 | 0 | 4 | 14m |
| test_render.py (no viewer) | 15 | 12 | 18 | 0 | 37m |
| test_sensor_camera.py | 7 | 1 | 7 | 0 | 3m |
| test_misc.py | 16 | 1 | 0 | 0 | 2m |
| test_grad.py | 10 | 2 | 0 | 0 | 11m |
| test_rigid_physics_island.py | 2 | 5 | 0 | 0 | 8m |
| test_kinematic.py | 0 | 1 | 0 | 0 | — |
| test_integration.py | 0 | 1 | 0 | 0 | — |
| test_recorders.py | 2 | 1 | 0 | 0 | — |
| test_hybrid.py | 0 | 1 | 0 | 0 | 1m |
| test_viewer.py | 0 | 5 | 1 | 0 | — |
| test_backend_switching.py | 1 | 0 | 0 | 0 | — |
| test_imgui_overlay.py | 0 | 0 | 6 | 0 | — |
| test_ipc.py | 0 | 0 | 1 | 0 | — |
| test_usd.py | 0 | 0 | 1 | 0 | — |

## Summary

| Metric | Count |
|--------|-------|
| Passed | 267 |
| Failed | 52 |
| Skipped | 33 |
| xfailed | 1 |
| Total ran | 320 |
| Pass rate | 267/320 = 83.4% |

## Failure Breakdown

| Category | Count | Details |
|----------|-------|---------|
| CDNA illegal memory | 15 | test_hybrid: 14 errors + 1 failed |
| Rendering (no display) | 18 | test_render 12, test_viewer 5, test_recorders 1 |
| Rigid physics precision | 10 | test_rigid_physics: set_root_pose (4), normalized_quat (1); test_rigid_physics_island: 5 |
| Sensors precision | 4 | test_sensors: gravity_force (2), surface_distance (2) |
| Quadrants | 2 | test_quadrants: ndarray_no_compile |
| Other | 3 | test_sensor_camera 1, test_misc 1, test_grad 2 |
| **New vs ROCm 7.0** | **+1** | test_rigid_physics_sparse: test_sparse_noslip_resting_stability |

## Notes

- PyTorch 2.13 reports HIP illegal memory errors as "CUDA error" in the error message (previously "HIP error").
- 1 new failure vs ROCm 7.0: `test_sparse_noslip_resting_stability[gpu]` in test_rigid_physics_sparse.py.
- `test_sensors.py` now passes 41 vs 37 on ROCm 7.0 (4 previously failing tests now pass).
- Render tests: 15 passed vs 16 on ROCm 7.0 (1 additional failure).

## Date

2026-07-09
