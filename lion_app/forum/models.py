from django.db import models

# Create your models here.
class Topic(models.Model):
    owner = models.ForeignKey('auth.User', related_name='topics', on_delete=models.CASCADE)
    admin = models.ForeignKey('auth.User', related_name='admin_topics', on_delete=models.CASCADE)
    common= models.ForeignKey('auth.User', related_name='common_topics', on_delete=models.CASCADE)

class Post(models.Model):
    title = models.CharField(max_length=100)
    body = models.TextField()
    author = models.ForeignKey('auth.User', related_name='posts', on_delete=models.CASCADE)
    topic = models.ForeignKey(Topic, related_name='posts', on_delete=models.CASCADE)