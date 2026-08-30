--月女神の至天
--Ultimate Sky
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--If your opponent controls more monsters than you do: Activate 1 of these effects (but you can only use each effect of "Ultimate Sky" once per turn);
	--● Target face-up cards on the field up to the number of face-up monsters your opponent controls and pay 800 LP for each target; negate their effects until the end of this turn
	--● When your opponent activates a monster effect in the hand or GY: Negate that effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
	end)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
end
function s.rescon(sg,e,tp,mg)
	return Duel.CheckLPCost(tp,800*#sg)
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return e:GetChainData().choice==1 and chkc:IsNegatable() and chkc:IsOnField() and chkc~=c end
	--● Target face-up cards on the field up to the number of face-up monsters your opponent controls and pay 800 LP for each target; negate their effects until the end of this turn
	local negate_group=Duel.GetTargetGroup(Card.IsNegatable,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
	local opp_faceup_monster_count=Duel.GetMatchingGroupCount(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local option_1=not Duel.HasFlagEffect(tp,id)
		and #negate_group>0
		and opp_faceup_monster_count>0
		and Duel.CheckLPCost(tp,800)
	--● When your opponent activates a monster effect in the hand or GY: Negate that effect
	local event_chk,_,event_player,event_value,event_reff=Duel.CheckEvent(EVENT_CHAINING,true)
	local option_2=not Duel.HasFlagEffect(tp,id+1)
		and event_chk and event_player==1-tp and event_reff:IsMonsterEffect()
		and Chain.IsTriggeringLocation(event_value,LOCATION_HAND|LOCATION_GRAVE)
		and Duel.IsChainDisablable(event_value)
	if chk==0 then return option_1 or option_2 end
	local choice=Duel.SelectEffect(tp,
		{option_1,aux.Stringid(id,1)},
		{option_2,aux.Stringid(id,2)})
	local cd=e:GetChainData()
	cd.choice=choice
	if choice==1 then
		--● Target face-up cards on the field up to the number of face-up monsters your opponent controls and pay 800 LP for each target; negate their effects until the end of this turn
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		local max_target_count=math.min(#negate_group,opp_faceup_monster_count,Duel.GetLP(tp)//800)
		local tg=aux.SelectUnselectGroup(negate_group,e,tp,1,max_target_count,s.rescon,1,tp,HINTMSG_NEGATE,s.rescon)
		Duel.SetTargetCard(tg)
		Duel.PayLPCost(tp,800*#tg)
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,tg,#tg,tp,0)
	elseif choice==2 then
		--● When your opponent activates a monster effect in the hand or GY: Negate that effect
		Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE|PHASE_END,0,1)
		e:SetProperty(0)
		cd.event_value=event_value
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,tp,0)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local choice=e:GetChainData().choice
	if choice==1 then
		--● Target face-up cards on the field up to the number of face-up monsters your opponent controls and pay 800 LP for each target; negate their effects until the end of this turn
		local tg=Duel.GetTargetCards(e)
		if #tg==0 then return end
		local c=e:GetHandler()
		for tc in tg:Iter() do
			--Negate their effects until the end of this turn
			tc:NegateEffects(c,RESET_PHASE|PHASE_END,true)
		end
	elseif choice==2 then
		--● When your opponent activates a monster effect in the hand or GY: Negate that effect
		Duel.NegateEffect(e:GetChainData().event_value)
	end
end