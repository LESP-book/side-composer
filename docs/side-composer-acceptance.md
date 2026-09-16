# Side Composer 测试与验收证据

日期：2026-09-16

## 环境与上游记录

- Discourse：`f7c85e6089cac8318e76bb0c58e8e3e898152a0f`（本地
  `2026.9.0-latest`）。
- Theme Component 骨架：`discourse/composer-peek`
  `1f8283ba07c1aedb5cbf38e8c1dd59ea406970f8`。
- Full Width 验证组件：`discourse-full-width-component`
  `c371e57a02db6956d5a253402ce1b824bb24a8a1`。
- `discourse` 工作树在测试前后均为 clean；Side Composer 未添加
  `.discourse-compatibility` 历史 pins。
- 正常测试默认使用 `spec/fixtures/full-width-component`：它只实现 Full
  Width 的公开 `full-width-enabled` marker 与 main-outlet grid 契约。缺依赖
  context 不上传该 fixture，也不手工添加 body class。另用上面记录的官方
  Full Width 组件跑了同一套系统测试。

## 阶段 A 静态检查

命令：

```text
pnpm install --frozen-lockfile
pnpm lint
```

结果：通过。`lint:css`、`lint:js`、`lint:hbs`、`lint:prettier`、`lint:types`
均退出码 0。

命令：

```text
BUNDLE_GEMFILE=/src/Gemfile bundle exec rubocop \
  spec/system/composer_peek_spec.rb \
  spec/system/core_features_spec.rb \
  spec/system/page_objects/components/side_composer.rb
```

结果：`3 files inspected, no offenses detected`。

## 第 6.1 节自动化测试

在 Discourse Docker 开发容器中执行：

```text
bin/rspec /tmp/side-composer/spec/system/composer_peek_spec.rb --format progress
```

结果：`10 examples, 0 failures`（最小等价 Full Width fixture，seed `23572`）。
覆盖开关持久化、preview 协调、窄屏、fullscreen、sidebar 两种 grid、普通与无
sidebar 的 Full Width viewport、缺依赖 staff/普通用户、普通 composer resize。

使用官方 Full Width 组件执行：

```text
SIDE_COMPOSER_FULL_WIDTH_COMPONENT_PATH=/tmp/full-width-upstream \
  bin/rspec /tmp/side-composer/spec/system/composer_peek_spec.rb --format progress
```

结果：`10 examples, 0 failures`（官方组件，seed `27971`）。

Core features smoke：

```text
bin/rspec /tmp/side-composer/spec/system/core_features_spec.rb --format progress
```

结果：`19 examples, 0 failures`（seed `6010`）。

## 第 7 节验收映射

| 验收项 | 证据 |
| --- | --- |
| `>= xl` 显示本地化按钮、preview 关闭、右侧停靠 | composer peek 系统测试；按钮 title 使用 `js.composer.peek_mode_toggle` |
| 正文与 composer 不重叠且无水平溢出 | sidebar open/closed bounding rect 与 overflow 断言 |
| 刷新、切换 topic 保持选择 | persistence 测试 |
| 原生 preview 打开退出侧边、关闭后恢复 | preview 协调测试 |
| fullscreen / `< xl` 不启用侧边布局 | fullscreen、窄屏测试 |
| Full Width 缺失时 staff 告警、普通用户无告警且无按钮 | 两个缺依赖测试；缺依赖 context 未加载 fixture |
| 普通 composer 高度拖动不受影响 | resize 回归测试 |
| core 行为未被破坏 | shared `having working core features`：19/19 |

## 第 6.2 节人工回归状态

以下是本次本地验收边界，未把自动化结果冒充实体设备上的人工结果：

- Foundation + Full Width、sidebar 开/关：已用最小等价 fixture 和官方
  Full Width 各跑自动化；视觉人工回归未执行。
- 亮/暗色、Markdown/rich-text、新建/回复/编辑/私信：本次未做人工矩阵。
- 1280 边界、1366/1440 宽度：自动化覆盖 600、1280、1380、1440；未逐项人工截图。
- iPad Pro 13 英寸键盘、chat drawer、composer redesign 开/关：未执行。
- RTL：未执行；当前实现按契约仍固定右侧，README 已记录该限制。
- stable/latest 双版本线上验证、tag/release：未执行；本次只验证本地
  Discourse `f7c85e6`。

上述未执行项是发布前人工回归和版本矩阵的剩余工作，不影响本次自动化结果。
