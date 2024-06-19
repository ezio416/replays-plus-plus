// c 2024-06-17
// m 2024-06-18

MwId         loadedGhostId = MwId();
const string title         = "\\$FFF" + Icons::Refresh + "\\$G Replays++";

[Setting category="General" name="Enabled"]
bool S_Enabled = true;

[Setting category="General" name="Show/hide with game UI"]
bool S_HideWithGame = true;

[Setting category="General" name="Show/hide with Openplanet UI"]
bool S_HideWithOP = false;

void Main() {
}

void RenderMenu() {
    if (UI::MenuItem(title, "", S_Enabled))
        S_Enabled = !S_Enabled;
}

uint16 stringOffset = 0;

void Render() {
    if (
        !S_Enabled
        || (S_HideWithGame && !UI::IsGameUIVisible())
        || (S_HideWithOP && !UI::IsOverlayShown())
    )
        return;

    if (UI::Begin(title, S_Enabled, UI::WindowFlags::None)) {
        if (UI::Button("load replay"))
            startnew(LoadReplay);

        UI::SameLine();
        if (UI::Button("play against replay"))
            startnew(PlayAgainst);

        if (UI::Button("add validation"))
            startnew(AddValidation);

        UI::SameLine();
        if (UI::Button("make ghost script"))
            startnew(MakeGhostScript);

        UI::Separator();

        UI::BeginTabBar("##tabs", UI::TabBarFlags::FittingPolicyScroll);
            if (UI::BeginTabItem("CGameCtnGhost", UI::TabItemFlags::None)) {
                if (ghost is null) {
                    if (UI::Button("load ghost")) {
                        // const string ghostFileName = "kelven.Ghost.gbx";
                        const string ghostFileName = "ezio.Ghost.gbx";

                        CSystemFidFile@ fid = Fids::GetUser("Replays/" + ghostFileName);
                        if (fid is null)
                            warn("fid null");
                        else {
                           @ghost = cast<CGameCtnGhost@>(Fids::Preload(fid));
                            if (ghost is null)
                                warn("ghost null");
                            else
                                ExploreNod("ghost", ghost);
                        }
                    }
                } else {
                    if (UI::Button("nullify ghost"))
                        @ghost = null;

                    stringOffset = UI::InputInt("string offset", stringOffset, 4);
                    UI::SameLine();
                    if (UI::Button("check"))
                        print("string at offset " + stringOffset + ": " + Dev::GetOffsetString(ghost, stringOffset));

                    if (ghost !is null) {
                        UI::BeginTabBar("##tabs-CGameGtnGhost", UI::TabBarFlags::FittingPolicyScroll);
                            // if (UI::BeginTabItem("API values")) {
                            //     if (UI::BeginTable("##table-api-values", 2, UI::TableFlags::Resizable | UI::TableFlags::RowBg | UI::TableFlags::ScrollY)) {
                            //         UI::PushStyleColor(UI::Col::TableRowBgAlt, vec4(0.0f, 0.0f, 0.0f, 0.5f));

                            //         UI::TableSetupScrollFreeze(0, 1);
                            //         UI::TableSetupColumn("name");
                            //         UI::TableSetupColumn("type");
                            //         UI::TableSetupColumn("size (B)");
                            //         UI::TableHeadersRow();

                            //         UI::TableNextRow();
                            //         UI::TableNextColumn();
                            //         UI::Text("Duration");
                            //         UI::TableNextColumn();
                            //         UI::Text("uint");
                            //         UI::TableNextColumn();
                            //         UI::Text("4");

                            //         UI::TableNextRow();
                            //         UI::TableNextColumn();
                            //         UI::Text("Size");
                            //         UI::TableNextColumn();
                            //         UI::Text(tostring(ghost.Size));

                            //         UI::TableNextRow();
                            //         UI::TableNextColumn();
                            //         UI::Text("ModelIdentName");
                            //         UI::TableNextColumn();
                            //         UI::Text(IntToHex(ghost.ModelIdentName.Value) + " | " + ghost.ModelIdentName.GetName());

                            //         UI::TableNextRow();
                            //         UI::TableNextColumn();
                            //         UI::Text("ModelIdentAuthor");
                            //         UI::TableNextColumn();
                            //         UI::Text(IntToHex(ghost.ModelIdentAuthor.Value) + " | " + ghost.ModelIdentAuthor.GetName());

                            //         UI::TableNextRow();
                            //         UI::TableNextColumn();
                            //         UI::Text("ModelIdentCollection");
                            //         UI::TableNextColumn();
                            //         UI::Text(tostring(ghost.ModelIdentCollection));

                            //         UI::TableNextRow();
                            //         UI::TableNextColumn();
                            //         UI::Text("ModelIdentCollection_Text");
                            //         // UI::TableNextColumn();
                            //         // UI::Text(tostring(ghost.ModelIdentCollection_Text));

                            //         UI::PopStyleColor();
                            //         UI::EndTable();
                            //     }

                            //     UI::EndTabItem();
                            // }

                            if (UI::BeginTabItem("API Offsets")) {
                                if (UI::BeginTable("##table-api-offsets", 4, UI::TableFlags::Resizable | UI::TableFlags::RowBg | UI::TableFlags::ScrollY)) {
                                    UI::PushStyleColor(UI::Col::TableRowBgAlt, vec4(0.0f, 0.0f, 0.0f, 0.5f));

                                    UI::TableSetupScrollFreeze(0, 1);
                                    UI::TableSetupColumn("name");
                                    // UI::TableSetupColumn("type");
                                    // UI::TableSetupColumn("size (B)");
                                    UI::TableSetupColumn("offset (dec)");
                                    UI::TableSetupColumn("offset (hex)");
                                    // UI::TableSetupColumn("value");
                                    UI::TableHeadersRow();

                                    const Reflection::MwClassInfo@ info = Reflection::GetType("CGameCtnGhost");

                                    for (uint i = 0; i < info.Members.Length; i++) {
                                        const Reflection::MwMemberInfo@ member = info.Members[i];

                                        UI::TableNextRow();

                                        UI::TableNextColumn();
                                        UI::Text(member.Name);

                                        UI::TableNextColumn();
                                        UI::Text(tostring(member.Offset));

                                        UI::TableNextColumn();
                                        UI::Text(IntToHex(member.Offset));
                                    }

                                    UI::PopStyleColor();
                                    UI::EndTable();
                                }

                                UI::EndTabItem();
                            }

                            if (UI::BeginTabItem("Raw Offsets")) {
                                if (UI::BeginTable("##table-offsets", 2, UI::TableFlags::RowBg | UI::TableFlags::ScrollY)) {
                                    UI::PushStyleColor(UI::Col::TableRowBgAlt, vec4(0.0f, 0.0f, 0.0f, 0.5f));

                                    UI::TableSetupColumn("offset");
                                    UI::TableSetupColumn("value");
                                    UI::TableHeadersRow();

                                    UI::ListClipper clipper(2000);
                                    while (clipper.Step()) {
                                        for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++) {
                                            const uint offset = i * 1;

                                            UI::TableNextRow();

                                            UI::TableNextColumn();
                                            UI::Text(tostring(offset));

                                            UI::TableNextColumn();
                                            const uint8 val = Dev::GetOffsetUint8(ghost, offset);
                                            UI::Text((val == 160 ? "\\$0F0" : val == 0 ? "\\$F00" : "") + tostring(val));
                                            // UI::Text((val == 0 ? "\\$F00" : "") + tostring(val));
                                        }
                                    }

                                    UI::TableNextRow();
                                    UI::PopStyleColor();
                                    UI::EndTable();
                                }

                                UI::EndTabItem();
                            }

                            if (UI::BeginTabItem("Memory Table")) {
                                const uint rows = 128;
                                const uint cols = 16;

                                if (UI::BeginTable("##table-memory", cols + 1, UI::TableFlags::RowBg | UI::TableFlags::ScrollY)) {
                                    UI::PushStyleColor(UI::Col::TableRowBgAlt, vec4(0.0f, 0.0f, 0.0f, 0.5f));

                                    UI::TableSetupColumn("#", UI::TableColumnFlags::WidthFixed, 25.0f);

                                    for (uint i = 0; i < cols; i++)
                                        UI::TableSetupColumn("", UI::TableColumnFlags::WidthFixed, 25.0f);

                                    UI::TableHeadersRow();

                                    uint offset = 0;

                                    for (uint i = 0; i < rows; i++) {
                                        UI::TableNextRow();

                                        UI::TableNextColumn();
                                        UI::Text(tostring(i));

                                        for (uint j = 0; j < cols; j++) {
                                            UI::TableNextColumn();
                                            const string val = IntToHex(Dev::GetOffsetUint8(ghost, offset), false);
                                            UI::Text((val == "0" ? "\\$F00" : "\\$0F0") + (val.Length < 2 ? "0" : "") + val);
                                            HoverTooltip(tostring(offset));

                                            offset += 1;
                                        }
                                    }

                                    UI::TableNextRow();
                                    UI::PopStyleColor();
                                    UI::EndTable();
                                }

                                UI::EndTabItem();
                            }

                        UI::EndTabBar();
                    }
                }

                UI::EndTabItem();
            }

        UI::EndTabBar();
    }

    UI::End();
}

CGameCtnGhost@ ghost;

const string IntToHex(const int i, const bool pre = true) {
    return (pre ? "0x" : "") + Text::Format("%X", i);
}

void HoverTooltip(const string &in msg) {
    if (!UI::IsItemHovered())
        return;

    UI::BeginTooltip();
        UI::Text(msg);
    UI::EndTooltip();
}

void AddValidation() {
    AddValidationGhostFromReplayPath("C:/Users/Ezio/Documents/Trackmania2020/Replays/My Replays/test-play-against_EzioTM_2024-06-17_16-19-58(00'03''308).Replay.Gbx");
}

void AddValidationGhost(CGameGhostScript@ Ghost) {
    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    CGameCtnEditorFree@ Editor = cast<CGameCtnEditorFree@>(App.Editor);
    if (Editor is null) {
        warn("Editor null");
        return;
    }

    CSmEditorPluginMapType@ PMT = cast<CSmEditorPluginMapType@>(Editor.PluginMapType);
    if (PMT is null) {
        warn("PMT null");
        return;
    }

    PMT.SetAuthorTimeAndGhost(Ghost);
}

void AddValidationGhostFromReplayPath(const string &in path) {
    if (!IO::FileExists(path)) {
        warn("path not found");
        return;
    }

    // CGameGhostScript@ Ghost = GhostScriptFromReplayPath(path);

    CTrackMania@ App = cast<CTrackMania@>(GetApp());
    CTrackManiaNetwork@ Network = cast<CTrackManiaNetwork@>(App.Network);

    CGameManiaAppPlayground@ CMAP = Network.ClientManiaAppPlayground;
    if (CMAP is null)
        return;

    CGameDataFileManagerScript@ FileMgr = CMAP.DataFileMgr;
    if (FileMgr is null)
        return;

    CWebServicesTaskResult_GhostListScript@ task = FileMgr.Replay_Load(path);
    while (task.IsProcessing)
        yield();

    if (task.HasFailed || !task.HasSucceeded) {
        warn("task error: code " + task.ErrorCode + " | type " + task.ErrorType + " | desc" + task.ErrorDescription);
        FileMgr.ReleaseTaskResult(task.Id);
        return;
    }

    if (task.Ghosts.Length == 0 || task.Ghosts[0] is null) {
        warn("task has no ghosts");
        FileMgr.ReleaseTaskResult(task.Id);
        return;
    }

    CGameGhostScript@ Ghost = task.Ghosts[0];
    if (Ghost is null) {
        warn("Ghost is null here 1");
        FileMgr.ReleaseTaskResult(task.Id);
        return;
    }

    // FileMgr.ReleaseTaskResult(task.Id);

    if (Ghost is null) {
        warn("Ghost is null here 2");
        FileMgr.ReleaseTaskResult(task.Id);
        return;
    }

    // if (Ghost is null) {
    //     warn("Ghost null");
    //     return;
    // }

    // AddValidationGhost(Ghost);

    CGameCtnEditorFree@ Editor = cast<CGameCtnEditorFree@>(App.Editor);
    if (Editor is null) {
        warn("Editor null");
        return;
    }

    CSmEditorPluginMapType@ PMT = cast<CSmEditorPluginMapType@>(Editor.PluginMapType);
    if (PMT is null) {
        warn("PMT null");
        return;
    }

    PMT.SetAuthorTimeAndGhost(Ghost);
}

CGameCtnGhost@ ExtractGhostFromReplay(CGameCtnReplayRecord@ Replay) {
    return null;
}

CGameCtnChallenge@ ExtractMapFromReplay(CGameCtnReplayRecord@ Replay) {
    return null;
}

CGameGhostScript@ GhostScriptFromReplayPath(const string &in path) {
    if (!IO::FileExists(path)) {
        warn("path not found");
        return null;
    }

    CTrackMania@ App = cast<CTrackMania@>(GetApp());
    CTrackManiaNetwork@ Network = cast<CTrackManiaNetwork@>(App.Network);

    CGameManiaAppPlayground@ CMAP = Network.ClientManiaAppPlayground;
    if (CMAP is null)
        return null;

    CGameDataFileManagerScript@ FileMgr = CMAP.DataFileMgr;
    if (FileMgr is null)
        return null;

    CWebServicesTaskResult_GhostListScript@ task = FileMgr.Replay_Load(path);
    while (task.IsProcessing)
        yield();

    if (task.HasFailed || !task.HasSucceeded) {
        warn("task error: code " + task.ErrorCode + " | type " + task.ErrorType + " | desc" + task.ErrorDescription);
        FileMgr.ReleaseTaskResult(task.Id);
        return null;
    }

    if (task.Ghosts.Length == 0 || task.Ghosts[0] is null) {
        warn("task has no ghosts");
        FileMgr.ReleaseTaskResult(task.Id);
        return null;
    }

    CGameGhostScript@ Script = task.Ghosts[0];
    if (Script is null) {
        warn("Script is null here 1");
        FileMgr.ReleaseTaskResult(task.Id);
        return null;
    }

    // FileMgr.ReleaseTaskResult(task.Id);

    if (Script is null) {
        warn("Script is null here 2");
        FileMgr.ReleaseTaskResult(task.Id);
        return null;
    }

    return Script;
}

uint64 CTmRaceResult_VTable_Ptr = 0x0;

CGameGhostScript@ GhostToGhostScript(CGameCtnGhost@ Ghost) {
    Ghost.MwAddRef();

    // create the script obj and populate fields round 1
    CGameGhostScript@ Script = CGameGhostScript();
    MwId ghostId = MwId();
    Dev::SetOffset(Script, 0x18, ghostId.Value);
    Dev::SetOffset(Script, 0x20, Ghost);
    uint64 ghostPtr = Dev::GetOffsetUint64(Script, 0x20);

    // the TmRaceResult nod
    // create some space in memory, will be freed by the game but might crash since vtable changes
    // CTmRaceResult is smaller than CGameCtnGhost, so that's fine at least.
    CGameGhostScript@ tmRaceResultNodPre = CGameGhostScript();
    Dev::SetOffset(tmRaceResultNodPre, 0x0, CTmRaceResult_VTable_Ptr);
    trace('force casting');
    CTmRaceResultNod@ tmRaceResultNod = Dev::ForceCast<CTmRaceResultNod@>(tmRaceResultNodPre).Get();
    trace('done force casting');
    // don't interact with this since we changed vtable.
    @tmRaceResultNodPre = null;
    Dev::SetOffset(tmRaceResultNod, 0x18, ghostPtr + 0x28);
    tmRaceResultNod.MwAddRef();

    // final round of setting fields
    Dev::SetOffset(Script, 0x28, tmRaceResultNod);

    // rest of nod should/can be 00s (including fid and refcount)
    return Script;
}

void LoadReplay() {
    loadedGhostId = LoadGhostFromReplayPath("C:/Users/Ezio/Documents/Trackmania2020/Replays/Downloaded/Fall 2023 - 20_KarjeN_2024_06_17_15_06_48_(0_43.502).Replay.Gbx");
}

MwId LoadGhostFromReplayPath(const string &in path) {
    if (!IO::FileExists(path)) {
        warn("path not found");
        return MwId();
    }

    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    CSmArenaRulesMode@ PlaygroundScript = cast<CSmArenaRulesMode@>(App.PlaygroundScript);
    if (PlaygroundScript is null || PlaygroundScript.GhostMgr is null)
        return MwId();

    CGameGhostScript@ Script = GhostScriptFromReplayPath(path);

    return PlaygroundScript.GhostMgr.Ghost_Add(Script, true);
}

void MakeGhostScript() {
    const string ghostFileName = "kelven.Ghost.gbx";

    CSystemFidFile@ fid = Fids::GetUser("Replays/" + ghostFileName);
    if (fid is null) {
        warn("fid null");
        return;
    }

    CGameCtnGhost@ Ghost = cast<CGameCtnGhost@>(Fids::Preload(fid));
    if (Ghost is null) {
        warn("Ghost null");
        return;
    }

    ExploreNod("ghost", Ghost);

    const string path = "C:/Users/Ezio/Documents/Trackmania2020/Replays/Downloaded/Fall 2023 - 20_KarjeN_2024_06_17_15_06_48_(0_43.502).Replay.Gbx";

    // CGameGhostScript@ _Script = GhostScriptFromReplayPath(path);
    // if (_Script is null) {
    //     warn("_Script null");
    //     return;
    // }

    if (!IO::FileExists(path)) {
        warn("path not found");
        return;
    }

    CTrackMania@ App = cast<CTrackMania@>(GetApp());
    CTrackManiaNetwork@ Network = cast<CTrackManiaNetwork@>(App.Network);

    CGameManiaAppPlayground@ CMAP = Network.ClientManiaAppPlayground;
    if (CMAP is null) {
        warn("CMAP null");
        return;
    }

    CGameDataFileManagerScript@ FileMgr = CMAP.DataFileMgr;
    if (FileMgr is null) {
        warn("FileMgr null");
        return;
    }

    CWebServicesTaskResult_GhostListScript@ task = FileMgr.Replay_Load(path);
    while (task.IsProcessing)
        yield();

    if (task.HasFailed || !task.HasSucceeded) {
        warn("task error: code " + task.ErrorCode + " | type " + task.ErrorType + " | desc" + task.ErrorDescription);
        FileMgr.ReleaseTaskResult(task.Id);
        return;
    }

    if (task.Ghosts.Length == 0 || task.Ghosts[0] is null) {
        warn("task has no ghosts");
        FileMgr.ReleaseTaskResult(task.Id);
        return;
    }

    CGameGhostScript@ _Script = task.Ghosts[0];
    if (_Script is null) {
        warn("_Script is null here 1");
        FileMgr.ReleaseTaskResult(task.Id);
        return;
    }

    // FileMgr.ReleaseTaskResult(task.Id);

    // if (Script is null) {
    //     warn("Script is null here 2");
    //     FileMgr.ReleaseTaskResult(task.Id);
    //     return;
    // }

    CTmRaceResult_VTable_Ptr = Dev::GetOffsetUint64(_Script.Result, 0x0);
    print("CTmRaceResult_VTable_Ptr: " + CTmRaceResult_VTable_Ptr);

    CGameGhostScript@ Script = GhostToGhostScript(Ghost);

    ExploreNod("script", Script);

    CSmArenaRulesMode@ PlaygroundScript = cast<CSmArenaRulesMode@>(App.PlaygroundScript);
    if (PlaygroundScript is null || PlaygroundScript.GhostMgr is null) {
        warn("PlaygroundScript issue");
        return;
    }

    PlaygroundScript.GhostMgr.Ghost_Add(Script, true);
}

void PlayAgainst() {
    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    CGameManiaTitleControlScriptAPI@ TitleControl = App.ManiaTitleControlScriptAPI;
    if (TitleControl is null)
        return;

    // const string path = "C:/Users/Ezio/Documents/Trackmania2020/Replays/Downloaded/Fall 2023 - 20_KarjeN_2024_06_17_15_06_48_(0_43.502).Replay.Gbx";
    // const string path = "C:/Users/Ezio/Documents/Trackmania2020/Replays/My Replays/test-play-against_EzioTM_2024-06-17_16-19-58(00'03''308).Replay.Gbx";
    const string path = "C:/Users/Ezio/Documents/Trackmania2020/Replays/My Replays/test_validation_ghost_EzioTM_2024-06-17_16-33-22(00'04''600).Replay.Gbx";
    if (!IO::FileExists(path)) {
        warn("path not found");
        return;
    }

    const string settings = string::Join({
        "<root>",
        "<setting name=\"S_TimeLimit\" value=\"-1\" type=\"integer\"/>",
        "<setting name=\"S_ForceLapsNb\" value=\"-1\" type=\"integer\"/>",
        "<setting name=\"S_AgainstReplay\" value=\"*vsreplayopponents*\" type=\"text\" />",
        "</root>"
    }, "");

    while (!TitleControl.IsReady)
        yield();

    print("playing");

    TitleControl.PlayAgainstReplay(path, "TrackMania/TM_PlayMap_Local", settings);

    while (!TitleControl.IsReady)
        yield();
}

void RemoveLoadedGhost(MwId id) {
    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    CSmArenaRulesMode@ PlaygroundScript = cast<CSmArenaRulesMode@>(App.PlaygroundScript);
    if (PlaygroundScript is null || PlaygroundScript.GhostMgr is null)
        return;

    PlaygroundScript.GhostMgr.Ghost_Remove(id);
}
