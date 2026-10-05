// Characterization harness. Official GE-SpMM kernel bodies are in ge_kernels.cuh.
#include <cuda_runtime.h>
#include <cusparse.h>
#include <algorithm>
#include <chrono>
#include <cmath>
#include <fstream>
#include <functional>
#include <iomanip>
#include <iostream>
#include <numeric>
#include <stdexcept>
#include <string>
#include <vector>
#include "ge_kernels.cuh"
using Clock=std::chrono::steady_clock;
#define CU(x) do{cudaError_t s=(x);if(s!=cudaSuccess)throw std::runtime_error(std::string(#x)+": "+cudaGetErrorString(s));}while(0)
#define SP(x) do{cusparseStatus_t s=(x);if(s!=CUSPARSE_STATUS_SUCCESS)throw std::runtime_error(std::string(#x)+": "+cusparseGetErrorString(s));}while(0)
template<class T>std::vector<T> read(const std::string&p,size_t n){std::vector<T>x(n);std::ifstream f(p,std::ios::binary);f.read((char*)x.data(),n*sizeof(T));if(!f)throw std::runtime_error("read "+p);return x;}
template<class T>T* device(const std::vector<T>&x){T*p;CU(cudaMalloc(&p,x.size()*sizeof(T)));CU(cudaMemcpy(p,x.data(),x.size()*sizeof(T),cudaMemcpyHostToDevice));return p;}
template<class T>void upload(T*p,const std::vector<T>&x){CU(cudaMemcpy(p,x.data(),x.size()*sizeof(T),cudaMemcpyHostToDevice));}
double wall(Clock::time_point t){return std::chrono::duration<double,std::micro>(Clock::now()-t).count();}
double event(const std::function<void()>&f){cudaEvent_t a,b;CU(cudaEventCreate(&a));CU(cudaEventCreate(&b));CU(cudaEventRecord(a));f();CU(cudaEventRecord(b));CU(cudaEventSynchronize(b));float ms;CU(cudaEventElapsedTime(&ms,a,b));CU(cudaEventDestroy(a));CU(cudaEventDestroy(b));return ms*1000.;}
std::vector<double> samples(const std::function<void()>&f,int count){std::vector<double>x;for(int r=0;r<9;r++)x.push_back(event([&]{for(int j=0;j<count;j++)f();})/count);return x;}
void array(const std::vector<double>&v){std::cout<<"[";for(size_t j=0;j<v.size();j++){if(j)std::cout<<",";std::cout<<v[j];}std::cout<<"]";}
struct SparseOp{
 cusparseHandle_t h;cusparseSpMatDescr_t A=nullptr;cusparseDnMatDescr_t B=nullptr,C=nullptr;cusparseDnVecDescr_t X=nullptr,Y=nullptr;
 int m,k,n,z,alg;bool col;int*rp,*ix;float*av,*b,*c;void*work=nullptr;size_t bytes=0;float one=1,zero=0;
 SparseOp(cusparseHandle_t hh,int mm,int kk,int nn,int zz,int aa,bool cc,int*r,int*i,float*v,float*bb,float*oo):h(hh),m(mm),k(kk),n(nn),z(zz),alg(aa),col(cc),rp(r),ix(i),av(v),b(bb),c(oo){
   if(n==1){SP(cusparseCreateDnVec(&X,k,b,CUDA_R_32F));SP(cusparseCreateDnVec(&Y,m,c,CUDA_R_32F));}
   else{SP(cusparseCreateDnMat(&B,k,n,col?k:n,b,CUDA_R_32F,col?CUSPARSE_ORDER_COL:CUSPARSE_ORDER_ROW));SP(cusparseCreateDnMat(&C,m,n,col?m:n,c,CUDA_R_32F,col?CUSPARSE_ORDER_COL:CUSPARSE_ORDER_ROW));}reset();
 }
 cusparseSpMVAlg_t va(){return alg==1?CUSPARSE_SPMV_CSR_ALG1:CUSPARSE_SPMV_CSR_ALG2;}
 cusparseSpMMAlg_t ma(){return alg==1?CUSPARSE_SPMM_CSR_ALG1:alg==2?CUSPARSE_SPMM_CSR_ALG2:CUSPARSE_SPMM_CSR_ALG3;}
 void reset(){if(A)SP(cusparseDestroySpMat(A));SP(cusparseCreateCsr(&A,m,k,z,rp,ix,av,CUSPARSE_INDEX_32I,CUSPARSE_INDEX_32I,CUSPARSE_INDEX_BASE_ZERO,CUDA_R_32F));size_t need=0;
  if(n==1)SP(cusparseSpMV_bufferSize(h,CUSPARSE_OPERATION_NON_TRANSPOSE,&one,A,X,&zero,Y,CUDA_R_32F,va(),&need));
  else SP(cusparseSpMM_bufferSize(h,CUSPARSE_OPERATION_NON_TRANSPOSE,CUSPARSE_OPERATION_NON_TRANSPOSE,&one,A,B,&zero,C,CUDA_R_32F,ma(),&need));
  if(need>bytes){if(work)CU(cudaFree(work));CU(cudaMalloc(&work,need));bytes=need;}
 }
 void prepare(){if(n==1)SP(cusparseSpMV_preprocess(h,CUSPARSE_OPERATION_NON_TRANSPOSE,&one,A,X,&zero,Y,CUDA_R_32F,va(),work));else SP(cusparseSpMM_preprocess(h,CUSPARSE_OPERATION_NON_TRANSPOSE,CUSPARSE_OPERATION_NON_TRANSPOSE,&one,A,B,&zero,C,CUDA_R_32F,ma(),work));}
 void launch(){if(n==1)SP(cusparseSpMV(h,CUSPARSE_OPERATION_NON_TRANSPOSE,&one,A,X,&zero,Y,CUDA_R_32F,va(),work));else SP(cusparseSpMM(h,CUSPARSE_OPERATION_NON_TRANSPOSE,CUSPARSE_OPERATION_NON_TRANSPOSE,&one,A,B,&zero,C,CUDA_R_32F,ma(),work));}
 ~SparseOp(){if(A)cusparseDestroySpMat(A);if(B)cusparseDestroyDnMat(B);if(C)cusparseDestroyDnMat(C);if(X)cusparseDestroyDnVec(X);if(Y)cusparseDestroyDnVec(Y);if(work)cudaFree(work);}
};
int main(int argc,char**argv){try{
 if(argc<9)throw std::runtime_error("matrix_dir dense_dir M K N nnz exact output_dir [only_method]");
 std::cout<<std::setprecision(10);std::string md=argv[1],bd=argv[2],od=argv[8];int m=atoi(argv[3]),k=atoi(argv[4]),n=atoi(argv[5]),z=atoi(argv[6]);bool exact=atoi(argv[7]);std::string only=argc>9?argv[9]:"all";
 auto rp=read<int>(md+"/row_ptr.bin",m+1),ix=read<int>(md+"/col_idx.bin",z);auto av=read<float>(md+"/values.bin",z),b=read<float>(bd+"/B.bin",size_t(k)*n);auto expected=read<double>(bd+"/expected.bin",size_t(m)*n);
 CU(cudaSetDevice(0));CU(cudaFree(nullptr));cusparseHandle_t h;SP(cusparseCreate(&h));SP(cusparseSetStream(h,cudaStreamPerThread));cudaDeviceProp prop;CU(cudaGetDeviceProperties(&prop,0));int version,driver,rt;SP(cusparseGetVersion(h,&version));CU(cudaDriverGetVersion(&driver));CU(cudaRuntimeGetVersion(&rt));
 std::cout<<"{\"type\":\"environment\",\"gpu\":\""<<prop.name<<"\",\"sm_count\":"<<prop.multiProcessorCount<<",\"l2_bytes\":"<<prop.l2CacheSize<<",\"cusparse_version\":"<<version<<",\"runtime_version\":"<<rt<<",\"driver_api_version\":"<<driver<<"}\n";
 auto t=Clock::now();int*drp=device(rp),*dix=device(ix);float*dav=device(av),*db=device(b),*dc;CU(cudaMalloc(&dc,size_t(m)*n*4));CU(cudaDeviceSynchronize());double h2d=wall(t);
 for(int method=0;method<7;method++){
   bool lib=method>=4;int alg=method-3;if(n==1&&alg==3)continue;bool col=lib&&alg==1&&n>1;
   std::string name=lib?"cusparse_alg"+std::to_string(alg)+(col?"_col":"_row"):std::vector<std::string>{"ge_plain","ge_cache","ge_merge2","ge_merge4"}[method];if(only!="all"&&name!=only)continue;
   try{
    upload(dix,ix);upload(dav,av);t=Clock::now();auto packed=b;if(col)for(int i=0;i<k;i++)for(int j=0;j<n;j++)packed[size_t(j)*k+i]=b[size_t(i)*n+j];double packing=wall(t);upload(db,packed);
    SparseOp*op=nullptr;t=Clock::now();if(lib)op=new SparseOp(h,m,k,n,z,alg,col,drp,dix,dav,db,dc);double setup=wall(t);
    auto launch=[&]{if(lib)op->launch();else{spmmWrapper(method,4,m,n,drp,dix,dav,db,dc);CU(cudaGetLastError());}};
    auto validate=[&](int session){
      auto vv=av,bb=b;auto ii=ix;if(session){for(auto&v:vv)v*=-2;for(auto&v:bb)v+=1;}if(session==2)for(auto&i:ii)i=(i+17)%k;
      if(session){upload(dav,vv);upload(dix,ii);auto pp=bb;if(col)for(int r=0;r<k;r++)for(int c=0;c<n;c++)pp[size_t(c)*k+r]=bb[size_t(r)*n+c];upload(db,pp);if(lib&&session==2){op->reset();op->prepare();}}
      CU(cudaMemset(dc,0xff,size_t(m)*n*4));launch();CU(cudaDeviceSynchronize());std::vector<float> raw(size_t(m)*n),out(raw.size());CU(cudaMemcpy(raw.data(),dc,raw.size()*4,cudaMemcpyDeviceToHost));
      for(int r=0;r<m;r++)for(int c=0;c<n;c++)out[size_t(r)*n+c]=raw[col?size_t(c)*m+r:size_t(r)*n+c];
      double max_abs=0,max_scaled=0;size_t bad=0;for(int r=0;r<m;r++)for(int c=0;c<n;c++){
        double ref=session?0:expected[size_t(r)*n+c];if(session)for(int p=rp[r];p<rp[r+1];p++)ref+=double(vv[p])*double(bb[size_t(ii[p])*n+c]);
        double err=std::abs(double(out[size_t(r)*n+c])-ref);max_abs=std::max(max_abs,err);max_scaled=std::max(max_scaled,err/(5e-5+5e-5*std::abs(ref)));
        if(!std::isfinite(out[size_t(r)*n+c])||err>(exact?0:5e-5+5e-5*std::abs(ref)))bad++;
      }
      std::ofstream f(od+"/"+name+"-session"+std::to_string(session)+".bin",std::ios::binary);f.write((char*)out.data(),out.size()*4);
      if(bad)throw std::runtime_error("numerical failure session="+std::to_string(session)+" elements="+std::to_string(bad)+" max_scaled="+std::to_string(max_scaled));return max_scaled;
    };
    double orig_error=validate(0);for(int w=0;w<10;w++)launch();CU(cudaDeviceSynchronize());auto before=samples(launch,100);
    double prep_device=0,prep_wall=0;if(lib){t=Clock::now();prep_device=event([&]{op->prepare();});prep_wall=wall(t);}
    for(int w=0;w<10;w++)launch();CU(cudaDeviceSynchronize());auto after=samples(launch,100),single=samples(launch,1);
    cudaGraph_t graph;cudaGraphExec_t exec;t=Clock::now();CU(cudaStreamBeginCapture(0,cudaStreamCaptureModeGlobal));for(int j=0;j<100;j++)launch();CU(cudaStreamEndCapture(0,&graph));CU(cudaGraphInstantiate(&exec,graph,0));double graph_build=wall(t);
    auto gl=[&]{CU(cudaGraphLaunch(exec,0));};for(int w=0;w<3;w++)gl();CU(cudaDeviceSynchronize());auto graph_samples=samples(gl,1);for(auto&x:graph_samples)x/=100;
    std::vector<float> raw(size_t(m)*n);CU(cudaMemcpy(raw.data(),dc,raw.size()*4,cudaMemcpyDeviceToHost));for(int r=0;r<m;r++)for(int c=0;c<n;c++){double v=raw[col?size_t(c)*m+r:size_t(r)*n+c],ref=expected[size_t(r)*n+c];if(!std::isfinite(v)||std::abs(v-ref)>(exact?0:5e-5+5e-5*std::abs(ref)))throw std::runtime_error("graph numerical failure");}
    CU(cudaGraphExecDestroy(exec));CU(cudaGraphDestroy(graph));double changed_error=validate(1),pattern_error=validate(2);
    std::cout<<"{\"type\":\"measurement\",\"method\":\""<<name<<"\",\"status\":\"pass\",\"h2d_allocation_us\":"<<h2d<<",\"layout_pack_cpu_us\":"<<packing<<",\"descriptor_setup_wall_us\":"<<setup<<",\"workspace_bytes\":"<<(op?op->bytes:0)<<",\"preprocess_device_us\":"<<prep_device<<",\"preprocess_wall_us\":"<<prep_wall<<",\"graph_build_wall_us\":"<<graph_build<<",\"original_max_scaled_error\":"<<orig_error<<",\"changed_max_scaled_error\":"<<changed_error<<",\"pattern_max_scaled_error\":"<<pattern_error<<",\"single_us\":";array(single);std::cout<<",\"graph_us\":";array(graph_samples);std::cout<<",\"unprepared_host_batch_us\":";array(before);std::cout<<",\"prepared_host_batch_us\":";array(after);std::cout<<"}\n"<<std::flush;
    delete op;
   }catch(const std::exception&e){std::string why=e.what();std::replace(why.begin(),why.end(),'"','\'');std::cout<<"{\"type\":\"measurement\",\"method\":\""<<name<<"\",\"status\":\"failed\",\"reason\":\""<<why<<"\"}\n"<<std::flush;}
 }
 CU(cudaFree(drp));CU(cudaFree(dix));CU(cudaFree(dav));CU(cudaFree(db));CU(cudaFree(dc));SP(cusparseDestroy(h));return 0;
}catch(const std::exception&e){std::cerr<<e.what()<<"\n";return 1;}}
