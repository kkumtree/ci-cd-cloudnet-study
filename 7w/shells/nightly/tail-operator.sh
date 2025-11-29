#!/bin/bash

helm upgrade \
	  --install \
		  tailscale-operator \
			  tailscale/tailscale-operator \
				  --namespace=tailscale \
					  --create-namespace \
						  --set-string oauth.clientId="$TAIL_OAUTH_CLIENT_ID" \
							  --set-string oauth.clientSecret="$TAIL_OAUTH_CLIENT_SECRET" \
								  --wait

