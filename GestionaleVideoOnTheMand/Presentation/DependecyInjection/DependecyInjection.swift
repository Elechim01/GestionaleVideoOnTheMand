//
//  DependecyInjection.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 21/03/26.
//

import Foundation

class DependencyContainer {
    
   private  lazy var movieRepository: MovieRepositoryProtocol = {
        return MovieRepository()
    }()
    
    private lazy var deleteUseCase: DeleteMovieUseCase  = {
        return DeleteMovieUseCase(repository: movieRepository)
    }()
    
    private lazy var fetchMovieUseCase: FetchMovieUseCase = {
       return FetchMovieUseCase(movieRepository: movieRepository)
    }()
    
    private lazy var storageReposotory: StorageReposotoryProtocol = {
        return StorageRepository()
    }()
    
    private lazy var uploadMovieUseCase: UploadMovieUseCase = {
       return UploadMovieUseCase(storageRepo: storageReposotory)
    }()
    
    private lazy var authRepository: AuthRepositoryProtocol = {
        return AuthRepository()
    }()
    
    private lazy var getCurrentUserUseCase: GetCurrentUserUseCase = {
        return GetCurrentUserUseCase(authRepository: authRepository)
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
    
    private lazy var registrationUseCase: RegistrationUseCase = {
        return RegistrationUseCase(repository: authRepository)
    }()
    
    @MainActor func makeHomeViewModel() -> HomeViewModel {
        return HomeViewModel(deleteUseCase: deleteUseCase,
                         fetchMovieUseCase: fetchMovieUseCase,
                         getCurrentUserUseCase: getCurrentUserUseCase)
    }
    
    @MainActor func makeLoadHomeViewModel () -> LoadFilmHomeViewModel {
        return LoadFilmHomeViewModel(uploadMovieUseCase: uploadMovieUseCase)
    }
    
    @MainActor func makeLoginHomeViewModel() -> LoginHomeViewModel {
        return LoginHomeViewModel(loginUseCase: loginUseCase,
                              restoreSessionUseCase: restoreSessionUseCase,
                              logoutUseCase: logoutUseCase)
    }
    
    @MainActor func makeRegistrationHomeViewModel() -> RegistrationHomeViewModel {
        return RegistrationHomeViewModel(registrationUseCase: registrationUseCase)
    }
    
}
