import os
import httpx
from dotenv import load_dotenv
import email_client

from fastapi import FastAPI, Request, HTTPException
from fastapi.templating import Jinja2Templates
from fastapi.staticfiles import StaticFiles
from fastapi import FastAPI, Request, Form

from starlette.middleware.trustedhost import TrustedHostMiddleware
from uvicorn.middleware.proxy_headers import ProxyHeadersMiddleware
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded

load_dotenv()

limiter = Limiter(key_func=get_remote_address)
app = FastAPI()
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

app.add_middleware(ProxyHeadersMiddleware, trusted_hosts="*")
app.add_middleware(TrustedHostMiddleware, allowed_hosts=["app-companyname.azurewebsites.net",
                                                         "localhost",
                                                         "www.companyname.com"])

email_client.api_key = os.getenv("EMAIL_API_KEY")
turnstile_secret = os.getenv("TURNSTILE_SECRET_KEY")

TURNSTILE_VERIFY_URL = "https://challenges.cloudflare.com/turnstile/v0/siteverify"

app.mount("/static", StaticFiles(directory="static"), name="static")
templates = Jinja2Templates(directory="templates")

@app.get("/")
def home(request: Request):
    return templates.TemplateResponse(request, "home.html")

@app.get("/about")
def about(request: Request):
    return templates.TemplateResponse(request, "about.html")

@app.post("/contact")
@limiter.limit("3/hour")
def contact_submit(
    request: Request,
    name: str = Form(...),
    email: str = Form(...),
    message: str = Form(...),
    cf_turnstile_response: str = Form(..., alias="cf-turnstile-response")
):
    verify = httpx.post(TURNSTILE_VERIFY_URL, data={
        "secret": turnstile_secret,
        "response": cf_turnstile_response
    })
    if not verify.json().get("success"):
        raise HTTPException(status_code=400, detail="CAPTCHA verification failed")

    params: email_client.Emails.SendParams = {
        "from": "info@companyname.com",
        "to": ["info@companyname.com"],
        "subject": f"New enquiry from {name}",
        "reply_to": email,
        "html": f"<p><strong>Name:</strong> {name}</p><p><strong>Email:</strong> {email}</p><p><strong>Message:</strong></p><p>{message}</p>"
    }
    email_client.Emails.send(params)
    return templates.TemplateResponse(request, "contact.html")
