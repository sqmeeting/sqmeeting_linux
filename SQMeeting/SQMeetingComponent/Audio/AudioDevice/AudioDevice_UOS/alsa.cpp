#include "alsa.h"

Alsa::Alsa()
{
    mixer = NULL;
    cap_elem = NULL;
    sctrlstr = "Capture";
    printf("Alsa::Alsa()");
    setCapVal();
}

Alsa::~Alsa()
{
    closeMixer();
}

/**
 * @brief Alsa::initializeMixer - Initialize the mixer
 * @param cardName - card name [Ex: "hw:1"]
 * @return -ve if failure, 0 if success
 */
int Alsa::initializeMixer(QString cardName) {

    int err;
    QByteArray ba = cardName.toLocal8Bit(); // QString to QBytearray
    const char *card = ba.data(); // QBytearray to const char *

    static struct snd_mixer_selem_regopt smixer_options;

    memset(&smixer_options, 0, sizeof(smixer_options));
    smixer_options.ver = 1;
    smixer_options.abstract = SND_MIXER_SABSTRACT_NONE;
    smixer_options.device = card; // Card "Ex: hw:1"

    err = snd_mixer_open(&mixer, 0);
    if (err < 0) {
        qDebug()<<"cannot open mixer:"<< err;
        return err;
    }

    err = snd_mixer_selem_register(mixer, &smixer_options, NULL);
    if (err < 0) {
        qDebug()<<"cannot register mixer:"<< err;
        return err;
    }

    err = snd_mixer_load(mixer);
    if (err < 0) {
        qDebug()<<"cannot load mixer controls:"<< err;
        return err;
    }

    err = snd_mixer_attach(mixer, card);
    if (err<0)
    {
        qDebug()<<"Failed to attach:"<<err;
        return err;
    }

    for (cap_elem = snd_mixer_first_elem(mixer); cap_elem; cap_elem = snd_mixer_elem_next(cap_elem))
    {
        qDebug() << "snd_mixer_selem_get_name is " << snd_mixer_selem_get_name (cap_elem);
        if ((strcmp (snd_mixer_selem_get_name (cap_elem), "Capture") == 0) ||
               (strcmp (snd_mixer_selem_get_name (cap_elem), "Mic") == 0)) {
                    qDebug() << "snd_mixer_selem_get_name is " << snd_mixer_selem_get_name (cap_elem);
                     break;
               }
    }

    return 0;
}

/**
 * @brief Alsa::setAlsaVolume - set volume in the camera
 * @param volume - volume to set
 * @return 0 if success , -ve if failure
 */
int Alsa::setAlsaVolume(long volume)
{
    int err;
    if (mixer == NULL) {
        return -1;
    }
    if (cap_elem == NULL) {
        return -1;
    }

    long min = 0, max = 0;
    err = snd_mixer_selem_get_capture_volume_range(cap_elem, &min, &max); // get min, max volume range
    if (err<0)
    {
       qDebug()<<"Failed to get volume range:"<<err;
       return err;
    }

    err = snd_mixer_selem_set_capture_volume_all(cap_elem, volume*max/100); // set volume
    if (err<0)
    {
       qDebug()<<"Failed to set capture volume:"<<err;
       return err;
    }
    else
    {
        qDebug() <<"set volume success";
    }
    return 0;
}

/**
 * @brief Alsa::setAlsaMute - Make camera audio as mute
 * @param mute [ true - mute enable , false - mute disable ]
 * @return 0 if success, -ve if failure
 */
int Alsa::setAlsaMute(bool mute)
{
    int err;
    if (mixer == NULL) {
        return -1;
    }

    if (cap_elem == NULL) {
        return -1;
    }

    if (snd_mixer_selem_has_capture_switch(cap_elem)) {
        if (mute) {
            err=snd_mixer_selem_set_capture_switch_all(cap_elem, 0);
        } else {
            err=snd_mixer_selem_set_capture_switch_all(cap_elem, 1);
        }
        if (err<0)
        {
            qDebug()<<"Failed to set capture switch_all:"<<err;
            return err;
        }
    }
    return 0;
}

/**
 * @brief Alsa::getMuteStatus - Get the status of mute in audio device
 * @return mute value[0/1] or -1 if failure
 */
int Alsa::getMuteStatus()
{
    int err;
    snd_mixer_elem_t *elem;

    if (mixer == NULL) {
        return -1;
    }


    if (cap_elem == NULL) {
        return -1;
    }

    int value;
    err = snd_mixer_selem_get_capture_switch(cap_elem, SND_MIXER_SCHN_FRONT_LEFT, &value);
    if (err<0)
    {
        qDebug()<<"Failed to get capture mute status:"<<err;
        return err;
    }

    return value;
}

/**
 * @brief Alsa::getAlsaVolume - get volume from camera
 * @param min - pointer to store min value
 * @param max - pointer to store max value
 * @return current volume
 */
int Alsa::getAlsaVolume(long *min, long *max)
{
    int err;
    if (mixer == NULL) {
        return -1;
    }

    if (cap_elem == NULL) {
        return -1;
    }

    err = snd_mixer_selem_get_capture_volume_range(cap_elem, min, max);
    if (err<0)
    {
       qDebug()<<"Failed to get volume range:"<<err;
       return err;
    }

    long value;
    err=snd_mixer_selem_get_capture_volume(cap_elem, SND_MIXER_SCHN_FRONT_LEFT, &value);

    if (err<0)
    {
        qDebug()<<"1-Failed to get capture volume:"<<err;
        return err;
    }

    return value;
}

void Alsa::setCapVal()
{
    long volMin, volMax, leftVal, rightVal;
       volMin = 0;  //声音范围
       volMax = 0;
       leftVal = 0;  //左右声道音量
       rightVal = 0;
       int err;
       static snd_mixer_t *handle = NULL;
       snd_mixer_elem_t *elem;
       snd_mixer_selem_id_t *sid;
       snd_mixer_selem_id_alloca(&sid);


       //打开混音器设备
       if ((err = snd_mixer_open(&handle, 0)) < 0) {
           printf("snd_mixer_open Err\n");
           return ;
       }

       snd_mixer_attach(handle, "default");
       snd_mixer_selem_register(handle, NULL, NULL);
       snd_mixer_load(handle);
       //循环找到自己想要的element
       elem = snd_mixer_first_elem(handle);
       while(elem)
       {
           //比较element名字是否是我们想要设置的选项
           printf("The element name is %s\n", snd_mixer_selem_get_name (elem));
           if ( strcmp( sctrlstr, snd_mixer_selem_get_name (elem)) == 0)
           {
               printf( "elem name : %s\n", snd_mixer_selem_get_name (elem) );
               break;
           }
           //如果不是就继续寻找下一个
           elem = snd_mixer_elem_next(elem);
       }

       if (!elem) {
           printf("snd_mixer_find_selem Err\n");
           snd_mixer_close(handle);
           handle = NULL;
           return ;
       }

       //输出elem的名字
       printf( "elem name : %s\n", snd_mixer_selem_get_name (elem) );

       snd_mixer_selem_get_capture_volume_range(elem, &volMin, &volMax);
       printf("音量范围: %ld -- %ld\n", volMin, volMax);

      // setAlsaVolume(50);

       err = snd_mixer_selem_set_capture_volume_all(elem, 20*volMax/100); // set volume
       if (err<0)
       {
          qDebug()<<"Failed to set capture volume:"<<err;

       }
       else
       {
           qDebug() <<"set volume success";
       }

       snd_mixer_handle_events(handle);
       snd_mixer_selem_get_playback_volume(elem, SND_MIXER_SCHN_FRONT_LEFT, &leftVal);
       snd_mixer_selem_get_playback_volume(elem, SND_MIXER_SCHN_FRONT_RIGHT, &rightVal);
       printf("当前音量: leftVal = %ld, rightVal = %ld\n", leftVal, rightVal);


       //判断是不是单声道
       if ( snd_mixer_selem_is_playback_mono( elem) )
       {
           //单声道
           snd_mixer_selem_set_playback_volume(elem,SND_MIXER_SCHN_FRONT_LEFT, 45);
           printf("单声道: 45\n");
       }
       else
       {
           //左音量
           snd_mixer_selem_set_playback_volume(elem,SND_MIXER_SCHN_FRONT_LEFT, 45);
           //右音量
           snd_mixer_selem_set_playback_volume(elem,SND_MIXER_SCHN_FRONT_RIGHT, 67);
           printf("双声道: 45,  67\n");
       }

       //关闭混音器设备
       snd_mixer_close(handle);
       handle = NULL;
}

/**
 * @brief Alsa::closeMixer
 * @return negative on failure, 0 on success
 */
int Alsa::closeMixer() {
    int err;
    if (mixer) {
        err=snd_mixer_close(mixer);
        if (err<0)
        {
           qDebug()<<"Failed to close mixer:"<<err;
           return err;
        }
    }
    mixer = NULL;
    return 0;
}
