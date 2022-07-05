import requests
import json
from collections import defaultdict

def get_posts_data(): 
    response_posts = requests.get("http://jsonplaceholder.typicode.com/posts")
    return json.loads(response_posts.text)

def get_comment_data():
    response_comments = requests.get("http://jsonplaceholder.typicode.com/comments")
    return json.loads(response_comments.text)

def average_comments_per_users_post() -> dict[int, float]:
    posts = get_posts_data()
    comments = get_comment_data()

    user_posts = defaultdict(list)
    for post in posts:
        user_posts[post['userId']].append(post['id'])

    post_comment_counts = defaultdict(int)
    for comment in comments:
        post_comment_counts[comment['postId']] += 1

    average_comments_per_users_post: dict[int, float] = {}
    for user, posts in user_posts.items():
        all_comments = 0
        for post in posts:
            all_comments += post_comment_counts[post]
        average_comments = all_comments / len(posts)
        average_comments_per_users_post[user] = average_comments

    return average_comments_per_users_post

print(average_comments_per_users_post())
