defmodule Elastix.MappingTest do
  use ExUnit.Case
  alias Elastix.Index
  alias Elastix.Mapping
  alias Elastix.Document

  @test_url Elastix.config(:test_url)
  @test_index Elastix.config(:test_index)
  @test_index2 Elastix.config(:test_index) <> "_2"
  @mapping %{
    properties: %{
      user: %{type: "integer"},
      message: %{type: "boolean"}
    }
  }
  @target_mapping %{
    "properties" => %{
      "user" => %{"type" => "integer"},
      "message" => %{"type" => "boolean"}
    }
  }
  @data %{
    user: 12,
    message: true
  }

  setup do
    Index.delete(@test_url, @test_index)
    Index.delete(@test_url, @test_index2)

    :ok
  end

  test "make_path should make url from index names, types, and query params" do
    assert Mapping.make_path([@test_index], version: 34, ttl: "1d") ==
             "/#{@test_index}/_mapping?version=34&ttl=1d"
  end

  test "make_all_path should make url from types, and query params" do
    assert Mapping.make_all_path(version: 34, ttl: "1d") ==
             "/_mapping?version=34&ttl=1d"
  end

  test "make_all_path should make url from query params" do
    assert Mapping.make_all_path(version: 34, ttl: "1d") == "/_mapping?version=34&ttl=1d"
  end

  test "put mapping with no index should error" do
    {:ok, response} = Mapping.put(@test_url, @test_index, @mapping)

    assert response.status_code == 404
  end

  test "put should put mapping" do
    Index.create(@test_url, @test_index, %{})
    {:ok, response} = Mapping.put(@test_url, @test_index, @mapping)

    assert response.status_code == 200
    assert response.body["acknowledged"] == true
  end

  test "get with non existing index should return error" do
    {:ok, response} = Mapping.get(@test_url, @test_index)

    assert response.status_code == 404
  end

  test "get with non existing mapping" do
    Index.create(@test_url, @test_index, %{})
    {:ok, response} = Mapping.get(@test_url, @test_index)

    assert response.body == %{@test_index => %{"mappings" => %{}}}

    assert response.status_code == 200
  end

  test "get mapping should return mapping" do
    Index.create(@test_url, @test_index, %{})
    Mapping.put(@test_url, @test_index, @mapping)
    {:ok, response} = Mapping.get(@test_url, @test_index)

    assert response.status_code == 200
    assert response.body[@test_index]["mappings"] == @target_mapping
  end

  test "put document with mapping should put document" do
    Index.create(@test_url, @test_index, %{})
    Mapping.put(@test_url, @test_index, @mapping)

    {:ok, response} = Document.index(@test_url, @test_index, 1, @data)

    assert response.status_code == 201
    assert response.body["_id"] == "1"
    assert response.body["_index"] == @test_index
    assert response.body["result"] == "created"
  end
end
