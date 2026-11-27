
let router_dictionary = {} ;

router_dictionary[ 'dns-query' ] = 'https://cloudflare-dns.com/dns-query' ;
router_dictionary[ 'ubuntu-security' ] = 'https://security.ubuntu.com/ubuntu' ;
router_dictionary[ 'ubuntu-nginx' ] = 'https://nginx.org/packages/ubuntu' ;
router_dictionary[ 'ubuntu-docker' ] = 'https://download.docker.com/linux/ubuntu' ;
router_dictionary[ 'ubuntu' ] = 'https://archive.ubuntu.com/ubuntu' ;
router_dictionary[ 'debian-security' ] = 'https://security.debian.org/debian-security' ;
router_dictionary[ 'debian-nginx' ] = 'https://nginx.org/packages/debian' ;
router_dictionary[ 'debian-docker' ] = 'https://download.docker.com/linux/debian' ;
router_dictionary[ 'debian' ] = 'https://deb.debian.org/debian' ;
router_dictionary[ 'docker' ] = 'https://registry-1.docker.io' ;
router_dictionary[ 'docker-auth' ] = 'https://auth.docker.io' ;
router_dictionary[ 'npmjs' ] = 'https://registry.npmjs.org' ;
router_dictionary[ 'wazuh' ] = 'https://packages.wazuh.com/4.x/apt' ;

let worker_banner_template = '' ;
for( const route_name of Object.keys( router_dictionary ) ) {
	if ( route_name == 'docker' ) {
		worker_banner_template = worker_banner_template + route_name + ' : #URL#/\n' ; 
	} else {
		worker_banner_template = worker_banner_template + route_name + ' : #URL#/' + route_name + '\n' ; 
	}
}

function print_worker_banner( cloudflare_worker_url , worker_banner_template ) {
	worker_banner_template = worker_banner_template.replaceAll( '#URL#' , cloudflare_worker_url );
	return worker_banner_template ;
}

function sort_length_descending( list_name ) {
	return list_name.sort( ( a , b ) => { return b.length - a.length });
}

router_dictionary[ 'v2' ] = router_dictionary[ 'docker' ];
delete router_dictionary[ 'docker' ];

const route_names_list = sort_length_descending( Object.keys( router_dictionary ) );

async function http_response( target_url , request_headers , follow_redirect , request_obj ) {
	const request_method = request_obj.method ;
	return await fetch(
		new Request( target_url , {
			headers: request_headers ,
			redirect: ( follow_redirect ) ? 'follow' : 'manual' ,
			cache: 'no-store' ,
			method: request_method ,
			body: ( request_method == 'GET' || request_method == 'HEAD' ) ? undefined : request_obj.body ,
		})
	); 
}

export default {
	async fetch( request ) {
		const redirect_header_name = 'Location' ;
		const auth_header_names_list = [ 'authorization' , 'cookie' ];
		const docker_auth_header_name = 'WWW-Authenticate' ;
		const client_request_headers = new Headers( request.headers );
		client_request_headers.delete( 'Host' );
		const client_request_url = new URL( request.url ) ;
		const client_request_url_query = client_request_url.search ;
		const cloudflare_worker_url = client_request_url.origin ;
		let client_request_url_path = client_request_url.pathname ;
		if ( client_request_url_path == '/' ) {
			return new Response( print_worker_banner( cloudflare_worker_url , worker_banner_template ) , {
				status: 200 ,
			});
		}
		let client_request_validation = false ;
		let route_name ;
		let route_url ;
		for ( const this_route_name of route_names_list ) {
			const this_route_url_path_prefix = '/' + this_route_name ;
			if ( client_request_url_path.startsWith( this_route_url_path_prefix ) ) {
				client_request_validation = true ;
				route_name = this_route_name ;
				route_url = router_dictionary[ route_name ] ;
				if ( route_name != 'v2' ) {
					client_request_url_path = client_request_url_path.slice( this_route_url_path_prefix.length ) ;
				}
				break
			}
		}
		if ( client_request_validation == false ) {
			return new Response( 'Bad Request' , {
				status: 400 ,
			});
		}
		const target_url = new URL( route_url + client_request_url_path + client_request_url_query );
		if ( route_name != 'v2' ) {
			return await http_response( target_url , client_request_headers , true , request );
		}
		let target_response = await http_response( target_url , client_request_headers , false , request );
		if ( target_response.status == 401 ) {
			if ( target_response.headers.has( docker_auth_header_name ) ) {
				let target_response_headers_auth_proxied = new Headers( target_response.headers );
				let target_response_docker_auth_header = target_response_headers_auth_proxied.get( docker_auth_header_name );
				if ( target_response_docker_auth_header.startsWith( 'Bearer' ) ) {
					const docker_auth_realm_official_key_value = 'realm="' + router_dictionary[ 'docker-auth' ] + '/token"' ;
					const docker_auth_realm_proxied_key_value = 'realm="' + cloudflare_worker_url + '/docker-auth/token"' ;
					const target_response_docker_auth_header_proxied = target_response_docker_auth_header.replace(
						docker_auth_realm_official_key_value ,
						docker_auth_realm_proxied_key_value
					);
					target_response_headers_auth_proxied.set( docker_auth_header_name , target_response_docker_auth_header_proxied );
					target_response = new Response(
						target_response.body , {
							status: target_response.status ,
							statusText: target_response.statusText ,
							headers: target_response_headers_auth_proxied ,
						}
					);
				}
			}
		}
		if ( target_response.status == 307 ) {
			if ( target_response.headers.has( redirect_header_name ) ) {
				const target_url_redirected = target_response.headers.get( redirect_header_name );
				let target_request_headers_auth_removed = new Headers( client_request_headers );
				for ( const this_auth_header_name of auth_header_names_list ) {
					if ( target_request_headers_auth_removed.has( this_auth_header_name ) ) {
						target_request_headers_auth_removed.delete( this_auth_header_name );
					}
				}
				target_response = await http_response( target_url_redirected , target_request_headers_auth_removed , false , request );
			}
		}
		return target_response ;
	}
};













