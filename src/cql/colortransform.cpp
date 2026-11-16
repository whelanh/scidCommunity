/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Original authors: scidvspc (https://sourceforge.net/projects/scidvspc/)
 */
#include "node.h"
Transform* ColorTransform::flipColorTransform(){
  Transform*ct=new ColorTransform();
  Transform*fh=DihedralTransform::flipHorizontal();
  return ct->compose(fh);
}
