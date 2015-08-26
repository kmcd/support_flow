require 'test_helper'

class GuidesTest < ActionDispatch::IntegrationTest
  test "list existing guides" do
    login(@rachel) do
      get team_guides_url(@support_flow)

      @support_flow.guides.each do |guide|
        assert_select 'a', href:edit_guide_path(guide)
      end
    end
  end

  test "create guide" do
    login(@rachel) do
      get team_guides_url(@support_flow)

      assert_select 'a', href:new_team_guide_path(@support_flow)

      get new_team_guide_path(@support_flow)

      assert_select 'form',
        action:team_guides_path(@support_flow),
        method:/post/i
      assert_select 'input', name:'guide[name]'
      assert_select 'textarea', name:'guide[content]'

      post_via_redirect \
        team_guides_path(@support_flow),
        guide:{name:'faq', content:'questions' }
    end

    get team_public_guide_url \
      team_name:@support_flow.name,
      host:'getsupportflow.com',
      slug:'faq'

    assert_select 'body', /questions/i
  end

  test "update home page" do
    login(@rachel) do
      get edit_guide_path(@home_page)

      assert_select 'form',
        action:guide_path(@home_page),
        method:/post/i
      assert_select 'input', name:'guide[name]'
      assert_select 'textarea', name:'guide[content]'

      put guide_path(@home_page), guide:{content:'panic' }
      assert_redirected_to edit_guide_path(@home_page)
    end

    get team_public_guides_url \
      team_name:@support_flow.name,
      host:'getsupportflow.com'

    assert_select 'body', /panic/i
  end

  test "permanent guides" do
    login(@rachel) do
      # dont delete home page
      get edit_guide_path(@home_page)
      assert_select "input[name='guide[name]']", readonly:'readonly'
      delete guide_path(@home_page)
      assert @home_page.reload.persisted?

      # dont delete template
      get edit_guide_path(@template)
      assert_select "input[name='guide[name]']", readonly:'readonly'
      delete guide_path(@template)
      assert @home_page.reload.persisted?
    end
  end

  test "template content" do
    @home_page.update content:'HEADER'
    @template.update content:'<html><!-- content -->FOOTER</html>'

    get team_public_guides_url \
      team_name:@support_flow.name,
      host:'getsupportflow.com'

    assert_select 'body', /header/i
    assert_select 'body', /footer/i
  end

  test "view count" do
    login(@rachel) do
      assert_no_difference('@home_page.reload.view_count') do
        get \
          team_public_guides_url( \
            team_name:@support_flow.name,
            host:'getsupportflow.com'),
          {},
          referer:'http://getsupportflow.net'

        assert_response :success
      end
    end

    assert_difference('@home_page.reload.view_count', 1) do
      get team_public_guides_url \
        team_name:@support_flow.name,
        host:'getsupportflow.com'

        assert_response :success
    end
  end

  test "search" do
    get team_guide_search_url(@support_flow)
    assert_response :success

    @support_flow.guides.each do |guide|
      assert_select 'a', href:team_public_guide_url(@support_flow, guide)
    end

    # Search by guide name
    assert_select 'form',
      action:team_guide_search_url(@support_flow),
      method:'get'
    assert_select 'form input', name:'q', type:'text'

    # Search by name
    get team_guide_search_url(@support_flow, q:@home_page.name)
    assert_select 'a', href:team_public_guide_url(@support_flow, @home_page)

    # Search by content
    get team_guide_search_url(@support_flow, q:@home_page.text_content)
    assert_select 'a', href:team_public_guide_url(@support_flow, @home_page)
  end
end
