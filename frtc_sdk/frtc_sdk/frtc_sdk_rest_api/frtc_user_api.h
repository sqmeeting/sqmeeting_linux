#ifndef FRTC_USER_API_H
#define FRTC_USER_API_H

#include "frtc_sdk_api.h"

#include <string>
#include <functional>

//typedef void (*frtc_user_api_callback)(int, const std::string&);
class frtc_user_api
{
    //let this class be a singleton
public:
    static frtc_user_api& getInstance() {
        static frtc_user_api instance;
        return instance;
    }

private:
    // Constructor
    frtc_user_api() : m_base_url(""), m_uuid("") {
    }

    frtc_user_api(const frtc_user_api&) = delete;
    frtc_user_api& operator=(const frtc_user_api&) = delete;


    // Add your member functions here

public:
    void set_base_url(const std::string& base_url);
    void set_uuid(const std::string& uuid){ m_uuid = uuid; };
    //void set_callback(PRESTAPICALLBACK callback){ m_callback = callback; };
public:
    // void sign_in(const std::string& user_name, const std::string& password);
    // void sign_in_via_token(const std::string& token);
private:
    void on_request_finished(int status_code, const std::string& response_str);
private:
    const std::string salt = "49d88eb34f77fc9e81cbdc5190c7efdc";

    std::string m_base_url;
    std::string m_uuid;

    //PRESTAPICALLBACK m_callback;

};

#endif // FRTC_USER_API_H
