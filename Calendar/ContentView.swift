//
//  ContentView.swift
//  Calendar
//
//  Created by Albert Kong on 2022/12/25.
//

import SwiftUI


struct DateButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}


extension Date {
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }
    
    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
            return calendar.component(component, from: self)
        }
}


extension Array: RawRepresentable where Element: Codable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode([Element].self, from: data)
        else {
            return nil
        }
        self = result
    }

    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
}


struct MonthView: View {
    @Binding var month: Month
    @Binding var selectedDate: Date_
    @State var days_before_month: Int
    var days_name = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    let columns = [GridItem(.flexible()),
                   GridItem(.flexible()),
                   GridItem(.flexible()),
                   GridItem(.flexible()),
                   GridItem(.flexible()),
                   GridItem(.flexible()),
                   GridItem(.flexible())]
    
    init(month: Binding<Month>, selectedDate: Binding<Date_>) {
        self._month = month
        self._selectedDate = selectedDate
        self.days_before_month = month.wrappedValue.start.get_day_num()
    }
    
    var body: some View {
        VStack {
            LazyVGrid(columns: columns){
                ForEach(days_name, id: \.self){i in
                    if i == "Sun" || i == "Sat"{
                        Text(i).font(.title3).bold().foregroundColor(Color.secondary)
                    } else {
                        Text(i).font(.title3).bold().foregroundColor(Color.primary)
                    }
                }
            }
            .padding(.horizontal)
            Divider()
            LazyVGrid(columns: columns){
                ForEach(0..<self.days_before_month, id: \.self){_ in
                    Spacer()
                }
                ForEach(0..<self.month.days_num, id: \.hashValue){i in
                    Button {
                        selectedDate = self.month.month_days_date[i]
                    } label: {
                        ZStack{
                            if self.month.month_days_date[i].get_string() == Date_().get_string() && selectedDate.get_string() == Date_().get_string() {
                                Circle()
                                    .stroke(Color.accentColor, lineWidth: 4)
                                    .background(Circle().fill(Color.accentColor))
                                    .frame(width: 40, height: 40)
                            } else if self.month.month_days_date[i].get_string() == Date_().get_string(){
                                Circle()
                                    .stroke(Color.accentColor, lineWidth: 4)
                                    .background(Circle().fill(Color("bg")))
                                    .frame(width: 40, height: 40)
                            } else if selectedDate.get_string() == self.month.month_days_date[i].get_string(){
                                Circle()
                                    .fill(Color.accentColor)
                                    .frame(width: 40, height: 40)
                            } else {
                                Circle()
                                    .fill(Color("bg"))
                                    .frame(width: 40, height: 40)
                            }
                            
                            if self.month.month_days_date[i].get_day_num() == 0 || self.month.month_days_date[i].get_day_num() == 6 {
                                Text(self.month.month_days_name[i]).foregroundColor(Color.secondary)
                            } else {
                                Text(self.month.month_days_name[i]).foregroundColor(Color.primary)
                            }
                        }
                    }
                        .buttonStyle(DateButton())
                    #if os(iOS)
                        .padding(.vertical)
                    #endif
                }
            }
            .padding([.leading, .bottom, .trailing])
            #if os(macOS)
                .frame(minWidth: 400, maxWidth: 500, minHeight: 300, maxHeight: 375)
            #else
                .frame(minHeight: 400)
            #endif
            .onChange(of: month.year){ new_year in
                self.days_before_month = month.start.get_day_num()
            }.onChange(of: month.month){ new_month in
                self.days_before_month = month.start.get_day_num()
            }
        }
        .padding()
    }
}


struct CalendarView: View {
    @State var month = Month()
    @Binding var selectedDate: Date_
    @State var year_num: Int = 0
    @State var month_num: Int = 0
    
    var body: some View {
        VStack{
            HStack{
                Menu(){
                    Picker("Year", selection: $year_num) {
                        ForEach(year_num-30...year_num+30, id: \.self) {i in
                            Text("\(i)")
                        }
                    }.pickerStyle(.menu)
                    
                    Picker("Month", selection: $month_num) {
                        ForEach(1...12, id: \.self) {i in
                            Text("\(i)")
                        }
                    }.pickerStyle(.menu)
                } label: {
                    Label(month.get_string(), systemImage: "calendar")
                }.padding()
                    .onChange(of: year_num) { new_year in
                        self.month = Month(year: new_year, month: month_num)
                    }.onChange(of: month_num) { new_month in
                        self.month = Month(year: year_num, month: new_month)
                    }.onAppear {
                        year_num = Date_().get_year()
                        month_num = Date_().get_month()
                    }
                
                Spacer()
                Button{
                    self.month_num -= 1
                    if self.month_num == 0 {
                        self.month_num = 12
                        self.year_num -= 1
                    }
                } label: {
                    Image(systemName: "chevron.left")
                    .font(.headline)
                }
                
                Button{
                    year_num = Date_().get_year()
                    month_num = Date_().get_month()
                    selectedDate = Date_()
                } label: {
                    Image(systemName: "dot.circle.fill")
                        .font(.headline)
                }
                
                Button{
                    self.month_num += 1
                    if self.month_num == 13 {
                        self.month_num = 1
                        self.year_num += 1
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.headline)
                }
            }.padding([.top, .leading, .trailing])
            MonthView(month: $month, selectedDate: $selectedDate)
        }
        #if os(macOS)
            .frame(minWidth: 400, maxWidth: 500, minHeight: 400, maxHeight: 450)
        #endif
    }
}


struct ReminderView: View {
    @Binding var selectedDate: Date_
    @State var selectedTab = 0
    @AppStorage("reminders") var reminders: [String] = []
    @AppStorage("types") var types: [Int] = []
    // type0: normal reminder; type1: daily repeats; type2: weekly repeats; type3: monthly repeats
    @AppStorage("dates") var dates: [Date] = []
    @AppStorage("firstStartUp") var firstStartUp = true
    
    init(selectedDate: Binding<Date_>){
        _selectedDate = selectedDate
        if firstStartUp{
            firstStartUp = false
            reminders = []
            types = []
            dates = []
        }
    }
    
    func difference_between(a: Date, b: Date) -> Int{
        print(Int(a - b))
        return Int(a - b)
    }
    
    var body: some View {
        VStack{
            Section{
                VStack(alignment: .leading){
                    Label("Today", systemImage: "calendar.badge.clock")
                        .font(.system(.title, design: .rounded, weight: .bold))
                        .foregroundColor(Color.accentColor)
                    Divider()
                        .padding(.horizontal)
                    ScrollView(showsIndicators: false){
                        LazyVStack {
                            ForEach(0..<reminders.count, id: \.self) { i in
                                if types[i] == 0{
                                    if difference_between(a: dates[i], b: Date_().date) == 0{
                                        Form{
                                            Label(reminders[i], systemImage: "circle.fill")
                                                .imageScale(.small)
                                        }
                                        .formStyle(.grouped)
                                    }
                                }
                            }
                        }
                    }
                }
            }.padding()
            Spacer()
            Section{
                ScrollView(showsIndicators: false){
                    VStack(alignment: .leading){
                        Label("Scheduled", systemImage: "calendar")
                            .font(.system(.title, design: .rounded, weight: .bold))
                            .foregroundColor(.red)
                        Divider()
                            .padding(.horizontal)
                        Text("hello")
                        Text("hello")
                    }
                }
            }.padding()
            Spacer()
            Section{
                ScrollView(showsIndicators: false){
                    VStack(alignment: .leading){
                        Label(selectedDate.get_string_human(), systemImage: "calendar.circle")
                            .font(.system(.title, design: .rounded, weight: .bold))
                            .foregroundColor(.yellow)
                        Divider()
                            .padding(.horizontal)
                        Text("hello")
                        Text("hello")
                    }
                }
            }.padding()
        }
            .toolbar{
                Image(systemName: "plus")
            }
            .frame(minWidth: 400)
    }
}


struct ContentView: View {
    @State var selectedDate = Date_()
    @State var selection = 1
    var body: some View {
        #if os(macOS)
        NavigationSplitView {
            CalendarView(selectedDate: $selectedDate)
        } detail: {
            ReminderView(selectedDate: $selectedDate)
                .frame(minWidth: 400)
        }
        #else
        TabView(selection: $selection) {
            CalendarView(selectedDate: $selectedDate)
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }.tag(1)
            ReminderView(selectedDate: $selectedDate)
                .tabItem {
                    Label("Reminder", systemImage: "note.text")
                }.tag(2)
        }
        #endif
    }
}



class Date_: ObservableObject {
    @Published var date = Date()
    
    private var date_formatter = DateFormatter()
    
    init(date: Date = Date()) {
        self.get_date_from_ymd(year:date.get(.year), month:date.get(.month), day: date.get(.day))
    }
    
    init(year: Int, month: Int, day: Int) {
        let gregorianCalendar = NSCalendar(calendarIdentifier: .gregorian)!

        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day

        self.date = gregorianCalendar.date(from: dateComponents)!
    }
    
    func get_date_from_ymd(year: Int, month: Int, day: Int){
        let gregorianCalendar = NSCalendar(calendarIdentifier: .gregorian)!

        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day

        self.date = gregorianCalendar.date(from: dateComponents)!
    }
    
    init(from: String){
        date_formatter.dateFormat = "YYYY MMMM d"
        self.date = date_formatter.date(from: from)!
    }
    
    public static func == (lhs: Date_, rhs: Date_) -> Bool{
        return lhs.date == rhs.date
    }
    
    func get_year() -> Int {
        date_formatter.dateFormat = "YYYY"
        return Int(date_formatter.string(from: self.date))!
    }
    
    func get_month() -> Int {
        date_formatter.dateFormat = "MM"
        return Int(date_formatter.string(from: self.date))!
    }
    
    func get_date() -> Int {
        date_formatter.dateFormat = "d"
        return Int(date_formatter.string(from: self.date))!
    }
    
    func get_day() -> String {
        date_formatter.dateFormat = "E"
        return date_formatter.string(from: self.date)
    }
    
    func get_string() -> String {
        date_formatter.dateFormat = "YYYY MMMM d"
        return date_formatter.string(from: self.date)
    }
    
    func get_string_human() -> String {
        date_formatter.dateFormat = "MMMM d, YYYY"
        return date_formatter.string(from: self.date)
    }
    
    func get_day_num() -> Int {
        func weekday(y: Int, m: Int, d: Int) -> Int{
            let f = Int(Double(14 - m) / 12)
            let Y = Double(y - f)
            let M = Double(m + 12 * f - 2)
            return (d + Int(Y) + Int(31 * M / 12) + Int(Y / 4) - Int(Y / 100) + Int(Y / 400)) % 7
        }
        return weekday(y: get_year(), m: get_month(), d: get_date())
    }
}


class Month: ObservableObject {
    @Published var year = Date_().get_year()
    @Published var month = Date_().get_month()
    var month_days: [Int]
    @Published var start: Date_
    @Published var end: Date_
    @Published var month_days_name: [String]
    @Published var month_days_date: [Date_]
    @Published var days_num: Int
    private var date_formatter = DateFormatter()
    
    
    init(year: Int = Date_().get_year(), month: Int = Date_().get_month()){
        self.year = year
        self.month = month
        self.month_days = [31, ((year % 4 == 0 && year % 100 == 0) || year % 400 == 0) ? 29 : 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
        self.days_num = month_days[month - 1]
        self.start = Date_(year: year, month: month, day: 1)
        self.end = Date_(year: year, month: year, day: month_days[month - 1])
        self.month_days_name = (1...month_days[month - 1]).map {"\($0)"}
        self.month_days_date = (1...month_days[month - 1]).map {Date_(year: year, month: month, day: $0)}
    }
    
    
    func get_string() -> String {
        date_formatter.dateFormat = "YYYY MMMM"
        return date_formatter.string(from: start.date)
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
