#!/bin/bash
# Genesis World AMD ROCm 完整验证脚本
# 使用方法: bash run_rocm_tests.sh
# 
# 前提条件:
#   1. 已安装 uv (https://docs.astral.sh/uv/)
#   2. 已安装 ROCm 7.2+
#   3. 在 genesis-world 项目目录下运行

set -e

echo "=========================================="
echo "  Genesis World AMD ROCm 验证脚本"
echo "=========================================="
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 测试结果记录
TOTAL_PASS=0
TOTAL_FAIL=0
TOTAL_SKIP=0
FAILED_TESTS=""

# 检查环境
echo -e "${YELLOW}[1/5] 检查环境...${NC}"
if ! command -v uv &> /dev/null; then
    echo -e "${RED}错误: uv 未安装${NC}"
    echo "请先安装 uv: curl -LsSf https://astral.sh/uv/install.sh | sh"
    exit 1
fi

if ! command -v rocm-smi &> /dev/null; then
    echo -e "${RED}错误: rocm-smi 未安装${NC}"
    echo "请先安装 ROCm: https://rocm.docs.amd.com/"
    exit 1
fi

echo -e "${GREEN}环境检查通过${NC}"
echo ""

# 运行测试的函数
run_test() {
    local test_name="$1"
    local test_cmd="$2"
    local timeout="${3:-600}"
    
    echo -e "${YELLOW}[运行] ${test_name}${NC}"
    echo "  命令: ${test_cmd}"
    
    # 运行测试并捕获结果
    if timeout ${timeout} bash -c "${test_cmd}" 2>&1 | tee /tmp/test_output.txt; then
        # 检查测试结果
        if grep -q "passed" /tmp/test_output.txt; then
            passed=$(grep -oP '\d+(?= passed)' /tmp/test_output.txt | head -1)
            failed=$(grep -oP '\d+(?= failed)' /tmp/test_output.txt | head -1 || echo "0")
            skipped=$(grep -oP '\d+(?= skipped)' /tmp/test_output.txt | head -1 || echo "0")
            
            TOTAL_PASS=$((TOTAL_PASS + ${passed:-0}))
            TOTAL_FAIL=$((TOTAL_FAIL + ${failed:-0}))
            TOTAL_SKIP=$((TOTAL_SKIP + ${skipped:-0}))
            
            if [ "${failed:-0}" -eq 0 ]; then
                echo -e "  ${GREEN}✓ 通过: ${passed} 个测试${NC}"
            else
                echo -e "  ${RED}✗ 失败: ${failed} 个测试${NC}"
                FAILED_TESTS="${FAILED_TESTS}\n  - ${test_name}: ${failed} failed"
            fi
            if [ "${skipped:-0}" -gt 0 ]; then
                echo -e "  ${YELLOW}  跳过: ${skipped} 个测试${NC}"
            fi
        else
            echo -e "  ${RED}✗ 测试结果解析失败${NC}"
            TOTAL_FAIL=$((TOTAL_FAIL + 1))
            FAILED_TESTS="${FAILED_TESTS}\n  - ${test_name}: 结果解析失败"
        fi
    else
        echo -e "  ${RED}✗ 测试超时或异常退出${NC}"
        TOTAL_FAIL=$((TOTAL_FAIL + 1))
        FAILED_TESTS="${FAILED_TESTS}\n  - ${test_name}: 超时/异常"
    fi
    echo ""
}

# 开始测试
echo "=========================================="
echo "  阶段 1: 基础工具测试"
echo "=========================================="
echo ""

run_test "test_misc.py" \
    "uv run pytest tests/test_misc.py -m required --backend=amdgpu --timeout=300 --numprocesses=1 -q"

run_test "test_utils.py" \
    "uv run pytest tests/test_utils.py -m required --backend=amdgpu --timeout=300 --numprocesses=1 -q"

run_test "test_mesh.py" \
    "uv run pytest tests/test_mesh.py -m required --backend=amdgpu --timeout=300 --numprocesses=1 -q"

echo "=========================================="
echo "  阶段 2: 核心物理求解器"
echo "=========================================="
echo ""

run_test "test_rigid_physics.py" \
    "uv run pytest tests/test_rigid_physics.py -m required --backend=amdgpu --timeout=600 --numprocesses=2 -q"

run_test "test_kinematic.py" \
    "uv run pytest tests/test_kinematic.py -m required --backend=amdgpu --timeout=300 --numprocesses=1 -q"

run_test "test_deformable_physics.py" \
    "uv run pytest tests/test_deformable_physics.py -m required --backend=amdgpu --timeout=300 --numprocesses=1 -q"

run_test "test_fem.py" \
    "uv run pytest tests/test_fem.py -m required --backend=amdgpu --timeout=300 --numprocesses=1 -q"

run_test "test_pbd.py" \
    "uv run pytest tests/test_pbd.py -m required --backend=amdgpu --timeout=300 --numprocesses=1 -q"

echo "=========================================="
echo "  阶段 3: 其他求解器"
echo "=========================================="
echo ""

run_test "test_sph.py" \
    "uv run pytest tests/test_sph.py -m required --backend=amdgpu --timeout=300 --numprocesses=1 -q"

run_test "test_hybrid.py" \
    "uv run pytest tests/test_hybrid.py -m required --backend=amdgpu --timeout=300 --numprocesses=1 -q"

run_test "test_ipc.py" \
    "uv run pytest tests/test_ipc.py -m required --backend=amdgpu --timeout=600 --numprocesses=1 -q"

run_test "test_grad.py" \
    "uv run pytest tests/test_grad.py -m required --backend=amdgpu --timeout=300 --numprocesses=1 -q"

echo "=========================================="
echo "  阶段 4: 其他测试"
echo "=========================================="
echo ""

run_test "test_bvh.py" \
    "uv run pytest tests/test_bvh.py -m required --backend=amdgpu --timeout=300 --numprocesses=1 -q"

run_test "test_quadrants.py" \
    "uv run pytest tests/test_quadrants.py -m required --backend=amdgpu --timeout=300 --numprocesses=1 -q"

run_test "test_integration.py" \
    "uv run pytest tests/test_integration.py -m required --backend=amdgpu --timeout=300 --numprocesses=1 -q"

run_test "test_usd.py" \
    "uv run pytest tests/test_usd.py -m required --backend=amdgpu --timeout=300 --numprocesses=1 -q"

run_test "test_recorders.py" \
    "uv run pytest tests/test_recorders.py -m required --backend=amdgpu --timeout=300 --numprocesses=1 -q"

run_test "test_sensors.py" \
    "uv run pytest tests/test_sensors.py -m required --backend=amdgpu --timeout=300 --numprocesses=1 -q"

run_test "test_sensor_camera.py" \
    "uv run pytest tests/test_sensor_camera.py -m required --backend=amdgpu --timeout=300 --numprocesses=1 -q"

echo "=========================================="
echo "  阶段 5: 示例验证"
echo "=========================================="
echo ""

echo -e "${YELLOW}[运行] hello_genesis.py${NC}"
if timeout 120 uv run examples/tutorials/hello_genesis.py 2>&1 | grep -q "completed\|FPS"; then
    echo -e "  ${GREEN}✓ hello_genesis.py 通过${NC}"
    TOTAL_PASS=$((TOTAL_PASS + 1))
else
    echo -e "  ${RED}✗ hello_genesis.py 失败${NC}"
    TOTAL_FAIL=$((TOTAL_FAIL + 1))
    FAILED_TESTS="${FAILED_TESTS}\n  - hello_genesis.py"
fi
echo ""

echo -e "${YELLOW}[运行] single_franka.py${NC}"
if timeout 120 uv run examples/rigid/single_franka.py 2>&1 | grep -q "completed\|FPS"; then
    echo -e "  ${GREEN}✓ single_franka.py 通过${NC}"
    TOTAL_PASS=$((TOTAL_PASS + 1))
else
    echo -e "  ${RED}✗ single_franka.py 失败${NC}"
    TOTAL_FAIL=$((TOTAL_FAIL + 1))
    FAILED_TESTS="${FAILED_TESTS}\n  - single_franka.py"
fi
echo ""

# 输出最终结果
echo "=========================================="
echo "  测试结果汇总"
echo "=========================================="
echo ""
echo -e "  ${GREEN}通过: ${TOTAL_PASS}${NC}"
echo -e "  ${RED}失败: ${TOTAL_FAIL}${NC}"
echo -e "  ${YELLOW}跳过: ${TOTAL_SKIP}${NC}"
echo ""

if [ ${TOTAL_FAIL} -eq 0 ]; then
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  所有测试通过!${NC}"
    echo -e "${GREEN}========================================${NC}"
else
    echo -e "${RED}========================================${NC}"
    echo -e "${RED}  有 ${TOTAL_FAIL} 个测试失败${NC}"
    echo -e "${RED}========================================${NC}"
    echo -e "\n失败的测试:${FAILED_TESTS}"
fi

echo ""
echo "详细日志: /tmp/test_output.txt"
echo ""
