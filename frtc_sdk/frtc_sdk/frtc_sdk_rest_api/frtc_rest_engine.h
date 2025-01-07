#ifndef FRTC_REST_ENGINE_H
#define FRTC_REST_ENGINE_H

#include <string>
#include <set>
#include <functional>

typedef enum _HTTP_METHOD {
    GET = 0,
    POST,
    PUT,
    DELETE
} HTTP_METHOD;

class frtc_rest_engine {

    #pragma region Singleton

public:
    static frtc_rest_engine& getInstance() {
        static frtc_rest_engine instance;
        return instance;
    }

    // Add your member functions here

private:
    frtc_rest_engine() : m_base_url(""), m_uuid(""), m_user_agent("FRTC_SDK_UNIFIED") {
        // Constructor
    }

    frtc_rest_engine(const frtc_rest_engine&) = delete;
    frtc_rest_engine& operator=(const frtc_rest_engine&) = delete;

    #pragma endregion

public:
    void set_base_url(const std::string& base_url); 
    void do_request_async(HTTP_METHOD method, const std::string& uri, const std::string& body, const std::set<std::pair<std::string, std::string>>& request_params, std::function<void(int, const std::string&)> callback);
    void do_request(HTTP_METHOD method, const std::string& uri, const std::string& body, const std::set<std::pair<std::string, std::string>>& request_params, int& status_code, std::string& response_str);

private:
    std::string make_request_url(const std::string& uri, const std::set<std::pair<std::string, std::string>>& request_params);

private:
    std::string m_base_url;
    std::string m_uuid;
    std::string m_user_agent;

};

#endif // FRTC_REST_ENGINE_H