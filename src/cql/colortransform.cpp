#include "node.h"
Transform* ColorTransform::flipColorTransform(){
  Transform*ct=new ColorTransform();
  Transform*fh=DihedralTransform::flipHorizontal();
  return ct->compose(fh);
}
