//tree will be used for applying changes
var waiting = true
class treeNode{
  constructor(activity, key, waiting){
    this.waiting = waiting||0;
    this.next = [];
    this.activity = activity;
    this.was_changed = false;
    this.key = key;
  }
  depDone(){this.waiting-=1;}
  depChange(){
    this.waiting-=1;
    this.was_changed = true;
  }
  ready(){return this.waiting<=0}
  change(){
    var newToChange = [];
    var wasChange = false;
    var i;

    if(this.was_changed){
      wasChange = this.activity.change()
      this.was_changed = false
    }

    if (wasChange){
      for (i=0; i<this.next.length; i++){
        this.next[i].depChange()
        if (this.next[i].ready()){
          newToChange.push(this.next[i])
        }
      }
    } else {
      for (i=0; i<this.next.length; i++){
        if (!this.next[i].ready()){
          this.next[i].depDone()
          if (this.next[i].ready()){
            newToChange.push(this.next[i])
          }
        }
      }

    }
    return newToChange

  }
}

//Machine class
class machine {
  constructor(id, jss, typee) {
    this.id = id
    this.time_taken = 0
    this.machine = []
    this.JSS = jss
    if (typee == undefined){
      typee = 1
    }
    this.type = typee

  }

  addActivity(activity, position){
    position = position||-1;
    if(activity.earliest_time()>=0){
      if(activity.machine_type != this.type){
        move_not_possible("This activity cannot be done here");
        return
      }
      position-=1;
      var changed_activities = []
      if(activity.machine == this.id && activity.position<position){
        position-=1;
      }
      if(activity.machine>-1){
        changed_activities = changed_activities.concat(this.JSS.machines[activity.machine].remove_activity(activity.position))
      }

      if (position>=0 && position < this.machine.length){

        var canDoIt = true
        var idAct = activity.id
        var idJob = activity.activities.id
        var i;
        for (i = 0; i<position; i++){
          if (this.machine[i].activities.id== idJob && this.machine[i].id > idAct){
            canDoIt = false
            break;
          }
        }
        if (canDoIt){
          this.machine.splice(position, 0, activity)
          activity.changeMachine(this.id)
          for(i=position; i<this.machine.length; i++){
            this.machine[i].position = i;
          }
          if (this.JSS.pendant_activities.length >0){
            this.JSS.fillTree(this.JSS.pendant_activities[0])
          }

          activity.update_status(-1,-1)
          this.JSS.fillTree(new treeNode(activity,activity.activities.id.toString()+", "+activity.id.toString()), changed_activities)

        } else {
          move_not_possible("This activity cannot be placed here");
        }

      } else {
        var position = this.machine.length
        var starting_time = Math.max(this.time_taken, activity.earliest_time())
        var end_time = starting_time + activity.time_cost
        this.machine.push(activity)
        activity.changeMachine(this.id)

        move_activity(this.id, -1, activity.activity_id, starting_time-this.time_taken, -1)
        this.time_taken = end_time;
        activity.update_status(starting_time, end_time)
        activity.position = position
        if (this.time_taken>maxTime){
          window.alert("Activity overflow")
          endGame()
        }

        if (changed_activities.length > 0){
          activity = changed_activities[0]
          this.JSS.fillTree(new treeNode(activity,activity.activities.id.toString()+", "+activity.id.toString()))
        }
      }
    } else {
      move_not_possible("This activity cannot be placed yet");
    }
  }

  getNext(position){
    position+=1;
    if(this.machine.length >position){
      return [this.machine[position]]
    }
    return []

  }

  //in order to be able to move activities on an specific position we need to know
  //   before which activity on a machine will it be placed, if there is no activity
  //    -1 will be returned
  nextId(position){
    position+=1;
    if(this.machine.length >position){
      return this.machine[position].activity_id
    }
    return -1
  }

  change(position){
    var activity = this.machine[position]
    var prevStartTime = activity.starting_time
    var prevTime = 0
    if (position-1>=0){
      prevTime = this.machine[position-1].end_time;
    }
    var starting_time = Math.max(prevTime, activity.earliest_time())

    move_activity(this.id, position, activity.activity_id, starting_time-prevTime, this.nextId(position))

    if (starting_time == prevStartTime){
      return false
    }
    var end_time = starting_time + activity.time_cost

    if (position >= this.machine.length -1){
      this.time_taken = end_time
    }
    if (this.time_taken>maxTime){
      window.alert("Activity overflow")
      endGame()
    }
    activity.update_status(starting_time, end_time)
    return true
  }

  remove_activity(position){

    this.machine.splice(position,1)

    if (this.machine.length > 0){
      if (position>= this.machine.length){
        this.time_taken = this.machine[this.machine.length-1].end_time
        return []
      }
    } else {
      this.time_taken = 0
      return []
    }
    var i
    for(i = position; i< this.machine.length; i++){
      this.machine[i].position = i;
    }
    return [this.machine[position]]
  }

  unused_time(){
    var unused_time = 0;
    prev_time = 0;
    var i
    for(i = 0; i < this.machine.length; i++){
      unused_time += this.machine[i].starting_time - prev_time
      prev_time = this.machine[i].end_time
    }
    return unused_time
  }
}

class activity {
  constructor(id, activities, time_cost, normalized_time, jss, machine_type, activity_id){
    if (machine_type == undefined){
      machine_type = 1
    }
    this.machine_type = machine_type
    this.id = id
    this.activities = activities
    this.time_cost = time_cost
    this.normalized_time = normalized_time
    this.starting_time = -1
    this.end_time = -1
    this.machine = -1
    this.position = -1
    this.JSS = jss
    this.activity_id = activity_id
    activities_map[activity_id] = this

  }

  earliest_time(){
    return this.activities.get_earliest_time(this.id)

  }

  update_status(starting_time, end_time){
    this.starting_time = starting_time
    this.end_time = end_time
  }

  getNext(){
    var nexts = this.activities.getNext(this.id)
    if (this.machine>=0){
      nexts = nexts.concat(this.JSS.machines[this.machine].getNext(this.position))
    }
    return nexts
  }

  change(){
    if (this.machine >=0){
      return this.JSS.machines[this.machine].change(this.position)
    }
    return false
  }

  changeMachine(id){
    this.machine = id
    this.activities.changeMachine(this.id, id)
  }

  dependant_machine(){
    return this.JSS.machines[this.machine].machine.length - this.position -1
  }
  dependant_activities(){
    return this.activities.next_id -this.id -1
  }

  remove_from_machines(){


    if (this.activities.getNext(this.id).length<=0){

      if (this.JSS.pendant_activities.length >0){
        this.JSS.fillTree(this.JSS.pendant_activities[0])
      }
      move_activity(-1, -1, this.activity_id)
      var changed_activities = []
      if(this.machine>-1){
        changed_activities = this.JSS.machines[this.machine].remove_activity(this.position)
        this.changeMachine(-1)
        this.update_status(-1,-1)
        if (changed_activities.length > 0){
          var activity = changed_activities[0]
          this.JSS.fillTree(new treeNode(activity,activity.activities.id.toString()+", "+activity.id.toString()))
        }
      }
      this.changeMachine(-1)
      this.update_status(-1,-1)

    } else {
      move_not_possible("For removing this activity you need to remove another activity");
    }
  }

}

class activities{
  constructor(id, activities_cost, jss, representation){
    this.representation = representation||'x'
    this.id = id
    this.activities = new Array(activities_cost.length)
    var cont = 0
    this.total_cost = 0
    var i
    for (i=0; i < activities_cost.length; i++){
      this.activities[i] = new activity(i, this, activities_cost[i][0], activities_cost[i][0], jss, activities_cost[i][1], activities_cost[i][2])
      console.log("activity", i, activities_cost[i][1])
      this.total_cost += activities_cost[i][0]
    }
    this.remaining_time = this.total_cost
    this.machine_activities = []
    for (i = 0; i < activities_cost.length; i++){
      this.machine_activities.push(-1)
    }
    this.JSS = jss
    this.next_id = 0

  }

  get_earliest_time (id){
    if(id<=0){
      return 0
    } else {
      return this.activities[id-1].end_time
    }
  }
  getTimes(){
    var total_done = 0
    var j
    for(j=0; j<this.activities.length && this.machine_activities[j]>=0; j++){
      total_done += this.activities[j].time_cost
    }
    return [this.total_cost, total_done]
  }
  getNext (id){
    id+=1
    if(this.activities.length>id && this.machine_activities[id]>=0){
      return [this.activities[id]]
    }
    return []
  }
  next_free_activity(){
    if(this.next_id<this.activities.length){
      return this.activities[this.next_id]
    }
    return null
  }
  changeMachine(act_id, mach_id){
    this.machine_activities[act_id] = mach_id
    if(act_id == this.next_id && mach_id>=0){
      this.next_id+=1
      this.remaining_time -= this.activities[act_id].time_cost
    } else if (act_id < this.next_id && mach_id<0){
      this.next_id = act_id
      this.remaining_time += this.activities[act_id].time_cost
    }

  }

  pendant_activities(){
    var pnd_activities = []
    var i = this.next_id
    while(i<this.activities.length){
      pnd_activities.push(this.activities[i].time_cost)
      i+=1
    }
    return pnd_activities
  }
}

class JSSProblem {
  constructor(id, source, solver, saved_steps) {
    this.id = id
    this.solver = solver
    this.seen_activities = new Map()

    this.activities =[]
    this.pendant_activities= []
    this.readSource(source)
    this.start(saved_steps)
  }

  percentage_complete(){
    var j
    var tempInfo
    var total = 0
    var total_done = 0
    for (j=0; j<this.activities.length; j++){
      tempInfo = this.activities[j].getTimes()
      total += tempInfo[0]
      total_done += tempInfo[1]
      console.log(j, tempInfo)
    }
    console.log( total, total_done)
    return total_done*1.0/total
  }

  getNode(activity, waiting){
    waiting = waiting||0
    var current_node = null
    var key = activity.activities.id.toString()+ ", "+ activity.id.toString()
    if (! this.seen_activities.has(key)){
      current_node = new treeNode(activity, key, waiting)
      this.seen_activities.set(key, current_node)

    } else {
      current_node = this.seen_activities.get(key)
      current_node.waiting += waiting
    }
    return current_node
  }

  isDependant(d, n){
    if (d.activities.id == n.activities.id && d.id>n.id){
      return true
    }
    return false
  }
  fillTree(root, other_activities){
    other_activities = other_activities||[]
    root.was_changed = true
    this.pendant_activities.push(root)
    this.seen_activities.set(root.key, root)
    var toChange = [root]

    var i
    for(i = 0; i<other_activities.length; i++){
      var o_a = this.getNode(other_activities[i])
      if (this.isDependant(root.activity, o_a.activity)){
        toChange.splice(0, toChange.length)
        this.seen_activities.clear()
        this.pendant_activities.splice(0, this.pendant_activities.length)
        move_not_possible("Activity cannot be placed here as there is a dependancy that could not be solved");
        return
      }
      o_a.was_changed=true
      toChange.push(o_a)
      this.pendant_activities.push(o_a)

    }
    for (i=0; i<this.pendant_activities.length; i++){
      var tempNext = this.pendant_activities[i].activity.getNext()
      var tempNodes = []
      var j
      for (j = 0; j<tempNext.length; j++){
        var o_a = this.getNode(tempNext[j], 1)
        if (this.isDependant(root.activity, o_a.activity)){
          toChange.splice(0, toChange.length)
          this.seen_activities.clear()
          this.pendant_activities.splice(0, this.pendant_activities.length)
          move_not_possible("Activity cannot be placed here as there is a dependancy that could not be solved");
          return
        }
        tempNodes.push(o_a)
      }
      tempNext.splice(0,tempNext.length)

      this.pendant_activities[i].next = this.pendant_activities[i].next.concat(tempNodes)
      this.pendant_activities = this.pendant_activities.concat(tempNodes)
      tempNodes.splice(0, tempNodes.length)
    }

    this.pendant_activities.splice(0, this.pendant_activities.length)

    var i
    for(i = 0; i<toChange.length; i++){

      toChange = toChange.concat(toChange[i].change())

    }

    toChange.splice(0, toChange.length)
    this.seen_activities.clear()
  }

  readSource(source){
    this.machines = new Array(source.machines)
    var i
    for(i=0; i<source.machines; i++){
      this.machines[i] = new machine(i, this, parseInt(source.machine_type.charAt(i)))
      console.log(i, parseInt(source.machine_type.charAt(i)))
    }
    var a= source.activities.length

    for(i=0; i<a; i++){
      this.activities.push(new activities(i, source.activities[i], this, toString(i)))
    }
  }



  start(saved_steps){
    this.solver.start(this, saved_steps)
  }

}

class solver {
  constructor(){
    this.jssp = null
  }
  getNextStep(){
    // probably will come directly from the user
    var activity = null
    var  i
    for (i=0; i < this.jssp.activities.length; i++){
      activity = this.jssp.activities[i].next_free_activity()
      if (activity != null){
        var job = this.jssp.activities[i].id
        var act = activity
        break
      }

    }
    if (activity == null){
      return -1
    }
    var machine
    for(i=0; i<this.jssp.machines.length; i++){
      if(this.jssp.machines[i].type== activity.machine_type){
        machine = i
        break;
      }
    }
    return {activity: act, machine: machine, position:1}
  }

  do_step(activity, machine, position){
    if (machine == -1){
      activity.remove_from_machines()
    } else {
      this.jssp.machines[machine].addActivity(activity, position)
    }
  }

  get_done(){
    return this.jssp.percentage_complete()
  }


  start(jssp, saved_steps){
    this.jssp = jssp

    var j
    for(j=0; j<saved_steps.length; j++){
      this.do_step(activities_map[saved_steps[j][0]],saved_steps[j][1],saved_steps[j][2])
      step+=1
    }
    waiting = false
  }
}

function move_not_possible(msg){
  console.log(msg)
  if (!waiting){
    window.alert(msg)
  }
}
