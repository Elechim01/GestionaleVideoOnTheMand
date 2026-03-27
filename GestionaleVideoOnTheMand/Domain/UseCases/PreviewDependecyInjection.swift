//
//  PreviewDependecyInjection.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 22/03/26.
//

import Foundation

class PreviewDependecyInjection {
    
    static let shared = PreviewDependecyInjection()
    
   private lazy var movieRepository: MovieRepositoryProtocol = {
        return MockMovieRepository()
    }()
    
   private  lazy var deleteUseCase: DeleteMovieUseCase  = {
        return DeleteMovieUseCase(repository: movieRepository)
    }()
    
   private  lazy var fetchMovieUseCase: FetchMovieUseCase = {
       return FetchMovieUseCase(movieRepository: movieRepository)
    }()
    
    private lazy var getCurrentUserUseCase: GetCurrentUserUseCase = {
        return GetCurrentUserUseCase(authRepository: AuthRepositoryMock())
    }()
    
    private lazy var uploadMovieUseCase: UploadMovieUseCase = {
        return UploadMovieUseCase(storageRepo: MockStorageRepository())
    }()
    
    private lazy var authRepository: AuthRepositoryProtocol = {
       return AuthRepositoryMock()
    }()
    
    private lazy var loginUseCase: LoginUseCase = {
       return LoginUseCase(authRepository: authRepository)
    }()
    
    private lazy var restoreSessionUseCase: RestoreSessionUseCase = {
       return RestoreSessionUseCase(authRepository: authRepository)
    }()
    private lazy var logoutUseCase: LogoutUseCase = {
       return LogoutUseCase(repository: authRepository)
    }()
    
    @MainActor func makeHomeViewModel() -> HomeViewModel {
        return HomeViewModel(deleteUseCase: deleteUseCase,
                         fetchMovieUseCase: fetchMovieUseCase,
                         getCurrentUserUseCase: getCurrentUserUseCase)
    }
    
    @MainActor func makeLoadFilmHomeViewModel() -> LoadFilmHomeViewModel {
        return LoadFilmHomeViewModel(uploadMovieUseCase: uploadMovieUseCase)
    }
    
    @MainActor func makeLoginHomeViewModel() -> LoginHomeViewModel {
        return LoginHomeViewModel(loginUseCase: loginUseCase,
                              restoreSessionUseCase: restoreSessionUseCase,
                              logoutUseCase: logoutUseCase)
    }
}
