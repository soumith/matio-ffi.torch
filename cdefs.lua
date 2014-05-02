-- Cut and paste from the C preprocessor output
-- Removed inline/defined functions which are not supported by luajit
-- Instead, those are defined into defines.lua
-- Note there are some tests here and there to stay cross-platform

local ffi = require 'ffi'

ffi.cdef[[
]]


ffi.cdef[[
enum mat_acc {
    MAT_ACC_RDONLY = 0,
    MAT_ACC_RDWR = 1
};

enum mat_ft {
    MAT_FT_MAT73 = 0x0200,
    MAT_FT_MAT5 = 0x0100,
    MAT_FT_MAT4 = 0x0010
};

enum matio_types {
    MAT_T_UNKNOWN = 0,
    MAT_T_INT8 = 1,
    MAT_T_UINT8 = 2,
    MAT_T_INT16 = 3,
    MAT_T_UINT16 = 4,
    MAT_T_INT32 = 5,
    MAT_T_UINT32 = 6,
    MAT_T_SINGLE = 7,
    MAT_T_DOUBLE = 9,
    MAT_T_INT64 = 12,
    MAT_T_UINT64 = 13,
    MAT_T_MATRIX = 14,
    MAT_T_COMPRESSED = 15,
    MAT_T_UTF8 = 16,
    MAT_T_UTF16 = 17,
    MAT_T_UTF32 = 18,

    MAT_T_STRING = 20,
    MAT_T_CELL = 21,
    MAT_T_STRUCT = 22,
    MAT_T_ARRAY = 23,
    MAT_T_FUNCTION = 24
};

enum matio_classes {
    MAT_C_EMPTY = 0,
    MAT_C_CELL = 1,
    MAT_C_STRUCT = 2,
    MAT_C_OBJECT = 3,
    MAT_C_CHAR = 4,
    MAT_C_SPARSE = 5,
    MAT_C_DOUBLE = 6,
    MAT_C_SINGLE = 7,
    MAT_C_INT8 = 8,
    MAT_C_UINT8 = 9,
    MAT_C_INT16 = 10,
    MAT_C_UINT16 = 11,
    MAT_C_INT32 = 12,
    MAT_C_UINT32 = 13,
    MAT_C_INT64 = 14,
    MAT_C_UINT64 = 15,
    MAT_C_FUNCTION = 16
};

enum matio_flags {
    MAT_F_COMPLEX = 0x0800,
    MAT_F_GLOBAL = 0x0400,
    MAT_F_LOGICAL = 0x0200,
    MAT_F_DONT_COPY_DATA = 0x0001
};

enum matio_compression {
    MAT_COMPRESSION_NONE = 0,
    MAT_COMPRESSION_ZLIB = 1
};

enum {
    MAT_BY_NAME = 1,
    MAT_BY_INDEX = 2
};

typedef struct mat_complex_split_t {
    void *Re;
    void *Im;
} mat_complex_split_t;

struct _mat_t;

typedef struct _mat_t mat_t;


struct matvar_internal;

typedef struct matvar_t {
    size_t nbytes;
    int rank;
    enum matio_types data_type;
    int data_size;
    enum matio_classes class_type;
    int isComplex;
    int isGlobal;
    int isLogical;
    size_t *dims;
    char *name;
    void *data;
    int mem_conserve;
    enum matio_compression compression;
    struct matvar_internal *internal;
} matvar_t;






typedef struct mat_sparse_t {
    int nzmax;
    int *ir;


    int nir;
    int *jc;



    int njc;
    int ndata;
    void *data;
} mat_sparse_t;


extern void Mat_GetLibraryVersion(int *major,int *minor,int *release);


extern char *strdup_vprintf(const char *format, va_list ap);
extern char *strdup_printf(const char *format, ...);
extern int Mat_SetVerbose( int verb, int s );
extern int Mat_SetDebug( int d );
extern void Mat_Critical( const char *format, ... );
extern void Mat_Error( const char *format, ... );
extern void Mat_Help( const char *helpstr[] );
extern int Mat_LogInit( const char *progname );
extern int Mat_LogClose(void);
extern int Mat_LogInitFunc(const char *prog_name,
                    void (*log_func)(int log_level, char *message) );
extern int Mat_Message( const char *format, ... );
extern int Mat_DebugMessage( int level, const char *format, ... );
extern int Mat_VerbMessage( int level, const char *format, ... );
extern void Mat_Warning( const char *format, ... );
extern size_t Mat_SizeOf(enum matio_types data_type);
extern size_t Mat_SizeOfClass(int class_type);



extern mat_t *Mat_CreateVer(const char *matname,const char *hdr_str,
                       enum mat_ft mat_file_ver);
extern int Mat_Close(mat_t *mat);
extern mat_t *Mat_Open(const char *matname,int mode);
extern const char *Mat_GetFilename(mat_t *matfp);
extern enum mat_ft Mat_GetVersion(mat_t *matfp);
extern int Mat_Rewind(mat_t *mat);


extern matvar_t *Mat_VarCalloc(void);
extern matvar_t *Mat_VarCreate(const char *name,enum matio_classes class_type,
                      enum matio_types data_type,int rank,size_t *dims,
                      void *data,int opt);
extern matvar_t *Mat_VarCreateStruct(const char *name,int rank,size_t *dims,
                      const char **fields,unsigned nfields);
extern int Mat_VarDelete(mat_t *mat, const char *name);
extern matvar_t *Mat_VarDuplicate(const matvar_t *in, int opt);
extern void Mat_VarFree(matvar_t *matvar);
extern matvar_t *Mat_VarGetCell(matvar_t *matvar,int index);
extern matvar_t **Mat_VarGetCells(matvar_t *matvar,int *start,int *stride,
                      int *edge);
extern matvar_t **Mat_VarGetCellsLinear(matvar_t *matvar,int start,int stride,
                      int edge);
extern size_t Mat_VarGetSize(matvar_t *matvar);
extern unsigned Mat_VarGetNumberOfFields(matvar_t *matvar);
extern int Mat_VarAddStructField(matvar_t *matvar,const char *fieldname);
extern char * const *Mat_VarGetStructFieldnames(const matvar_t *matvar);
extern matvar_t *Mat_VarGetStructFieldByIndex(matvar_t *matvar,
                      size_t field_index,size_t index);
extern matvar_t *Mat_VarGetStructFieldByName(matvar_t *matvar,
                      const char *field_name,size_t index);
extern matvar_t *Mat_VarGetStructField(matvar_t *matvar,void *name_or_index,
                      int opt,int index);
extern matvar_t *Mat_VarGetStructs(matvar_t *matvar,int *start,int *stride,
                      int *edge,int copy_fields);
extern matvar_t *Mat_VarGetStructsLinear(matvar_t *matvar,int start,int stride,
                      int edge,int copy_fields);
extern void Mat_VarPrint( matvar_t *matvar, int printdata );
extern matvar_t *Mat_VarRead(mat_t *mat, const char *name );
extern int Mat_VarReadData(mat_t *mat,matvar_t *matvar,void *data,
                      int *start,int *stride,int *edge);
extern int Mat_VarReadDataAll(mat_t *mat,matvar_t *matvar);
extern int Mat_VarReadDataLinear(mat_t *mat,matvar_t *matvar,void *data,
                      int start,int stride,int edge);
extern matvar_t *Mat_VarReadInfo( mat_t *mat, const char *name );
extern matvar_t *Mat_VarReadNext( mat_t *mat );
extern matvar_t *Mat_VarReadNextInfo( mat_t *mat );
extern matvar_t *Mat_VarSetCell(matvar_t *matvar,int index,matvar_t *cell);
extern matvar_t *Mat_VarSetStructFieldByIndex(matvar_t *matvar,
                      size_t field_index,size_t index,matvar_t *field);
extern matvar_t *Mat_VarSetStructFieldByName(matvar_t *matvar,
                      const char *field_name,size_t index,matvar_t *field);
extern int Mat_VarWrite(mat_t *mat,matvar_t *matvar,
                      enum matio_compression compress );
extern int Mat_VarWriteInfo(mat_t *mat,matvar_t *matvar);
extern int Mat_VarWriteData(mat_t *mat,matvar_t *matvar,void *data,
                      int *start,int *stride,int *edge);


extern int Mat_CalcSingleSubscript(int rank,int *dims,int *subs);
extern int *Mat_CalcSubscripts(int rank,int *dims,int index);

]]
