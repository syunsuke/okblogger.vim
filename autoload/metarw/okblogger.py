#! /usr/bin/env python

import pickle
import os.path
from googleapiclient.discovery import build
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request

import os
import sys
import json


#########################################################################
# deal with auth
#########################################################################

scopes = ["https://www.googleapis.com/auth/blogger"]

def get_authenticated_service(secfile, tokenfile):
    creds = None
    if os.path.exists(tokenfile):
        with open(tokenfile, 'rb') as token:
            creds = pickle.load(token)
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            flow = InstalledAppFlow.from_client_secrets_file(secfile,scopes)
            creds = flow.run_local_server(port=0)

        with open(tokenfile, 'wb') as token:
            pickle.dump(creds, token)
    return build("blogger", "v3", credentials=creds)


def main(oplist):

    #########################################################################
    # get blogger service
    #########################################################################
    service = get_authenticated_service(oplist[1], oplist[2])


    #########################################################################
    # return list of posts
    #########################################################################
    if  oplist[3] == "list":
        blog_id = oplist[4]
        post_obj = service.posts()

        blog_list = post_obj.list(blogId = blog_id).execute()

        print(json.dumps(blog_list))


    #########################################################################
    # get a post
    #########################################################################
    if  oplist[3] == "show":
        blog_id = oplist[4]
        post_id = oplist[5]
        post_obj = service.posts()

        blog_post = post_obj.get(blogId = blog_id, postId = post_id).execute()

        print(json.dumps(blog_post))


    #########################################################################
    # update a post content
    #########################################################################
    if  oplist[3] == "update":
        blog_id = oplist[4]
        post_id = oplist[5]
        content = oplist[6]

        post_body = {'content': content}

        post_obj = service.posts()

        blog_post = post_obj.patch(blogId = blog_id,
                                   postId = post_id,
                                   body = post_body).execute()


if __name__ == '__main__':
    main(sys.argv)

