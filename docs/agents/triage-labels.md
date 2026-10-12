# Triage Labels

技能说的是五个固定角色（canonical triage roles）。这张表把角色映射到这个仓库的 issue tracker 里实际使用的标签字符串。

| Label in mattpocock/skills | Label in our tracker | Meaning                                  |
| -------------------------- | -------------------- | ---------------------------------------- |
| `needs-triage`             | `needs-triage`       | Maintainer needs to evaluate this issue  |
| `needs-info`               | `needs-info`         | Waiting on reporter for more information |
| `ready-for-agent`          | `ready-for-agent`    | Fully specified, ready for an AFK agent  |
| `ready-for-human`          | `ready-for-human`    | Requires human implementation            |
| `wontfix`                  | `wontfix`            | Will not be actioned                     |

本仓库保留默认五角色，未做任何重命名：右列与左列逐字相同。技能提到某个角色（例如「apply the AFK-ready
triage label」）时，直接用右列这个标签字符串。

## Wayfinder 类型标签

`/wayfinder` 另有一套类型标签，与上面的 triage 角色互不替代，同样按原名使用：

| Label           | 用途                                            |
| --------------- | ----------------------------------------------- |
| `wayfinder:map` | 地图本身（Notes / Decisions so far / Fog 挂在它身上） |
| `wayfinder:research`  | 调研票   |
| `wayfinder:prototype` | 原型票   |
| `wayfinder:grilling`  | 待定夺的讨论票 |
| `wayfinder:task`      | 普通执行票 |

除这两套之外，打标签严格遵循技能规则，不额外强制任何标签。
