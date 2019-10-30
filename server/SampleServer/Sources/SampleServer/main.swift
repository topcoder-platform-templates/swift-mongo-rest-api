//
//  main.swift
//  SampleServer
//
//  Created by Alexander Volkov on 10/12/2019
//	Copyright (C) 2019 Alexander Volkov
//

import Foundation
import PerfectHTTP
import PerfectHTTPServer

// Configure the server endpoints:
var routes = Routes()
routes.addCRUD(uri: "/test", handler: Controller.handler)

#if DEBUG
print("DEVELOPMENT VERSION")
#else
print("RELEASE VERSION")
#endif

// Start server
try HTTPServer.launch(name: "localhost",
                      port: Configuration.port,
					  routes: routes,
					  responseFilters: [
						(PerfectHTTPServer.HTTPFilter.contentCompression(data: [:]), HTTPFilterPriority.high)])

