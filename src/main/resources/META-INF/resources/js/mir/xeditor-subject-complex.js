//Class SubjectComplex

function SubjectComplex (element) {
  this.element = element;
  this.topics=$(element).children(".form-group");
  this.labels = new Array;
  this.select;
  this.replaceLabels();
  this.initTopic();
  
  
  //subject.changeTopic(0);
  
};

SubjectComplex.prototype= {
  constructor: SubjectComplex
  
  ,initTopic: function () {
      subject=this;
      var setTopic = false;
  
      this.topics.each( function (index,topic) {
          if ( $(topic).find("input").val() != "" ) {
              subject.changeTopic(index);
              setTopic = true;
              return false;
          };
      });
      
      if (! setTopic) {
          subject.changeTopic(0);
      }
  
  }
  
  ,changeTopic: function (index) {
      if (index < this.topics.length && index >= 0) {
          var subject = this;
          subject.topics.addClass("d-none");
          subject.topics.each( function (tindex,topic) {
              $(topic).find("label").children().detach();
              $(topic).find("label").text(subject.labels[tindex]);
              if (index != tindex) {
                  $(topic).find("input").val("");
              }
          }); 
          this.select.find("option").eq(index).prop('selected', true);
          subject.topics.eq(index).removeClass("d-none");
          subject.topics.eq(index).find("label").empty();
          subject.topics.eq(index).find("label").append(this.select);
          
      }
  }
  
  ,unhideAll: function () {
      this.topics.removeClass("d-none");
  }
  
  ,replaceLabels: function () {
      var subject = this;
      var select = $('<select>');
      select.addClass("topicSelect");
      
      this.topics.each(function(index, child) {
          option = $('<option>');
          labeltext= $(child).find('label').text();
          subject.labels[index]=labeltext;
          option.text(labeltext);
	      option.data('topicindex',index);
	      select.append(option);  
	  });
	  
	  select.change(function () {
          var topicIndex = $(this).find("option:selected" ).data('topicindex');
          subject.changeTopic(topicIndex)
      });
      
      //this.topics.eq(0).find("label").append(select);
      
      this.select = select;
	  
  }
  
};

/// End Class SubjectComplex

$(document).ready(function() {
	$(".subject_select").each(function(index, elem) {
	    sub = new SubjectComplex (elem); 
	})
	//$("form").submit( function )
})