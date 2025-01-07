#include "frtc_user_api.h"
#include "frtc_rest_engine.h"

#include <set>
#include "sha1.hpp"


void frtc_user_api::set_base_url(const std::string& base_url)
{
    m_base_url = base_url;
    frtc_rest_engine::getInstance().set_base_url(base_url);
}

void frtc_user_api::sign_in(const std::string& user_name, const std::string& password)
{
    std::function<void(int, const std::string&)> cb = std::bind(&frtc_user_api::on_request_finished, this, std::placeholders::_1, std::placeholders::_2);
    SHA1 sha1;
    sha1.update(password + salt);
    std::string hash = sha1.final();
    frtc_rest_engine::getInstance().do_request_async(
        POST, 
        "/api/v1/user/sign_in", 
        "{ \"username\":\"" + user_name + "\", \"secret\":\"" + hash + "\"}", 
        {{"client_id", m_uuid}}, 
        cb);
}

void frtc_user_api::sign_in_via_token(const std::string& token)
{
    std::function<void(int, const std::string&)> cb = std::bind(&frtc_user_api::on_request_finished, this, std::placeholders::_1, std::placeholders::_2);
    frtc_rest_engine::getInstance().do_request_async(
        POST, 
        "/api/v1/user/info", 
        "", 
        {{"client_id", m_uuid},{"token", token}}, 
        cb);
}

void frtc_user_api::on_request_finished(int status_code, const std::string& response_str)
{
    if(m_callback)
    {
        m_callback(status_code, response_str.c_str());
    }
}