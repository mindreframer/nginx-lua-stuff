#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>
#include "ip.h"

static int load_data_file(lua_State* L) {
    lua_pushnumber(L, load_ip_data_file(luaL_checkstring(L, 1)));
    return 1;
}

static int get_ip_info(lua_State* L) {
    lua_pushstring(L, query(luaL_checkstring(L, 1)));
    return 1;
}

static int lua_release(lua_State* L) {
    release();
    return 0;
}

static luaL_Reg ipquery_methods[] = {
    {"load_data_file", load_data_file},
    {"get_ip_info", get_ip_info},
    {"lua_release", lua_release},
    {NULL, NULL}
};

int luaopen_ipquery(lua_State* L) {
    luaL_register(L, "ipquery", ipquery_methods);
    lua_pushvalue(L, -1);
    lua_setglobal(L, "ipquery");
    return 1;
}
