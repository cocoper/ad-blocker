if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface Index_Params {
    lines?: string;
}
import accessibility from "@ohos:accessibility";
import hilog from "@ohos:hilog";
import type { BusinessError } from "@ohos:base";
const DOMAIN = 0x0000;
const TAG = 'ClearStartProbeHost';
class Index extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__lines = new ObservedPropertySimplePU('', this, "lines");
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: Index_Params) {
        if (params.lines !== undefined) {
            this.lines = params.lines;
        }
    }
    updateStateVars(params: Index_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__lines.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__lines.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    private __lines: ObservedPropertySimplePU<string>;
    get lines() {
        return this.__lines.get();
    }
    set lines(newValue: string) {
        this.__lines.set(newValue);
    }
    aboutToAppear(): void {
        this.selfCheck();
    }
    private selfCheck(): void {
        let out: string = '';
        try {
            const open: boolean = accessibility.isOpenAccessibilitySync();
            out += 'isOpenAccessibilitySync=' + open + '\n';
            hilog.info(DOMAIN, TAG, 'HOST isOpenAccessibilitySync=%{public}s', String(open));
        }
        catch (e) {
            const err = e as BusinessError;
            out += 'isOpenAccessibilitySync ERR code=' + err.code + '\n';
            hilog.error(DOMAIN, TAG, 'HOST isOpenAccessibilitySync failed code=%{public}d', err.code);
        }
        try {
            const l1 = accessibility.getAccessibilityExtensionListSync('all', 'install');
            out += this.fmt('install', l1.length, l1);
        }
        catch (e) {
            const err = e as BusinessError;
            out += 'list install ERR code=' + err.code + '\n';
            hilog.error(DOMAIN, TAG, 'HOST list install failed code=%{public}d', err.code);
        }
        try {
            const l2 = accessibility.getAccessibilityExtensionListSync('all', 'enable');
            out += this.fmt('enable', l2.length, l2);
        }
        catch (e) {
            const err = e as BusinessError;
            out += 'list enable ERR code=' + err.code + '\n';
            hilog.error(DOMAIN, TAG, 'HOST list enable failed code=%{public}d', err.code);
        }
        try {
            const l3 = accessibility.getAccessibilityExtensionListSync('all', 'disable');
            out += this.fmt('disable', l3.length, l3);
        }
        catch (e) {
            const err = e as BusinessError;
            out += 'list disable ERR code=' + err.code + '\n';
            hilog.error(DOMAIN, TAG, 'HOST list disable failed code=%{public}d', err.code);
        }
        this.lines = out;
    }
    private fmt(state: string, count: number, list: object): string {
        let names: string = '';
        const arr = list as Array<object>;
        for (let i = 0; i < arr.length; i++) {
            const info = arr[i] as Record<string, string>;
            names += info.bundleName + ' ';
        }
        hilog.info(DOMAIN, TAG, 'HOST list state=%{public}s count=%{public}d bundles=%{public}s', state, count, names);
        return 'state=' + state + ' count=' + count + ' [' + names + ']\n';
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create({ space: 10 });
            Column.width('100%');
            Column.height('100%');
            Column.padding(20);
            Column.justifyContent(FlexAlign.Center);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('ClearStart G0 Probe');
            Text.fontSize(22);
            Text.fontWeight(FontWeight.Bold);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('自检结果（同时写入 hilog，tag=ClearStartProbeHost）');
            Text.fontSize(13);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.lines);
            Text.fontSize(12);
            Text.textAlign(TextAlign.Start);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('启用路径：设置 → 辅助功能 → 无障碍 → 找到 ClearStart Probe');
            Text.fontSize(13);
            Text.margin({ top: 12 });
        }, Text);
        Text.pop();
        Column.pop();
    }
    rerender() {
        this.updateDirtyElements();
    }
    public __resetStateVarsOnReuse__Internal(params: Object): void {
    }
    static getEntryName(): string {
        return "Index";
    }
}
registerNamedRoute(() => new Index(undefined, {}), "", { bundleName: "com.cocoper.clearstart", moduleName: "entry", pagePath: "pages/Index", pageFullPath: "entry/src/main/ets/pages/Index", integratedHsp: "false", moduleType: "followWithHap" });
