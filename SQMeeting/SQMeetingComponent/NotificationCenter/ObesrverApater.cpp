#include "ObesrverApater.h"

ObesrverApaterFactory* ObesrverApaterFactory::instance = NULL;

ObesrverApater::ObesrverApater(QObject *parent) : QObject(parent) {

}

ObesrverApaterFactory *ObesrverApaterFactory::getInstance() {
    if (instance == NULL) {
        instance = new ObesrverApaterFactory();
    }
    return instance;
}

void ObesrverApaterFactory::realese() {
    if (instance != NULL) {
        delete instance;
        instance = NULL;
    }
}

ObesrverApater *ObesrverApaterFactory::createObesrverApater() {
    return new ObesrverApater();
}
