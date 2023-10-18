---
title: App SDK - Background Publishing
---

# App Functions SDK - Background Publishing

!!! note
    The Background Publishing capability has been deprecated in EdgeX 3.1 and will be removed in the next major release. Use the [Service Publsh/PublishWithTopic](../api/ApplicationServiceAPI.md#publish) or [Context Publsh/PublishWithTopic](../api/AppFunctionContextAPI.md#publish) APIs instead.

Application Services using the MessageBus trigger can request a background publisher using the AddBackgroundPublisher API in the SDK.  This method takes an int representing the background channel's capacity as the only parameter and returns a reference to a BackgroundPublisher.  This reference can then be used by background processes to publish to the configured MessageBus output.  A custom topic can be provided to use instead of the configured message bus output as well.

!!! example "Example - Background Publisher"
    ```go    
    func runJob (service interfaces.ApplicationService, done chan struct{}){
    	ticker := time.NewTicker(1 * time.Minute)
    	
        //initialize background publisher with a channel capacity of 10 and a custom topic
        publisher, err := service.AddBackgroundPublisherWithTopic(10, "custom-topic")
        
        if err != nil {
            // do something
        }
    	
    	go func(pub interfaces.BackgroundPublisher) {
     		for {
     			select {
     			case <-ticker.C:
     				msg := myDataService.GetMessage()
     				payload, err := json.Marshal(message)
     				
     				if err != nil {
     					//do something
     				}
     				
     				ctx := svc.BuildContext(uuid.NewString(), common.ContentTypeJSON)
     				
     				// modify context as needed
     				
     				err = pub.Publish(payload, ctx)
     				
     				if err != nil {
     					//do something
     				}
     			case <-j.done:
     				ticker.Stop()
     				return
     			}
     		}
     	}(publisher)
     }
     
     func main() {
     	service := pkg.NewAppService(serviceKey)
     	
     	done := make(chan struct{})
     	defer close(done)
     
     	//pass publisher to your background job
     	runJob(service, done)
     
     	service.SetDefaultFunctionsPipeline(
     		All,
     		My,
     		Functions,
     	)
     	
     	service.Run()
     
     	os.Exit(0)
      }		
    ```