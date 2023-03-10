defmodule Clik.CommandBehaviourTest do
  use ExUnit.Case, async: true

  require Clik.Command, as: Command
  alias Clik.{CommandEnvironment, Configuration}

  @test_env CommandEnvironment.new("foo")

  test "basic getters" do
    cmd = Command.new!(:hello_world, Clik.Test.HelloWorldCommand)
    assert 1 == Enum.count(Command.options(cmd))
    assert "Says hello to the world" == Command.help_text(cmd)
  end

  test "execute a command" do
    cmd = Command.new!(:hello_world, Clik.Test.HelloWorldCommand)
    assert :ok == Command.run(cmd, @test_env)
  end

  test "execute a command w/high-level interface" do
    cmd = Command.new!(:hello_world, Clik.Test.HelloWorldCommand)
    config = Configuration.add_command!(%Configuration{}, cmd)
    assert :ok == Clik.run(config, ["hello_world"], @test_env)
    assert :ok == Clik.run(config, [], @test_env)
  end

  test "execute a command w/high-level interface and bad command name" do
    cmd = Command.new!(:hello_world, Clik.Test.HelloWorldCommand)
    config = Configuration.add_command!(%Configuration{}, cmd)
    assert :ok == Clik.run(config, ["hello"], @test_env)
    assert :ok == Clik.run(config, [], @test_env)
  end

  test "execute a named command w/high-level interface" do
    config =
      Configuration.add_command!(
        %Configuration{},
        Command.new!(:hello_world, Clik.Test.HelloWorldCommand)
      )
      |> Configuration.add_command!(Command.new!(:baz, Clik.Test.BazCommand))

    assert :ok == Clik.run(config, ["hello_world"], @test_env)
  end

  test "execute a command w/high-level interface and default command" do
    cmd = Command.new!(:hello_world, Clik.Test.HelloWorldCommand)
    config = Configuration.add_command!(%Configuration{}, cmd)
    assert :ok == Clik.run(config, ["hello_world"], @test_env)
    assert :ok == Clik.run(config, [], @test_env)
  end

  test "execute command w/high-level interface and missing required option" do
    config =
      Configuration.add_command!(%Configuration{}, Command.new!(:bar, Clik.Test.BarCommand))

    assert {:missing_option, :foo} == Clik.run(config, ["bar"], @test_env)
  end

  test "execute command w/high-level interface and required option" do
    config =
      Configuration.add_command!(%Configuration{}, Command.new!(:bar, Clik.Test.BarCommand))

    assert :ok == Clik.run(config, ["bar", "--foo", "abc"], @test_env)
  end

  test "execute command w/high-level interface and unknown options" do
    config =
      Configuration.add_command!(%Configuration{}, Command.new!(:bar, Clik.Test.BarCommand))

    assert {:unknown_options, ["--bar", "--baz"]} ==
             Clik.run(config, ["bar", "--foo", "abc", "--bar", "--baz"], @test_env)
  end

  test "execute command w/high-level interface and default options" do
    config =
      Configuration.add_command!(%Configuration{}, Command.new!(:default, Clik.Test.BazCommand))

    assert :ok == Clik.run(config, ["baz", "--foo", "abc"], @test_env)
  end

  test "bad args are caught" do
    assert {:error, :badarg} == Command.new(:hello_world, nil)
    assert {:error, :badarg} == Command.new(nil, Clik.Test.HelloWorldCommand)
    assert {:error, :badarg} == Command.new(:hello, Clik.Test.ThisModuleDoesNotExist)
    assert_raise ArgumentError, fn -> Command.new!(:hello_world, nil) end
    assert_raise ArgumentError, fn -> Command.new!(nil, Clik.Test.HelloWorldCommand) end
    assert_raise ArgumentError, fn -> Command.new!(:hello, Clik.Test.ThisModuleDoesNotExist) end
  end
end
