InterfaceHelper = new Object();

InterfaceHelper.clear = function(input) {
  if(!input.ihAlreadySet) {
    input.ihAlreadySet = true;
    input.style.color = 'black';
    input.style.fontStyle = 'normal';
    input.ihDefaultValue = input.value;
    input.value = '';
  }
};

InterfaceHelper.reset = function(input) {
  if(input.value == '') {
    input.ihAlreadySet = false;
    input.style.color = 'gray';
    input.style.fontStyle = 'italic';
    input.value = input.ihDefaultValue; 
  }
};