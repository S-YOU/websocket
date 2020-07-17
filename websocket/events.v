module websocket

// All this plumbing will go awauy when we can do EventHandler<T> properly
struct MessageEventHandler {
	handler  SocketMessageFn
	handler2 SocketMessageFn2
	is_ref   bool = false
	ref      voidptr
}

struct ErrorEventHandler {
	handler  SocketErrorFn
	handler2 SocketErrorFn2
	is_ref   bool = false
	ref      voidptr
}

struct OpenEventHandler {
	handler  SocketOpenFn
	handler2 SocketOpenFn2
	is_ref   bool = false
	ref      voidptr
}

struct CloseEventHandler {
	handler  SocketCloseFn
	handler2 SocketCloseFn2
	is_ref   bool = false
	ref      voidptr
}

pub type SocketMessageFn = fn (c &Client, msg &Message)?

pub type SocketErrorFn = fn (mut c &Client, err string)?

pub type SocketOpenFn = fn (mut c &Client)?

pub type SocketCloseFn = fn (mut c &Client, code int, reason string)?

pub type SocketMessageFn2 = fn (c &Client, msg &Message, v voidptr)?

pub type SocketErrorFn2 = fn (mut c &Client, err string, v voidptr)?

pub type SocketOpenFn2 = fn (mut c &Client, v voidptr)?

pub type SocketCloseFn2 = fn (mut c &Client, code int, reason string, v voidptr)?

// on_message, register a callback on new messages
pub fn (mut ws Client) on_message(fun SocketMessageFn) {
	ws.message_callbacks << MessageEventHandler{
		handler: fun
	}
}

// on_message_ref, register a callback on new messages and provide a reference
pub fn (mut ws Client) on_message_ref(fun SocketMessageFn2, ref voidptr) {
	ws.message_callbacks << MessageEventHandler{
		handler2: fun
		ref: ref
		is_ref: true
	}
}

// on_error, register a callback on errors
pub fn (mut ws Client) on_error(fun SocketErrorFn) {
	ws.error_callbacks << ErrorEventHandler{
		handler: fun
	}
}

// on_error_ref, register a callback on errors and provida a reference
pub fn (mut ws Client) on_error_ref(fun SocketErrorFn2, ref voidptr) {
	ws.error_callbacks << ErrorEventHandler{
		handler2: fun
		ref: ref
		is_ref: true
	}
}

// on_open, register a callback on successful open
pub fn (mut ws Client) on_open(fun SocketOpenFn) {
	ws.open_callbacks << OpenEventHandler{
		handler: fun
	}
}

// on_open_ref, register a callback on successful open and provide a reference
pub fn (mut ws Client) on_open_ref(fun SocketOpenFn2, ref voidptr) {
	ws.open_callbacks << OpenEventHandler{
		handler2: fun
		ref: ref
		is_ref: true
	}
}

// on_close, register a callback on closed socket
pub fn (mut ws Client) on_close(fun SocketCloseFn) {
	ws.close_callbacks << CloseEventHandler{
		handler: fun
	}
}

// on_close_ref, register a callback on closed socket and provide a reference
pub fn (mut ws Client) on_close_ref(fun SocketCloseFn2, ref voidptr) {
	ws.close_callbacks << CloseEventHandler{
		handler2: fun
		ref: ref
		is_ref: true
	}
}

fn (mut ws Client) send_message_event(mut msg Message) ? {
	ws.logger.debug('sending on_message event')
	for ev_handler in ws.message_callbacks {
		if !ev_handler.is_ref {
			ev_handler.handler(ws, msg)
		} else {
			ev_handler.handler2(ws, msg, ev_handler.ref)
		}
	}
	return none
}

fn (mut ws Client) send_error_event(err string) ? {
	ws.logger.debug('sending on_error event')
	for ev_handler in ws.error_callbacks {
		if !ev_handler.is_ref {
			ev_handler.handler(mut ws, err)
		} else {
			ev_handler.handler2(mut ws, err, ev_handler.ref)
		}
	}
	return none
}

fn (mut ws Client) send_close_event(code int, reason string) ? {
	ws.logger.debug('sending on_close event')
	for ev_handler in ws.close_callbacks {
		if !ev_handler.is_ref {
			ev_handler.handler(mut ws, code, reason)
		} else {
			ev_handler.handler2(mut ws, code, reason, ev_handler.ref)
		}
	}
	return none
}

fn (mut ws Client) send_open_event() ? {
	ws.logger.debug('sending on_open event')
	for ev_handler in ws.open_callbacks {
		if !ev_handler.is_ref {
			ev_handler.handler(mut ws)
		} else {
			ev_handler.handler2(mut ws, ev_handler.ref)
		}
	}
	return none
}
