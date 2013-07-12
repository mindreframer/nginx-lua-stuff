#include <Python.h>
#include "ip.h"

static PyObject* load_datafile(PyObject* self, PyObject* args) {
    char* datafile = NULL;
    if (!PyArg_ParseTuple(args, "s", &datafile) || NULL == datafile)
        return NULL;
    if (-1 == load_ip_data_file(datafile))
        return NULL;
    Py_RETURN_NONE;
}

static PyObject* get_ip_info(PyObject* self, PyObject* args) {
    char *ip = NULL;
    if (! PyArg_ParseTuple(args, "s", &ip))
        return NULL;
    return Py_BuildValue("s", query(ip));
}

static PyObject* py_release(PyObject* self, PyObject* args) {
    release();
    Py_RETURN_NONE;
}

static PyMethodDef ipqueryMethods[] = {
    {"load_datafile", load_datafile, METH_VARARGS, "load data file"},
    {"get_ip_info", get_ip_info, METH_VARARGS, "query ip's info"},
    {"release", py_release, METH_VARARGS, "release system resource"},
    {NULL, NULL}
};

void initipquery(void) {
    Py_InitModule("ipquery", ipqueryMethods);
}
