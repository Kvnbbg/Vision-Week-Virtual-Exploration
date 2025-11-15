<?php

namespace App\Middleware;

use App\Security\AuthorizationException;
use App\Security\FirebaseTokenValidator;
use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;
use Psr\Http\Server\MiddlewareInterface;
use Psr\Http\Server\RequestHandlerInterface;
use Slim\Exception\HttpUnauthorizedException;

class FirebaseAuthMiddleware implements MiddlewareInterface
{
    public function __construct(private readonly FirebaseTokenValidator $validator)
    {
    }

    public function process(ServerRequestInterface $request, RequestHandlerInterface $handler): ResponseInterface
    {
        try {
            $claims = $this->validator->assertValidAuthorization($request->getHeaderLine('Authorization'));
        } catch (AuthorizationException $exception) {
            throw new HttpUnauthorizedException($request, $exception->getMessage(), $exception);
        }

        return $handler->handle($request->withAttribute('firebaseClaims', $claims));
    }
}
