import requests
import time
import random
from faker import Faker
from abc import ABC, abstractmethod


class APIHandler(ABC):
    urls = {
        "topic": "/forum/topic/",
        "post": "/forum/post/",
    }

    class Meta:
        host = "http://localhost:8888"
        url = ""
        username = "admin"
        password = "admin"

    def __init__(self, host: str = "http://localhost:8000"):
        self.host = hasattr(self.Meta, "host") and self.Meta.host or host
        self.url = hasattr(self.Meta, "url") and self.Meta.url or ""
        self.username = hasattr(self.Meta, "username") and self.Meta.username or "admin"
        self.password = hasattr(self.Meta, "password") and self.Meta.password or "admin"
        self._login()

    def _login(self):
        res = requests.post(
            self.host + "/api/token/",
            data={"username": self.username, "password": self.password},
        )
        data = res.json()
        self.jwt = data["access"]

    def api_call(self, method: str, url: str, data: dict = None):
        request = {
            "url": url,
            "data": data,
            "headers": {"Authorization": f"Bearer {self.jwt}"},
        }
        if method == "get":
            res = requests.get(**request)
        elif method == "post":
            res = requests.post(**request)
        elif method == "put":
            res = requests.put(**request)
        elif method == "delete":
            res = requests.delete(**request)
        else:
            raise Exception
        return res

    def get_url(self, pk: int = None) -> str:
        root_url = f"{self.host}{self.url}"
        if pk is not None:
            return f"{root_url}{pk}"
        return root_url

    def get_pk(self, model: str = None) -> int:
        list = self.list()
        return list[0]["id"]

    @abstractmethod
    def create(self):
        pass

    @abstractmethod
    def list(self):
        pass

    @abstractmethod
    def update(self):
        pass

    @abstractmethod
    def destroy(self):
        pass

    @abstractmethod
    def detail(self):
        pass


class TopicAPIHandler(APIHandler):
    class Meta:
        url = "/forum/topic/"

    def generate_data(self, fk: int = 1) -> dict:
        fake = Faker()
        data = {
            "name": fake.text(max_nb_chars=10),
            "is_private": False,
            "owner": fk,
        }
        return data

    def get_pk(self, model: str = None) -> int:
        list = self.list()
        return list[0]["id"]

    def create(self):
        self.api_call("post", self.get_url(), data=self.generate_data())

    def list(self):
        res = self.api_call("get", self.get_url())
        return res.json()

    def update(self):
        pk = self.get_pk()
        fk = self.get_pk()
        requests.put(self.get_url(detail=True, pk=pk), data=self.generate_data(fk))

    def destroy(self):
        pk = self.get_pk()
        self.api_call("delete", self.get_url(pk=pk))

    def detail(self):
        pk = self.get_pk()
        requests.get(self.get_url(detail=True, pk=pk))


class PostAPIHandler(APIHandler):
    class Meta:
        url = "/forum/post/"

    def generate_data(self, fk: int = 1) -> dict:
        fake = Faker()
        data = {
            "topic": fk,
            "title": fake.text(max_nb_chars=20),
            "content": fake.text(max_nb_chars=100),
        }

        return data

    def create(self):
        if self.model == "topic":
            self.api_call("post", self.get_url(), data=self.generate_data())
            requests.post(self.get_url(), data=self.generate_data())
        elif self.model == "post":
            fk = self.get_pk("topic")
            requests.post(self.get_url(), data=self.generate_data(fk))

    def list(self, model=None):
        target_model = model or self.model
        if target_model == "topic":
            res = requests.get(self.get_url())
        elif target_model == "post":
            res = requests.get(f"{self.host}/forum/topic/{self.get_pk('topic')}/posts")
        else:
            raise Exception

        return res

    def update(self):
        pk = self.get_pk()
        fk = self.get_pk()
        requests.put(self.get_url(detail=True, pk=pk), data=self.generate_data(fk))

    def destroy(self):
        pk = self.get_pk()
        requests.delete(self.get_url(detail=True, pk=pk))

    def detail(self):
        pk = self.get_pk()
        requests.get(self.get_url(detail=True, pk=pk))


def sleep():
    sleep_time = random.randrange(10, 100) / 100
    time.sleep(sleep_time)


if __name__ == "__main__":
    topic_handler = TopicAPIHandler()

    while True:
        topic_handler.create()
        sleep()
        topic_handler.destroy()
        sleep()
