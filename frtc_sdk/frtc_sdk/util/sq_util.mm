#include "sq_util.h"
#include <QString>
#include <QStandardPaths>


namespace Util {

std::string SystemUtil::GetApplicationDocumentDirectory()
{
    QString documentsPath = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
    
    std::string str = documentsPath.toStdString();
    
    return str;
}
        
}

