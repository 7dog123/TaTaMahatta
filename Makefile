# Ta-Ta Mahatta - MinGW32 build
#
# Cross-compiles from Linux with the mingw-w64 32-bit toolchain.
#   make            - release build -> TATA_MAHATTA.exe (+ BASS.DLL copy)
#   make BUILD=debug
#   make clean
#
# Requires: i686-w64-mingw32-gcc/g++/windres/ar (Debian: g++-mingw-w64-i686)

CROSS  ?= i686-w64-mingw32-
CXX    := $(CROSS)g++
AR     := $(CROSS)ar
WINDRES:= $(CROSS)windres

BUILD ?= release
ifeq ($(BUILD),debug)
  OPTFLAGS := -O0 -g -D_DEBUG
else
  OPTFLAGS := -O2 -DNDEBUG
endif

# Old VS2010-era code; keep the dialect permissive.
CXXFLAGS := $(OPTFLAGS) -std=gnu++98 -Wall -Wno-unknown-pragmas \
            -Wno-write-strings -Wno-conversion-null \
            -MMD -MP -fno-strict-aliasing -fpermissive -fcommon
LDFLAGS  := -mwindows -static-libgcc -static-libstdc++

BUILD_DIR   := build
DT          := david tools
# space-free symlinks into "david tools" and Source/
LINK_DT     := $(BUILD_DIR)/dt
LINK_SRC    := $(BUILD_DIR)/src

# ---- include paths ------------------------------------------------------
INCLUDES_COMMON  := -I"$(DT)" -I$(LINK_SRC)
INCLUDES_GFX     := -I"$(DT)" -I$(LINK_DT)/graphicsX
INCLUDES_INPX    := -I"$(DT)" -I$(LINK_DT)/InputX
INCLUDES_PARSER  := -I"$(DT)" -I$(LINK_DT)/Parser
INCLUDES_SCRIPT  := -I"$(DT)" -I$(LINK_DT)/ScriptTease
INCLUDES_TIMER   := -I"$(DT)" -I$(LINK_DT)/TIMER
INCLUDES_GAME    := -ISource -I"$(DT)"

DX_LIBS := -ldxguid -ldinput8 -ld3d9 -ld3dx9
SYS_LIBS := $(DX_LIBS) -lwinmm -lcomdlg32 -lgdi32 -luser32 -lkernel32 -lshell32 -lole32

# ---- sources (mirror the original .vcxproj file lists) ------------------
GFX_SRCS := \
	GFX_BkgrndFX.cpp GFX_Camera.cpp GFX_ErrorCheck.cpp GFX_Fog.cpp \
	GFX_Font.cpp GFX_Frustrum.cpp GFX_Light.cpp GFX_Main.cpp GFX_Math.cpp \
	GFX_Misc.cpp GFX_Pager.cpp GFX_Primitives.cpp GFX_Screen.cpp \
	GFX_SkyBox.cpp GFX_Sprite.cpp GFX_ParticleFX.cpp PARFX_3DExplode.cpp \
	PARFX_expand.cpp PARFX_explode.cpp PARFX_gas.cpp PARFX_gather.cpp \
	PARFX_glow.cpp PARFX_lightningY.cpp PARFX_puff.cpp PARFX_smoke.cpp \
	GFX_joints.cpp GFX_mesh.cpp GFX_Model.cpp GFX_ModelFX.cpp \
	GFX_ModelGenMap.cpp GFX_ModelLoad_MD2.cpp GFX_ModelLoad_MS3D.cpp \
	GFX_Object.cpp GFX_ObjectLoad.cpp GFX_Map.cpp GFX_MapGenMidptFrac.cpp \
	GFX_QBSPCollision.cpp GFX_QBSPDestroy.cpp GFX_QBSPLoad.cpp \
	GFX_QBSPModel.cpp GFX_QBSPRender.cpp GFX_QBSPTool.cpp GFX_QBSPVisBit.cpp \
	GFX_Surface.cpp GFX_Texture.cpp GFX_TextureDisplay.cpp \
	D3DSTUFF/D3DFONT.CPP D3DSTUFF/D3DUTIL.CPP D3DSTUFF/DDUTIL.CPP D3DSTUFF/DXUTIL.CPP

INPX_SRCS := INP_ErrorCheck.cpp INP_Joystick.cpp INP_Keyboard.cpp INP_Main.cpp

PARSER_SRCS := commandline.cpp FINDFILE.CPP PARSER.CPP

SCRIPT_SRCS := CFG.CPP SCRIPT.CPP script_basics.cpp script_condition.cpp \
	script_function.cpp script_line.cpp script_param.cpp script_parse.cpp \
	script_variable.cpp scriptTease.cpp script_var_file.cpp \
	script_var_float.cpp script_var_int.cpp script_var_string.cpp \
	script_func_file.cpp script_func_float.cpp script_func_integer.cpp \
	script_func_string.cpp

TIMER_SRCS := w32Timer.cpp w32TimerFPS.cpp

GAME_SRCS := \
	MYWIN.CPP tata_destroy.cpp tata_init.cpp tata_main.cpp tata_tool.cpp \
	proc_credits.cpp proc_game.cpp proc_intro.cpp tata_basic.cpp \
	tata_bound.cpp tata_collision.cpp tata_error.cpp tata_ID.cpp \
	tata_input.cpp tata_proc.cpp tata_sound.cpp tata_stage_select.cpp \
	tata_view.cpp tata_waypoint.cpp tata_world.cpp \
	tata_world_ambientSound.cpp tata_world_cutscene.cpp \
	tata_world_display.cpp tata_world_HUD.cpp tata_world_music.cpp \
	tata_world_profile.cpp tata_world_target.cpp tata_world_update.cpp \
	tata_world_load.cpp tata_world_load_entity_block.cpp \
	tata_world_load_entity_button.cpp tata_world_load_entity_enemy.cpp \
	tata_world_load_entity_gas.cpp tata_world_load_entity_item.cpp \
	tata_world_load_entity_lever.cpp tata_world_load_entity_light.cpp \
	tata_world_load_entity_misc.cpp tata_world_load_entity_platform.cpp \
	tata_world_load_entity_sign.cpp tata_world_load_entity_start.cpp \
	tata_world_load_entity_steak.cpp tata_world_load_entity_tata.cpp \
	tata_world_load_entity_trigger.cpp tata_world_load_entity_waypoint.cpp \
	tata_creature.cpp tata_creature_status.cpp creature_BabyTaTa.cpp \
	creature_CaptainTaTa.cpp creature_ChiTa.cpp creature_FrostTa.cpp \
	creature_HopTaHop.cpp creature_KeyKeyTa.cpp creature_LoopTaLoop.cpp \
	creature_ParaTaTa.cpp creature_TaTaTrample.cpp creature_TaTaTug.cpp \
	creature_TaVatar.cpp creature_TinkerTa.cpp boss_CatterShroom.cpp \
	boss_CorrupTa.cpp boss_ShroomPa.cpp creature_FungaBark.cpp \
	creature_FungaMusketeer.cpp creature_FungaSmug.cpp creature_FungaSpy.cpp \
	creature_ShroomGuard.cpp creature_ShroomShooter.cpp object_block.cpp \
	object_button.cpp object_doodad.cpp object_geyser.cpp object_goal.cpp \
	object_lever.cpp object_lightningarea.cpp object_ouchfield.cpp \
	object_platform.cpp object_sign.cpp object_steak.cpp object_teleport.cpp \
	object_trigger.cpp object_turret.cpp tata_object.cpp \
	projectile_attackmelee.cpp projectile_frost.cpp projectile_gas.cpp \
	projectile_openmelee.cpp projectile_pullpower.cpp \
	projectile_pushmelee.cpp projectile_scanner.cpp projectile_spike.cpp \
	projectile_spit.cpp projectile_teleport.cpp projectile_usemelee.cpp \
	projectile_whip.cpp tata_projectile.cpp tata_item.cpp \
	script_creature.cpp script_dialog.cpp script_entity.cpp \
	script_image.cpp script_object.cpp script_target.cpp script_tata.cpp \
	script_vector.cpp script_view.cpp script_world.cpp \
	tata_script_query.cpp tata_menu.cpp tata_menu_cursor.cpp \
	tata_menu_game.cpp menu_item_button2D.cpp menu_item_button3D.cpp \
	menu_item_buttonText.cpp tata_menu_item.cpp menu_callback_exit.cpp \
	menu_callback_gameover.cpp menu_callback_jstick_cfg.cpp \
	menu_callback_kb_cfg.cpp menu_callback_levelselect.cpp \
	menu_callback_levelstart.cpp menu_callback_load.cpp \
	menu_callback_mainmenu.cpp menu_callback_new.cpp menu_callback_pause.cpp \
	menu_callback_pause_ingame.cpp menu_callback_victory.cpp \
	menu_callback_playtutorial.cpp menu_callback_options.cpp \
	menu_callback_options_audio.cpp menu_callback_options_gfx.cpp \
	menu_callback_options_input.cpp

# ---- objects & libraries ------------------------------------------------
# Sources carry mixed .cpp/.CPP extensions (original MSVC naming).
objext = $(patsubst %.cpp,%.o,$(patsubst %.CPP,%.o,$(1)))
GFX_OBJS    := $(addprefix $(BUILD_DIR)/obj/graphicsX/,$(call objext,$(GFX_SRCS)))
INPX_OBJS   := $(addprefix $(BUILD_DIR)/obj/InputX/,$(call objext,$(INPX_SRCS)))
PARSER_OBJS := $(addprefix $(BUILD_DIR)/obj/Parser/,$(call objext,$(PARSER_SRCS)))
SCRIPT_OBJS := $(addprefix $(BUILD_DIR)/obj/ScriptTease/,$(call objext,$(SCRIPT_SRCS)))
TIMER_OBJS  := $(addprefix $(BUILD_DIR)/obj/TIMER/,$(call objext,$(TIMER_SRCS)))
GAME_OBJS   := $(addprefix $(BUILD_DIR)/obj/game/,$(call objext,$(GAME_SRCS)))

LIBS := $(BUILD_DIR)/libgraphicsX.a $(BUILD_DIR)/libInputX.a \
        $(BUILD_DIR)/libParser.a $(BUILD_DIR)/libScriptTease.a \
        $(BUILD_DIR)/libtimer.a

RES_OBJ := $(BUILD_DIR)/tata_resource.o
TARGET  := TATA_MAHATTA.exe

.PHONY: all clean run
all: $(TARGET)

# ---- symlinks (keep build rules free of the space in "david tools") -----
# Bootstrapped at parse time: make must see the .cpp files while building
# its dependency graph, so order-only prerequisites alone won't cut it.
$(shell mkdir -p $(BUILD_DIR)/dt)
$(shell ln -sfn "../../david tools/graphicsX"  "$(BUILD_DIR)/dt/graphicsX")
$(shell ln -sfn "../../david tools/InputX"     "$(BUILD_DIR)/dt/InputX")
$(shell ln -sfn "../../david tools/Parser"     "$(BUILD_DIR)/dt/Parser")
$(shell ln -sfn "../../david tools/ScriptTease" "$(BUILD_DIR)/dt/ScriptTease")
$(shell ln -sfn "../../david tools/TIMER"      "$(BUILD_DIR)/dt/TIMER")
$(shell mkdir -p $(BUILD_DIR) && ln -sfn ../Source "$(BUILD_DIR)/src")

# ---- pattern rules -------------------------------------------------------
# Two variants per project: lowercase and uppercase .cpp extensions.
define OBJ_RULE
$(1)/%.o: $(2)/%.cpp | $(3)
	@mkdir -p $$(dir $$@)
	$$(CXX) $$(CXXFLAGS) $$(INCLUDES_$(4)) -c $$< -o $$@

$(1)/%.o: $(2)/%.CPP | $(3)
	@mkdir -p $$(dir $$@)
	$$(CXX) $$(CXXFLAGS) $$(INCLUDES_$(4)) -c $$< -o $$@
endef

$(eval $(call OBJ_RULE,$(BUILD_DIR)/obj/graphicsX,$(LINK_DT)/graphicsX,$(BUILD_DIR)/dt/graphicsX,GFX))
$(eval $(call OBJ_RULE,$(BUILD_DIR)/obj/InputX,$(LINK_DT)/InputX,$(BUILD_DIR)/dt/InputX,INPX))
$(eval $(call OBJ_RULE,$(BUILD_DIR)/obj/Parser,$(LINK_DT)/Parser,$(BUILD_DIR)/dt/Parser,PARSER))
$(eval $(call OBJ_RULE,$(BUILD_DIR)/obj/ScriptTease,$(LINK_DT)/ScriptTease,$(BUILD_DIR)/dt/ScriptTease,SCRIPT))
$(eval $(call OBJ_RULE,$(BUILD_DIR)/obj/TIMER,$(LINK_DT)/TIMER,$(BUILD_DIR)/dt/TIMER,TIMER))
$(eval $(call OBJ_RULE,$(BUILD_DIR)/obj/game,$(LINK_SRC),$(BUILD_DIR)/src,GAME))

$(BUILD_DIR)/%.a:
	rm -f $@
	$(AR) rcs $@ $^

$(BUILD_DIR)/libgraphicsX.a: $(GFX_OBJS)
$(BUILD_DIR)/libInputX.a: $(INPX_OBJS)
$(BUILD_DIR)/libParser.a: $(PARSER_OBJS)
$(BUILD_DIR)/libScriptTease.a: $(SCRIPT_OBJS)
$(BUILD_DIR)/libtimer.a: $(TIMER_OBJS)

$(RES_OBJ): Source/tata_win_resource.rc Source/RESOURCE.H TATAICON.ICO
	@mkdir -p $(BUILD_DIR)
	$(WINDRES) -ISource -I. $< $@

$(TARGET): $(GAME_OBJS) $(LIBS) $(RES_OBJ)
	$(CXX) $(LDFLAGS) -o $@ $(GAME_OBJS) $(RES_OBJ) $(LIBS) ./BASS.DLL $(SYS_LIBS)

run: $(TARGET)
	wine ./$(TARGET)

clean:
	rm -rf $(BUILD_DIR) $(TARGET)

-include $(wildcard $(BUILD_DIR)/obj/*/*.d)
