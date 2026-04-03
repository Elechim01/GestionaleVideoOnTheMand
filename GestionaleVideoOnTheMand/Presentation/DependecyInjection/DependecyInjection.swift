//
//  DependecyInjection.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 21/03/26.
//

import Foundation

class DependencyContainer {
    
    // MARK: REPOSITORY
   private  lazy var movieRepository: MovieRepositoryProtocol = {
        return MovieRepository()
    }()
    
    private lazy var storageReposotory: StorageReposotoryProtocol = {
        return StorageRepository()
    }()
    
    private lazy var authRepository: AuthRepositoryProtocol = {
        return AuthRepository()
    }()
    
    private lazy var credentialRepository: CredentialRepositoryProtocol = {
       return CredentialRepository()
    }()
    
    private lazy var chronologyRepository: ChronologyRepositoryProtocol = {
       return ChronologyRepository()
    }()
    
    
    //MARK: USE CASE
    private lazy var deleteUseCase: DeleteMovieUseCase  = {
        return DeleteMovieUseCase(repository: movieRepository)
    }()
    
    private lazy var fetchMovieUseCase: FetchMovieUseCase = {
       return FetchMovieUseCase(movieRepository: movieRepository)
    }()
    
    private lazy var uploadMovieUseCase: UploadMovieUseCase = {
       return UploadMovieUseCase(storageRepo: storageReposotory)
    }()
    
    private lazy var getCurrentUserUseCase: GetCurrentUserUseCase = {
        return GetCurrentUserUseCase(authRepository: authRepository, credentialRepository: credentialRepository)
    }()
    
    private lazy var loginUseCase: LoginUseCase = {
       return LoginUseCase(authRepository: authRepository,credentialRepository: credentialRepository)
    }()
    
    private lazy var restoreSessionUseCase: RestoreSessionUseCase = {
        return RestoreSessionUseCase(authRepository: authRepository, credentialRepository: credentialRepository)
    }()
    
    private lazy var logoutUseCase: LogoutUseCase = {
       return LogoutUseCase(repository: authRepository)
    }()
    
    private lazy var registrationUseCase: RegistrationUseCase = {
        return RegistrationUseCase(authRepository: authRepository,credentialRepository: credentialRepository)
    }()
    
    private lazy var fetchChronologyUseCase: FetchChronologyUseCase = {
       return FetchChronologyUseCase(chronologyRepository: chronologyRepository)
    }()
    
    
    // MARK: VIEW MODEL
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
