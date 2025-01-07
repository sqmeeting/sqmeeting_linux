#include "frtc_rest_engine.h"
#include <cpr/cpr.h>



void frtc_rest_engine::set_base_url(const std::string& base_url)
{
    m_base_url = base_url;
}

void frtc_rest_engine::do_request_async(HTTP_METHOD method, const std::string& uri, const std::string& body, const std::set<std::pair<std::string, std::string>>& request_params, std::function<void(int, const std::string&)> callback)
{
    cpr::Url url = cpr::Url{make_request_url(uri, request_params)};

    std::shared_ptr<cpr::Session> session = std::make_shared<cpr::Session>();
    session->SetUrl(url);
    session->SetBody(cpr::Body{body});
    session->SetTimeout(cpr::Timeout{1000 * 15});

    session->SetHeader(cpr::Header{{"user-agent", m_user_agent}});
    session->SetHeader(cpr::Header{{"accept", "application/json"}});

    auto callback_wrapper = [callback](cpr::Response r)
    {
        callback(r.status_code, r.text); 
    };

    switch(method)
    {
        case GET:
            session->GetCallback(callback_wrapper);
            break;
        case POST:
            session->PostCallback(callback_wrapper);
            break;
        case PUT:
            session->PutCallback(callback_wrapper);
            break;
        case DELETE:
            session->DeleteCallback(callback_wrapper);
            break;
        default:
            break;
    }
}

void frtc_rest_engine::do_request(HTTP_METHOD method, const std::string& uri, const std::string& body, const std::set<std::pair<std::string, std::string>>& request_params, int& status_code, std::string& response_str)
{
    cpr::Url url = cpr::Url{make_request_url(uri, request_params)};
    cpr::Session session;
    session.SetUrl(url);
    session.SetBody(cpr::Body{body});
    session.SetTimeout(cpr::Timeout{1000 * 15});

    session.SetHeader(cpr::Header{{"user-agent", m_user_agent}});
    session.SetHeader(cpr::Header{{"accept", "application/json"}});

    cpr::Response response;
    switch (method)
    {
    case GET:
        response = session.Get();
        break;
    case POST:
        response = session.Post();
        break;
    case PUT:
        response = session.Put();
        break;
    case DELETE:
        response = session.Delete();
        break;
    default:
        break;
    }
    
    if(response.status_code >= 0)
    {
        status_code = response.status_code;
        response_str = response.text;
    }
}

std::string frtc_rest_engine::make_request_url(const std::string& uri, const std::set<std::pair<std::string, std::string>>& request_params)
{
    std::string ret = "https://" + m_base_url + uri + "?";
    for(auto p : request_params)
    {
        ret += p.first + "=" + p.second + "&";
    }
    ret.erase(ret.end() - 1);
    return ret;
}
