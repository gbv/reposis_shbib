//Class SubjectComplex

function SubjectComplex (element) {
  this.element = element;
  this.topics=$(element).find(".form-group");
  this.labels = new Array;
  this.select;
  this.replaceLabels();
  this.changeTopic(0);
};

SubjectComplex.prototype= {
  constructor: SubjectComplex
  
  ,changeTopic: function (index) {
      if (index < this.topics.length && index >= 0) {
          var subject = this;
          //subject.topics.addClass("hidden");
          subject.topics.each( function (tindex,topic) {
              $(topic).find("label").text(subject.labels[tindex]);
          }); 
          subject.topics.eq(index).removeClass("hidden");
          subject.topics.eq(index).find("label").empty();
          subject.topics.eq(index).find("label").append(this.select);
      }
  }
  
  ,unhideAll: function () {
      this.topics.removeClass("hidden");
  }
  
  ,replaceLabels: function () {
      var subject = this;
      var select = $('<select>');
      this.select = select;
      
      this.topics.each(function(index, child) {
          option = $('<option>');
          labeltext= $(child).find('label').text();
          subject.labels[index]=labeltext;
          option.text(labeltext);
	      option.data('topicindex',index);
	      select.append(option);  
	  });
	  
	  this.select.change(function () {
          var topicIndex = $(this).find("option:selected" ).data('topicindex');
          subject.changeTopic(topicIndex)
      });
	  
  }
  
};

/// End Class SubjectComplex

$(document).ready(function() {
	$(".subject_select").each(function(index, elem) {
	    sub = new SubjectComplex (elem); 
	})
	//$("form").submit( function )
})