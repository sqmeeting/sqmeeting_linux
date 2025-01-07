#ifndef string_util_hpp
#define string_util_hpp

#include <string>

namespace Util {
class SystemUtil {
public:
    static std::string GetApplicationDocumentDirectory();

private:
    SystemUtil() {}
    ~SystemUtil() {}
};
}

#endif /* string_util_hpp */
