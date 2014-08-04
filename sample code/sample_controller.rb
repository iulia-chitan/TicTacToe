class DevelopmentController < ApplicationController
  include DeltaAndAbilitySet
  include NewAbilitySet
  include NewTrackSet

  require 'csv'

  
  before_filter :check_courses_enabled, only:['assign_more_courses']

  skip_filter :authorize,              only:['badge_for_share', 'course_for_share', 'track_for_share']
  skip_filter :check_setup,            only:[ 'badge_for_share', 'course_for_share', 'track_for_share']
  
  layout 'private'

  def index
    
    @tracks = TracksUser.where(user_id: @user.id, is_global: true).order("track_id ASC").map(&:track)
    if @user.can_take_sample_assessment
      @sample_assessment = @user.sample_assessment.nil? ? SampleAssessment.create(:user_id => @user.id, :score => 0, :state => "started", :question_index => 0) : @user.sample_assessment
    end
    
    #only for users with tracks==============
    @progress = @user.tracks_progres if @user.enterprise.has_tracks_for_user?(@user) && !@user.tracks_users.global_tracks.all.empty?
    @completed_tracks = Track.all.select{|t| t.is_completed_with_or_without_assessment_by? @user} if @user.enterprise.has_tracks_for_user?(@user)
    @completed_tracks_size = @completed_tracks.size unless @completed_tracks.nil?
    #end tracks======================

    #only for users with company tracks==============
    @spec_tracks = TracksUser.where(user_id: @user.id, is_global: false).order("track_id ASC").map(&:track)
    @specific_tracks_size = @spec_tracks.size
    #end tracks======================

  end

  def badge_for_share
    @user = User.where(:id => params[:user_id]).first
    @badge = Badge.where(:id => params[:badge_id]).first
    @badge_courses = @badge.courses_for_badge
    render :layout => 'social'
  end

  def course_for_share
    @user = User.where(:id => params[:user_id].to_i).first
    @course = Course.unscoped.where(:id => params[:course_id].to_i).first
    render :layout => 'social'
  end

  def track_for_share
    @user = User.where(:id => params[:user_id].to_i).first
    @track = Track.where(:id => params[:track_id].to_i).first  
    render :layout => 'social'
  end

  def knowledge_chart

    @learning_categs = Course::CATEGORIES
    @selected_categ = params[:category].nil? ? 'Prepare' : params[:category]
    @subcategories = Course.grouped_subcategories @selected_categ
    @subcategories = @subcategories.collect{|s| [s, Course.by_subcategory(s)]}
  end

 
  def view_specific_courses
    @learning_categs = Course::CATEGORIES

    @courses = Course.unscoped.enterprise_exclusive(@enterprise.id).active.all
    
  end

  def assign_selected_course
    @course = Course.unscoped.where(id: params[:course_id]).first

    callback_url =  url_for(:only_path => false, :action => 'cloud_callback', :controller => 'development')  
    @course.assign_to @user, callback_url, true
    action_name = @course.enterprise_id.nil? ? 'knowledge_chart' : 'specific_courses'
    redirect_to action: action_name
  end

  def assign_more_courses
    unless @user.can_get_courses?
      flash[:error] = 'You have to complete all your courses before asking for a new set!'
      redirect_to action:'index'
    else
     @courses = NewAbilitySet.next_set_of_courses(@user)
     callback_url =  url_for(:only_path => false, :action => 'cloud_callback', :controller => 'development')
     @courses.each do |course|
       course.delay.assign_to @user, callback_url
     end
     
     redirect_to action:'stand_by_for_courses'
    end

  end

  private
  
  def controller 
    @controller
  end
 
  def check_courses_enabled
    return @enterprise.courses_enabled
  end

end
