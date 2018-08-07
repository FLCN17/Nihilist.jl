


<a id='Deleting-1'></a>

# Deleting


Records, Files, Arms, and Events may be deleted from a project via API call.


<a id='Records-1'></a>

## Records

<a id='REDCap.delete_records-Tuple{REDCap.Config,Array}' href='#REDCap.delete_records-Tuple{REDCap.Config,Array}'>#</a>
**`REDCap.delete_records`** &mdash; *Method*.



```
delete_records(config::REDCap.Config, records::Array; arm::Integer=0)
```

Delete one or more records from project.

**Parameters:**

  * `config` - Struct containing the url and api-key
  * `records` - Array of record names to delete
  * `arm` - Number of arm containing records

**Returns:**

Number of records successfully deleted


An array of `record_id` names is passed, and if they exist, they will be deleted.


```julia
#For non-longitudinal projects
delete_records(config, ["1","2","25"])

delete_records(config, ["1","2","25"], arm="1")
```


The number of records deleted will be returned. If a record is specified that does not exist, REDCap will throw an error (It will <b>NOT</b> delete the valid ids).


<a id='Files-1'></a>

## Files

<a id='REDCap.delete_file-Tuple{REDCap.Config,String,String,String}' href='#REDCap.delete_file-Tuple{REDCap.Config,String,String,String}'>#</a>
**`REDCap.delete_file`** &mdash; *Method*.



```
delete_file(config::REDCap.Config, record::String, field::String, event::String; 
					repeat_instance::Integer=1, returnFormat::String="json")
```

Delete document attached to record.

**Parameters:**

  * `config` - Struct containing url and api-key
  * `record` - Name of record containing file
  * `field` - Name of field containing file
  * `event` - Name of event containing file
  * `repeat_instance` - Number of repeated instances (long project)
  * `returnFormat` - Error message format

**Returns:**

Nothing/error


The location of the file must be specified by passing the record name, the field containing the file, and the event.


```julia
delete_file(config, "2", "file_upload", "event")
```


<a id='Arms-1'></a>

## Arms

<a id='REDCap.delete_arms-Tuple{REDCap.Config,Array}' href='#REDCap.delete_arms-Tuple{REDCap.Config,Array}'>#</a>
**`REDCap.delete_arms`** &mdash; *Method*.



```
delete_arms(config::REDCap.Config, arms::Array)
```

Delete Arms from project. Removing all arms reverts the project into a non-longitudinal project.

**NOTE: This only works for longitudinal projects.**

**Parameters:**

  * `config` - Struct containing url and api-key
  * `arms` - Array of arm names to delete

**Returns:**

Number of succesfully deleted arms


```julia
delete_arms(config, ["1"])
```


<a id='Events-1'></a>

## Events

<a id='REDCap.delete_events-Tuple{REDCap.Config,Array}' href='#REDCap.delete_events-Tuple{REDCap.Config,Array}'>#</a>
**`REDCap.delete_events`** &mdash; *Method*.



```
delete_events(config::REDCap.Config, events::Array)
```

Delete Events from project. Removing all but one event reverts the project into a non-longitudinal project.

**NOTE: This only works for longitudinal projects.**

**Parameters:**

  * `config` - Struct containing url and api-key
  * `events` - Array of event names to delete

**Returns:**

Number of successfully deleted events


```julia
delete_events(config, ["event_1_arm_1"])
```

