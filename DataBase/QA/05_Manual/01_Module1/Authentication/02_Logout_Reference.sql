--==============================
-- LOGOUT TESTS
--==============================

-- logout non-existent user
-- expected: false

select logout_user('qa-manual-missing@qa.miacaomigo.pt');


-- logout client with active session
-- context: goncalo.pratas open session from setup
-- expected: true

select logout_user('goncalo.pratas.cstress@gmail.com');


-- logout employee with active session
-- context: 12@ open session from fixture/setup
-- expected: true

select logout_user('12@miacaomigo.pt');


-- logout again (already closed)
-- expected: false

select logout_user('12@miacaomigo.pt');