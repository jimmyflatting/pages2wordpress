import Foundation

// Set the WordPress site URL
let apiUrl = "https://dev.gopeach.se/alekuriren/wp-json/wp/v2"

// Export the current Pages document as HTML
let desktopUrl = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask)[0]
Pages.setDefaultTemplateSavingPath(desktopUrl.path)
let htmlContent = exportResult

// Construct the request URL for the posts endpoint
let postUrl = URL(string: "\(apiUrl)/posts")!

// Construct the request body with the post data
var requestBody = [
    "title": Pages.document().name(),
    "content": htmlContent,
    "status": "draft"
] as [String : Any]

// Send a POST request to the posts endpoint with the authentication details and request body
var request = URLRequest(url: postUrl)
request.httpMethod = "POST"

// Set the authentication headers to use the WordPress cookie as the bearer token
let cookies = HTTPCookieStorage.shared.cookies ?? []
let cookieStrings = cookies.map { "\($0.name)=\($0.value)" }
let cookieString = cookieStrings.joined(separator: ";")
request.addValue("Bearer \(cookieString)", forHTTPHeaderField: "Authorization")
request.addValue("application/json", forHTTPHeaderField: "Content-Type")

request.httpBody = try! JSONSerialization.data(withJSONObject: requestBody)

let task = URLSession.shared.dataTask(with: request) { data, response, error in
    guard let data = data else {
        print("Error: \(error?.localizedDescription ?? "Unknown error")")
        return
    }
    guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
        print("Error: Invalid HTTP response")
        return
    }
    let responseData = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    print("New draft post created with ID \(responseData["id"]!)")
}
task.resume()
