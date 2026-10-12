if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface Index_Params {
    mode?: number;
    left?: number;
    timerId?: number;
}
import router from "@ohos:router";
class Index extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__mode = new ObservedPropertySimplePU(0, this, "mode");
        this.__left = new ObservedPropertySimplePU(3, this, "left");
        this.timerId = -1;
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: Index_Params) {
        if (params.mode !== undefined) {
            this.mode = params.mode;
        }
        if (params.left !== undefined) {
            this.left = params.left;
        }
        if (params.timerId !== undefined) {
            this.timerId = params.timerId;
        }
    }
    updateStateVars(params: Index_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__mode.purgeDependencyOnElmtId(rmElmtId);
        this.__left.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__mode.aboutToBeDeleted();
        this.__left.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    private __mode: ObservedPropertySimplePU<number>;
    get mode() {
        return this.__mode.get();
    }
    set mode(newValue: number) {
        this.__mode.set(newValue);
    }
    private __left: ObservedPropertySimplePU<number>;
    get left() {
        return this.__left.get();
    }
    set left(newValue: number) {
        this.__left.set(newValue);
    }
    private timerId: number;
    aboutToAppear(): void {
        this.restart();
    }
    aboutToDisappear(): void {
        this.stopTimer();
    }
    private restart(): void {
        this.stopTimer();
        if (this.mode === 0) {
            this.left = 3;
            this.timerId = setInterval(() => {
                if (this.left > 0) {
                    this.left = this.left - 1;
                }
                if (this.left <= 0) {
                    this.stopTimer();
                }
            }, 1000);
        }
    }
    private stopTimer(): void {
        if (this.timerId !== -1) {
            clearInterval(this.timerId);
            this.timerId = -1;
        }
    }
    private switchMode(m: number): void {
        this.mode = m;
        this.restart();
    }
    private modeText(): string {
        if (this.mode === 0) {
            return 'A 倒计时';
        }
        if (this.mode === 1) {
            return 'B 不可点击';
        }
        return 'C 静默';
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create({ space: 16 });
            Column.width('100%');
            Column.height('100%');
            Column.justifyContent(FlexAlign.Center);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create({ space: 8 });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel('A 倒计时');
            Button.fontSize(13);
            Button.onClick(() => this.switchMode(0));
        }, Button);
        Button.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel('B 不可点击');
            Button.fontSize(13);
            Button.onClick(() => this.switchMode(1));
        }, Button);
        Button.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel('C 静默');
            Button.fontSize(13);
            Button.onClick(() => this.switchMode(2));
        }, Button);
        Button.pop();
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (this.mode === 2) {
                this.ifElseBranchUpdateFunction(0, () => {
                    if (!If.canRetake('fixture_silent')) {
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            Text.create('静默页：没有广告，也没有可跳过控件');
                            Text.fontSize(18);
                            Text.id('fixture_silent');
                        }, Text);
                        Text.pop();
                    }
                });
            }
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                    if (!If.canRetake('fixture_ad_label')) {
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            Text.create('广告');
                            Text.fontSize(40);
                            Text.fontWeight(FontWeight.Bold);
                            Text.id('fixture_ad_label');
                        }, Text);
                        Text.pop();
                    }
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        If.create();
                        if (this.mode === 0) {
                            this.ifElseBranchUpdateFunction(0, () => {
                                if (!If.canRetake('fixture_skip')) {
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Button.createWithLabel(this.left > 0 ? ('跳过 ' + this.left) : '跳过');
                                        Button.enabled(this.left === 0);
                                        Button.id('fixture_skip');
                                        Button.onClick(() => {
                                            router.pushUrl({ url: 'pages/Content' });
                                        });
                                    }, Button);
                                    Button.pop();
                                }
                            });
                        }
                        else {
                            this.ifElseBranchUpdateFunction(1, () => {
                                if (!If.canRetake('fixture_skip_disabled')) {
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Button.createWithLabel('跳过（不可点击）');
                                        Button.enabled(false);
                                        Button.id('fixture_skip_disabled');
                                    }, Button);
                                    Button.pop();
                                }
                            });
                        }
                    }, If);
                    If.pop();
                });
            }
        }, If);
        If.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('当前模式：' + this.modeText());
            Text.fontSize(13);
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
registerNamedRoute(() => new Index(undefined, {}), "", { bundleName: "com.cocoper.clearstart.fixture", moduleName: "entry", pagePath: "pages/Index", pageFullPath: "entry/src/main/ets/pages/Index", integratedHsp: "false", moduleType: "followWithHap" });
