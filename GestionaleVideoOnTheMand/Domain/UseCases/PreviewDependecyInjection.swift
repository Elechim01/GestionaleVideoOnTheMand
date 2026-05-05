//
//  PreviewDependecyInjection.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 22/03/26.
//

import Foundation

class PreviewDependecyInjection {
    
    static let shared = PreviewDependecyInjection()
    
    // MARK: REPOSITORY PROTOCOL
    private lazy var movieRepository: MovieRepositoryProtocol = {
        return MockMovieRepository()
    }()
    
    private lazy var authRepository: AuthRepositoryProtocol = {
        return AuthRepositoryMock()
    }()
    
    private lazy var credentialRepository: CredentialRepositoryProtocol = {
        return CredentialRepository()
    }()
    
    private lazy var chronologyRepository: ChronologyRepositoryProtocol = {
        return ChronologyRepositoryMock()
    }()
    
    // MARK: USE CASE
    private  lazy var deleteUseCase: DeleteMovieUseCase  = {
        return DeleteMovieUseCase(repository: movieRepository)
    }()
    
    private  lazy var fetchMovieUseCase: FetchMovieUseCase = {
        return FetchMovieUseCase(movieRepository: movieRepository)
    }()
    
    private lazy var getCurrentUserUseCase: GetCurrentUserUseCase = {
        return GetCurrentUserUseCase(authRepository: authRepository,
                                     credentialRepository: credentialRepository)
    }()
    
    private lazy var uploadMovieUseCase: UploadMovieUseCase = {
        return UploadMovieUseCase(storageRepo: MockStorageRepository())
    }()
    
    private lazy var loginUseCase: LoginUseCase = {
        return LoginUseCase(authRepository: authRepository,
                            credentialRepository: credentialRepository)
    }()
    
    private lazy var restoreSessionUseCase: RestoreSessionUseCase = {
        return RestoreSessionUseCase(authRepository: authRepository,
                                     credentialRepository: credentialRepository)
    }()
    private lazy var logoutUseCase: LogoutUseCase = {
        return LogoutUseCase(repository: authRepository)
    }()
    
    private lazy var fetchChronologyUseCase: FetchChronologyUseCase = {
        return FetchChronologyUseCase(chronologyRepository: chronologyRepository)
    }()
    
    private lazy var getRememberedCredential: GetRememberedCredentialsUseCase = {
        return GetRememberedCredentialsUseCase(repository: credentialRepository)
    }()
    
    private lazy var deleteRememberedCredential: DeleteRememberedCredentialsUseCase = {
        return DeleteRememberedCredentialsUseCase(repository: credentialRepository)
    }()
    
    private lazy var existRememberedCredentialUseCase: ExistRememberedCredentialUseCase = {
        return ExistRememberedCredentialUseCase(repository: credentialRepository)
    }()
    
    private lazy var restorePasswordUseCase: RestorePasswordUseCase = {
        return RestorePasswordUseCase(repository: authRepository)
    }()
    
    let sessionManager = SessionManager()
    
    // MARK: VIEW MODEL
    @MainActor func makeHomeViewModel() -> HomeViewModel {
        return HomeViewModel(deleteUseCase: deleteUseCase,
                             fetchMovieUseCase: fetchMovieUseCase,
                             getCurrentUserUseCase: getCurrentUserUseCase,
                             sessionManager: sessionManager)
    }
    
    @MainActor func makeLoadFilmViewModel() -> LoadFilmViewModel {
        return LoadFilmViewModel(uploadMovieUseCase: uploadMovieUseCase,
                                 sessionManager: sessionManager)
    }
    
    @MainActor func makeLoginViewModel() -> LoginViewModel {
        return LoginViewModel(loginUseCase: loginUseCase,
                              restoreSessionUseCase: restoreSessionUseCase,
                              logoutUseCase: logoutUseCase,
                              getRememberedCredentialUseCase: getRememberedCredential,
                              deleteRememberedCredentialUseCase: deleteRememberedCredential,
                              existRememberedCredentialUseCase:existRememberedCredentialUseCase,
                              restorePasswordUseCase: restorePasswordUseCase,
                              sessionManager: sessionManager)
    }
    @MainActor
    func makeChronologyViewModel() -> ChronologyViewModel {
        return ChronologyViewModel(fetchChronologyUseCase: fetchChronologyUseCase,
                                   sessionManager: sessionManager)
    }
}
