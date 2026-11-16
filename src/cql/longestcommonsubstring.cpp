#include <vector>
using std::vector;
//void printarray(int m, int n, vector<vector<int>>arr);

int longestCommonSubstring(std::vector<int>a, std::vector<int>b, int* astart, int*bstart){
  int m=(int)(a.size());
  int n=(int)(b.size());
  if(!m|!n)return 0;
  /* lcsuff[i][j] is the longest common suffix in a[0..i]
      and b[0..j]
  */
  std::vector<std::vector<int>>lcsuff;
  lcsuff.resize(m);
  for(int i=0;i<m;++i) lcsuff[i].resize(n);

  for(int i=0;i<m;++i)for(int j=0;j<n;++j)lcsuff[i][j]=-1000;
  for(int j=0;j<n;++j) lcsuff[0][j]= a[0]==b[j]?1:0;
  for(int i=0;i<m;++i) lcsuff[i][0]= a[i]==b[0]?1:0;
  for(int i=1;i<m;++i)
    for(int j=1;j<n;++j)
      if(a[i]==b[j])
	lcsuff[i][j]=lcsuff[i-1][j-1]+1;
      else
	lcsuff[i][j]=0;
  int longest=-1;
  int longi=-1;
  int longj=-1;
  for(int i=0;i<m;++i)
    for(int j=0;j<n;++j){
      int x=lcsuff[i][j];
      if(x>longest){
	longest=x;
	longi=i;
	longj=j;
      }
    }
  *astart=longi-longest+1;
  *bstart=longj-longest+1;
  return longest;
}
      
// void printarray(int m, int n, vector<vector<int>>arr){
//   for(int i=0;i<m;i++)
//     for(int j=0;j<m;j++)
//       printf("i: %d j: %d arr[i][j]: %d\n",i,j,arr[i][j]);
// }
	  
