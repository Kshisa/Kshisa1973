$(document).ready(function() {
    var monthNames = [ "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" ]; 
    var dayNames= ["Sun","Mon","Tue","Wen","Thu","Fri","Sut"]
    
    // Создаем объект newDate()
    var newDate = new Date();
    // "Достаем" текущую дату из объекта Date
    newDate.setDate(newDate.getDate());
    // Получаем день недели, день, месяц и год
    $('#Date').html(dayNames[newDate.getDay()] + " " + newDate.getDate() + 
    ' ' + monthNames[newDate.getMonth()] + ' ' + newDate.getFullYear());

    setInterval( function() {
        // Создаем объект newDate() и показывает секунды
        var seconds = new Date().getSeconds();
        // Добавляем ноль в начало цифры, которые до 10
        $("#sec").html(( seconds < 10 ? "0" : "" ) + seconds);
    },1000);
    
    setInterval( function() {
        // Создаем объект newDate() и показывает минуты
        var minutes = new Date().getMinutes();
        // Добавляем ноль в начало цифры, которые до 10
        $("#min").html(( minutes < 10 ? "0" : "" ) + minutes);
    },1000);
    
    setInterval( function() {
        // Создаем объект newDate() и показывает часы
        var hours = new Date().getHours();
        // Добавляем ноль в начало цифры, которые до 10
        $("#hours").html(( hours < 10 ? "0" : "" ) + hours);
    }, 1000);   
});
