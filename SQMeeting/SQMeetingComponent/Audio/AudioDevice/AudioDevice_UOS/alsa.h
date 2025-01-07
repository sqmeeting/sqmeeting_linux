#ifndef ALSA_H
#define ALSA_H

#include <QDebug>
#include <QObject>

#include <alsa/asoundlib.h>
#include <alsa/mixer.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/asoundlib.h>

class Alsa: public QObject
{
private:
    snd_mixer_t *mixer;
    snd_mixer_elem_t *cap_elem;
    char *sctrlstr;

public:
    Alsa();
    ~Alsa();

    int initializeMixer(QString cardName);
    int closeMixer();
    void setCapVal();


public slots:
    int setAlsaVolume(long volume);
    int getAlsaVolume(long *min, long *max);
    int setAlsaMute(bool mute);
    int getMuteStatus();
};

#endif // ALSA_H
