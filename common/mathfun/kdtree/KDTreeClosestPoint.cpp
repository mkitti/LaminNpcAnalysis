 /* [idx, dist] = KDTreeClosestPoint(inPts,queryPts);
 *
 * (c) Sylvain Berlemont, 2011 (last modified Oct 7, 2011)
 *
 * Compilation:
 * Mac/Linux: mex -I.  -I../../mex/include/c++ KDTreeClosestPoint.cpp
 * Windows: mex COMPFLAGS="$COMPFLAGS /TP" -I"." -I"..\..\mex\include\c++" -output KDTreeClosestPoint KDTreeClosestPoint.cpp
 */


#include <mex.h>

#include <list>
#include <map>
#include <vector>

#include <vector.hpp>
#include <KDTree.hpp>

template <unsigned K>
static void dispatch(int n, int m, double *x_ptr, double *y_ptr, int nlhs, mxArray *plhs[])
{
  // Read parameters
  typename KDTree<K, double>::points_type X;
  
  typename KDTree<K, double>::point_type v;
  
  for (int i = 0; i < n; ++i)
    {
      for (unsigned k = 0; k < K; ++k)
	v[k] = x_ptr[i + (n * k)];
      X.push_back(v);
    }

  typename KDTree<K, double>::points_type Y;

  for (int i = 0; i < m; ++i)
    {
      for (unsigned k = 0; k < K; ++k)
	v[k] = y_ptr[i + (m * k)];
      Y.push_back(v);
    }

  // Build kd-tree
  KDTree<K, double> kdtree(X);

  // Compute queries
  std::vector<unsigned> idx(m);
  std::vector<double> dist(m);

  typename KDTree<K,double>::pair_type pair;
	
  for (int i = 0; i < m; ++i)
    {
      pair = kdtree.closest_point(Y[i]);

      dist[i] = pair.first;
      idx[i] = pair.second;
    }

  // Write output
  if (nlhs > 0)
    {
      plhs[0] = mxCreateDoubleMatrix(m, 1, mxREAL);
      double * p = mxGetPr(plhs[0]);
				
      for (typename std::vector<unsigned>::const_iterator it = idx.begin(); it != idx.end(); ++it)
	*p++ = *it + 1;
    }

  if (nlhs > 1)
    {
      plhs[1] = mxCreateDoubleMatrix(m, 1, mxREAL);
      double * p = mxGetPr(plhs[1]);
				
      for (typename std::vector<double>::const_iterator it = dist.begin(); it != dist.end(); ++it)
	*p++ = *it;
    }
}

void mexFunction(int nlhs, mxArray *plhs[],
		 int nrhs, const mxArray *prhs[])
{
  // Check input/output parameter

  if (nrhs != 2)
    mexErrMsgTxt("Two input arguments required.");

  if (nlhs > 2)
    mexErrMsgTxt("Too many output arguments.");

  size_t k = mxGetN(prhs[0]);
  size_t n = mxGetM(prhs[0]);
  size_t m = mxGetM(prhs[1]);

  if (k != mxGetN(prhs[1]))
    mexErrMsgTxt("X and Y must have the same number of columns.");

  double *x_ptr = mxGetPr(prhs[0]);
  double *y_ptr = mxGetPr(prhs[1]);

  switch (k)
    {
    case 1: dispatch<1>(n, m, x_ptr, y_ptr, nlhs, plhs); break;
    case 2: dispatch<2>(n, m, x_ptr, y_ptr, nlhs, plhs); break;
    case 3: dispatch<3>(n, m, x_ptr, y_ptr, nlhs, plhs); break;
    default: mexErrMsgTxt("Dimension not implemented.");
    }  
}
