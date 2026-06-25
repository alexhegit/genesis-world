#!/bin/bash
# Genesis World AMD ROCm - 未完成测试重跑脚本
# 测试之前因 GPU 资源耗尽而未完成的 4 个文件
# 使用方法: bash run_rocm_incomplete_tests.sh
#
# 注意: 这些测试之前因并行运行导致 GPU 资源耗尽
#       现在使用单进程模式逐个运行

set -e

echo "=========================================="
echo "  Genesis World AMD ROCm 未完成测试重跑"
echo "=========================================="
echo ""

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

TOTAL_PASS=0
TOTAL_FAIL=0
FAILED_TESTS=""

run_test() {
    local test_name="$1"
    local test_cmd="$2"
    local timeout="${3:-600}"
    
    echo -e "${YELLOW}[运行] ${test_name}${NC}"
    echo "  命令: ${test_cmd}"
    echo "  超时: ${timeout}s"
    echo ""
    
    if timeout ${timeout} bash -c "${test_cmd}" 2>&1 | tee /tmp/test_output.txt; then
        if grep -q "passed" /tmp/test_output.txt; then
            passed=$(grep -oP '\d+(?= passed)' /tmp/test_output.txt | head -1)
            failed=$(grep -oP '\d+(?= failed)' /tmp/test_output.txt | head -1 || echo "0")
            errors=$(grep -oP '\d+(?= error)' /tmp/test_output.txt | head -1 || echo "0")
            
            TOTAL_PASS=$((TOTAL_PASS + ${passed:-0}))
            TOTAL_FAIL=$((TOTAL_FAIL + ${failed:-0} + ${errors:-0}))
            
            if [ "${failed:-0}" -eq 0 ] && [ "${errors:-0}" -eq 0 ]; then
                echo -e "  ${GREEN}✓ 通过: ${passed} 个测试${NC}"
            else
                echo -e "  ${RED}✗ 失败: ${failed} failed, ${errors} errors${NC}"
                FAILED_TESTS="${FAILED_TESTS}\n  - ${test_name}"
            fi
        else
            echo -e "  ${RED}✗ 测试结果解析失败${NC}"
            TOTAL_FAIL=$((TOTAL_FAIL + 1))
            FAILED_TESTS="${FAILED_TESTS}\n  - ${test_name}: 解析失败"
        fi
    else
        echo -e "  ${RED}✗ 测试超时或异常退出${NC}"
        TOTAL_FAIL=$((TOTAL_FAIL + 1))
        FAILED_TESTS="${FAILED_TESTS}\n  - ${test_name}: 超时/异常"
    fi
    echo ""
    echo "------------------------------------------"
    echo ""
}

# 建议: 运行前先重启 GPU 或等待几分钟
echo -e "${YELLOW}提示: 建议运行前执行以下命令重置 GPU:${NC}"
echo "  sudo systemctl restart rocm-smi"
echo "  或等待 2-3 分钟让 GPU 冷却"
echo ""

echo "=========================================="
echo "  1. test_ipc.py (IPC 求解器)"
echo "=========================================="
echo ""

run_test "test_ipc.py - required" \
    "uv run pytest tests/test_ipc.py -m required --backend=amdgpu --timeout=600 --numprocesses=1 -v" \
    900

echo "=========================================="
echo "  2. test_grad.py (梯度计算)"
echo "=========================================="
echo ""

run_test "test_grad.py - required" \
    "uv run pytest tests/test_grad.py -m required --backend=amdgpu --timeout=300 --numprocesses=1 -v" \
    600

echo "=========================================="
echo "  3. test_sph.py (SPH 求解器)"
echo "=========================================="
echo ""

run_test "test_sph.py - required" \
    "uv run pytest tests/test_sph.py -m required --backend=amdgpu --timeout=300 --numprocesses=1 -v" \
    600

echo "=========================================="
echo "  4. test_deformable_physics.py (可变形体)"
echo "=========================================="
echo ""

run_test "test_deformable_physics.py - required" \
    "uv run pytest tests/test_deformable_physics.py -m required --backend=amdgpu --timeout=300 --numprocesses=1 -v" \
    600

echo "=========================================="
echo "  测试结果汇总"
echo "=========================================="
echo ""
echo -e "  ${GREEN}通过: ${TOTAL_PASS}${NC}"
echo -e "  ${RED}失败: ${TOTAL_FAIL}${NC}"
echo ""

if [ ${TOTAL_FAIL} -eq 0 ]; then
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  所有未完成测试重跑通过!${NC}"
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
