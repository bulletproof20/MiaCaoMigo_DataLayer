--==============================
-- LOGOUT TESTS
--==============================

-- logout non-existent user
-- expected: false

select svc_auth_logout('qa-manual-missing@qa.miacaomigo.pt');


-- logout client with active session
-- context: goncalo.pratas open session from setup
-- expected: true

select svc_auth_logout('goncalo.pratas.cstress@gmail.com');


-- logout employee with active session
-- context: 12@ open session from fixture/setup
-- expected: true

select svc_auth_logout('12@miacaomigo.pt');


-- logout again (already closed)
-- expected: false

select svc_auth_logout('2@miacaomigo.pt');



select svc_auth_logout('goncalo.rego.dev@gmail.com');