import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:likeminds_flutter_sample/chat/service/likeminds_service.dart';
import 'package:likeminds_flutter_sample/chat/service/service_locator.dart';
import 'package:overlay_support/overlay_support.dart';

part 'poll_event.dart';
part 'poll_state.dart';

class PollBloc extends Bloc<PollEvents, PollState> {
  PollBloc() : super(PollInitial()) {
    on<SubmitPoll>(mapSubmitPollEvent);
    on<AddPollOption>(mapAddPollOption);
    on<GetPollUsers>(mapGetPollUsers);
    on<UpdatePoll>(mapUpdatePoll);
    on<EditPollSubmittion>((event, emit) => emit(EditingPollSubmission()));
  }

  /*
  * This function is used to update a poll
  * It takes a UpdatePoll event and an Emitter<PollState> as parameters
  * to raise UpdatePoll event, [GetConversationRequest] is neccessary
  */
  void mapUpdatePoll(UpdatePoll event, Emitter<PollState> emit) async {
    LMResponse response = await locator<LikeMindsService>()
        .getConversation(event.getConversationRequest);
    if (response.success) {
      emit(UpdatedPoll(
          getConversationResponse: response.data!,
          conversationId: event.getConversationRequest.conversationId!));
    } else {
      toast(response.errorMessage ?? "An error occurred");
    }
  }

  /*
  * This function is used to submit a poll
  * It takes a SubmitPoll event and an Emitter<PollState> as parameters
  * to raise SubmitPoll event, [SubmitPollRequest] is neccessary
  */
  void mapSubmitPollEvent(SubmitPoll event, Emitter<PollState> emit) async {
    LMResponse response =
        await locator<LikeMindsService>().submitPoll(event.submitPollRequest);
    if (response.success) {
      emit(SubmittedPoll(
          submitPollResponse: response.data,
          conversationId: event.submitPollRequest.conversationId));
    } else if (response.errorMessage != null) {
      emit(
        PollSubmitError(
          errorMessage: response.errorMessage ?? "An error occurred",
          submitPollRequest: event.submitPollRequest,
        ),
      );
    }
  }

  /*
  * This function is used to add a new option to the poll
  * It takes a AddPollOption event and an Emitter<PollState> as parameters
  * to raise AddPollOption, [AddPollOptionRequest] is neccessary
  */
  void mapAddPollOption(AddPollOption event, Emitter<PollState> emit) async {
    LMResponse response = await locator<LikeMindsService>()
        .addPollOption(event.addPollOptionRequest);
    if (response.success) {
      emit(PollOptionAdded(
          addPollOptionResponse: response.data,
          conversationId: event.addPollOptionRequest.conversationId));
    } else if (response.errorMessage != null) {
      emit(
        PollOptionError(
            errorMessage: response.errorMessage ?? "An error occurred",
            addPollOptionRequest: event.addPollOptionRequest,
            conversationId: event.addPollOptionRequest.conversationId),
      );
    }
  }

  /* 
  * Fetches the list of users who have voted on a poll
  * It takes a GetPollUsers event and an Emitter<PollState> as parameters
  * to raise GetPollUsers, [GetPollUsersRequest] is neccessary
  */
  void mapGetPollUsers(GetPollUsers event, Emitter<PollState> emit) async {
    emit(PollUsersLoading(getPollUsersRequest: event.getPollUsersRequest));
    LMResponse response = await locator<LikeMindsService>()
        .getPollUsers(event.getPollUsersRequest);
    if (response.success) {
      emit(PollUsers(getPollUsersResponse: response.data));
    } else {
      emit(PollUsersError(
          errorMessage: response.errorMessage ?? "An error occurred",
          getPollUsersRequest: event.getPollUsersRequest));
    }
  }
}
