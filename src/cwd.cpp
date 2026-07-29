#include <Rcpp.h>
#include <algorithm>
#include <vector>

using namespace Rcpp;

// [[Rcpp::export]]
List cwd_deficit_cpp(
    NumericVector wbal,
    IntegerVector doy,
    double thresh_drop,
    Nullable<int> doy_reset = R_NilValue) {
  const int n = wbal.size();
  NumericVector iinst_out(n, NA_REAL);
  NumericVector dday_out(n, NA_REAL);
  NumericVector deficit_out(n, 0.0);

  std::vector<int> starts, lengths, instances, end_indices, max_indices;
  std::vector<double> maxima;
  int idx = 0;
  int instance = 1;
  int idx_max_deficit = 0;
  int iidx_drop = 0;
  const bool reset_enabled = doy_reset.isNotNull();
  const int reset_day = reset_enabled ? as<int>(doy_reset) : NA_INTEGER;

  while (idx <= n - 1) {
    ++idx;
    if (idx > n) break;
    if (wbal[idx - 1] < 0) {
      int dday = 0;
      double deficit = 0.0;
      double max_deficit = 0.0;
      int iidx = idx;
      bool found_dropday = false;

      // Include the final observation. The former `iidx <= n - 1` bound left
      // the last day's deficit at its initialized value of zero whenever an
      // event continued through the end of the input.
      while (iidx <= n && deficit >= 0.0) {
        ++dday;
        deficit -= wbal[iidx - 1];

        if (deficit < 0.0) {
          iidx_drop = iidx + 1;
          found_dropday = true;
          break;
        }
        if (deficit > max_deficit) {
          max_deficit = deficit;
          idx_max_deficit = iidx;
          found_dropday = false;
        }
        if (deficit < max_deficit * thresh_drop && !found_dropday) {
          iidx_drop = iidx;
          found_dropday = true;
        }

        if (!found_dropday) {
          iinst_out[iidx - 1] = instance;
          dday_out[iidx - 1] = dday;
          iidx_drop = iidx;
        }
        deficit_out[iidx - 1] = deficit;

        if (reset_enabled && doy[iidx - 1] == reset_day) {
          if (!found_dropday) iidx_drop = iidx + 1;
          break;
        }
        ++iidx;
      }

      starts.push_back(idx);
      lengths.push_back(iidx_drop - idx);
      instances.push_back(instance);
      end_indices.push_back(iidx_drop - 1);
      maxima.push_back(max_deficit);
      max_indices.push_back(idx_max_deficit);
      ++instance;
      idx = iidx;
    }
  }

  DataFrame events = DataFrame::create(
    _["idx_start"] = starts,
    _["len"] = lengths,
    _["iinst"] = instances,
    _["date_end_idx"] = end_indices,
    _["max_deficit"] = maxima,
    _["idx_max_deficit"] = max_indices
  );
  return List::create(
    _["iinst"] = iinst_out,
    _["dday"] = dday_out,
    _["deficit"] = deficit_out,
    _["events"] = events
  );
}

// [[Rcpp::export]]
List cwd_surplus_cpp(NumericVector wbal, IntegerVector annual_max_indices) {
  const int n = wbal.size();
  NumericVector iinst_out(n, NA_REAL);
  NumericVector dday_out(n, NA_REAL);
  NumericVector surplus_out(n, 0.0);
  std::vector<int> annual_indices = as<std::vector<int> >(annual_max_indices);
  std::sort(annual_indices.begin(), annual_indices.end());

  std::vector<int> starts, lengths, instances, ends, max_indices;
  std::vector<double> maxima;
  int idx = 0;
  int instance = 1;
  int idx_max_surplus = 0;
  int idx_end = 0;

  while (idx <= n - 1) {
    ++idx;
    if (idx > n) break;
    if (wbal[idx - 1] > 0) {
      int dday = 0;
      double surplus = 0.0;
      double max_surplus = 0.0;
      int iidx = idx;
      while (iidx <= n - 1 && surplus >= 0.0) {
        ++dday;
        surplus += wbal[iidx - 1];
        if (surplus < 0.0) {
          idx_end = iidx;
          break;
        }
        if (surplus > max_surplus) {
          max_surplus = surplus;
          idx_max_surplus = iidx;
        }
        iinst_out[iidx - 1] = instance;
        dday_out[iidx - 1] = dday;
        surplus_out[iidx - 1] = surplus;

        // Equivalent to filtering annual maxima at or before iidx, selecting
        // the last one, and stopping when its maximum-deficit day is reached.
        std::vector<int>::const_iterator upper =
          std::upper_bound(annual_indices.begin(), annual_indices.end(), iidx);
        if (upper != annual_indices.begin()) {
          --upper;
          if (iidx == *upper) {
            idx_end = iidx;
            break;
          }
        }
        ++iidx;
      }

      starts.push_back(idx);
      lengths.push_back(idx_end - idx);
      instances.push_back(instance);
      ends.push_back(idx_end);
      maxima.push_back(max_surplus);
      max_indices.push_back(idx_max_surplus);
      ++instance;
      idx = iidx;
    }
  }

  DataFrame events = DataFrame::create(
    _["idx_start"] = starts,
    _["len"] = lengths,
    _["iinst"] = instances,
    _["idx_end"] = ends,
    _["max_surplus"] = maxima,
    _["idx_max_surplus"] = max_indices
  );
  return List::create(
    _["iinst_surplus"] = iinst_out,
    _["dday_surplus"] = dday_out,
    _["surplus"] = surplus_out,
    _["events"] = events
  );
}
