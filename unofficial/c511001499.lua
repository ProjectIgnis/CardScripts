--テイクワンチャンス
--Take One Chance
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_CHAIN_END,TIMING_CHAIN_END|TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.tgfilter(c,tp,szone_adjustment)
	if not c:IsSpellTrap() or c:IsCode(id) then return false end
	local te=c:GetActivateEffect()
	--Check for HOPT
	if not (te and te:CheckCountLimit(tp)) then return false end
	--Check for "cannot activate" restrictions
	if c:IsHasEffect(EFFECT_CANNOT_TRIGGER) then return false end
	local cannot_act_restrictions={Duel.GetPlayerEffect(tp,EFFECT_CANNOT_ACTIVATE)}
	if cannot_act_restrictions[1] then
		for _,eff in ipairs(cannot_act_restrictions) do
			local eff_value=eff:GetValue()
			if type(eff_value)~='function' or eff_value(eff,te,tp) then return false end
		end
	end
	--Check using the returned values of "Duel.CheckEvent" only for the activation check
	if not Duel.IsChainSolving() then
		local te_effect_code=te:GetCode()
		local res,ceg,cep,cev,cre,cr,crp=Duel.CheckEvent(te_effect_code,true)
		--If it's "EVENT_FREE_CHAIN" then "res" will always be false
		if not res and te_effect_code~=EVENT_FREE_CHAIN then return false end
		local condition=te:GetCondition()
		local cost=te:GetCost()
		local target=te:GetTarget()
		--Check if the card can be activated
		if condition and not condition(te,tp,ceg,cep,cev,cre,cr,crp) then return false end
		if cost and not cost(te,tp,ceg,cep,cev,cre,cr,crp,0) then return false end
		if target and not target(te,tp,ceg,cep,cev,cre,cr,crp,0) then return false end
	end
	--Don't need to check for zones for a Field Card
	if c:IsType(TYPE_FIELD) then return true end
	--Check for cards that can only be activated in certain zones
	local zones=0xff
	if te:IsHasProperty(EFFECT_FLAG_LIMIT_ZONE) then
		zones=te:GetValue()(te,tp,eg,ep,ev,re,r,rp)
	end
	return Duel.GetLocationCount(tp,LOCATION_SZONE,tp,LOCATION_REASON_TOFIELD,zones)-szone_adjustment>0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		local szone_adjustment=c:IsLocation(LOCATION_SZONE) and 0 or 1
		return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_GRAVE,0,1,c,tp,szone_adjustment)
	end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_GRAVE,0,nil)
	if #g==0 then return end
	local sc=g:RandomSelect(tp,1):GetFirst()
	if not sc then return end
	Duel.HintSelection(sc)
	if not s.tgfilter(sc,tp,0) then return end
	local te=sc:GetActivateEffect()
	if not te then return end
	local location=sc:IsType(TYPE_FIELD) and LOCATION_FZONE or LOCATION_SZONE
	--Adjust "zones" for cards that can only be activated in certain zones
	local zones=0xff
	if te:IsHasProperty(EFFECT_FLAG_LIMIT_ZONE) then
		zones=te:GetValue()(te,tp,eg,ep,ev,re,r,rp)
	end
	if not Duel.MoveToField(sc,tp,tp,location,POS_FACEUP,true,zones) then return end
	--Set activated status, show the card, create relation to itself, and use the effect's count limit (if any)
	sc:SetStatus(STATUS_ACTIVATED,true)
	Duel.Hint(HINT_CARD,0,sc:GetCode())
	sc:CreateEffectRelation(te)
	te:UseCountLimit(tp)
	--Mark the card as "to be sent to the GY" if it's not a card that remains on the field after activation
	if not (sc:IsType(TYPE_FIELD) or sc:IsEquipSpell() or sc:IsContinuousSpellTrap() or sc:IsLinkSpell()
		or sc:IsHasEffect(EFFECT_REMAIN_FIELD) or te:GetCost()==aux.RemainFieldCost) then
		sc:CancelToGrave(false)
	end
	local te_effect_code=te:GetCode()
	local ceg,cep,cev,cre,cr,crp
	if te_effect_code==EVENT_CHAINING then
		--If it's "EVENT_CHAINING" then manually grab the previous Chain Link's relevant values cuz "Duel.CheckEvent" won't return the proper values anymore
		local trig_chain_link=Duel.GetCurrentChain()-1
		local trig_eff,trig_player=Duel.GetChainInfo(trig_chain_link,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
		local trig_eg=Group.FromCards(trig_eff:GetHandler())
		ceg,cep,cev,cre,cr,crp=trig_eg,trig_player,trig_chain_link,trig_eff,0,trig_player
	else
		--If it's not "EVENT_CHAINING" then use the values returned by "Duel.CheckEvent"
		_,ceg,cep,cev,cre,cr,crp=Duel.CheckEvent(te_effect_code,true)
	end
	--Execute the cost, target, and operation with the designated parameters if the card's effects after it's placed on the field aren't negated
	if not sc:IsDisabled() then
		local cost=te:GetCost()
		local target=te:GetTarget()
		local operation=te:GetOperation()
		--Set the effect's property so that targeted cards are highlighted normally
		e:SetProperty(te:GetProperty())
		--Activation procedure
		if cost then cost(te,tp,ceg,cep,cev,cre,cr,crp,1) end
		if target then target(te,tp,ceg,cep,cev,cre,cr,crp,1) end
		--Manually create the effect relation for any targeted cards
		local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
		if tg then
			for tc in tg:Iter() do
				tc:CreateEffectRelation(te)
			end
		end
		e:SetProperty(0)
		local field_event_eg=Group.FromCards(sc)
		local current_chain_link=Duel.GetCurrentChain()
		--Manually raise the events for activating it
		Duel.RaiseSingleEvent(sc,EVENT_CHAINING,te,0,tp,tp,current_chain_link)
		Duel.RaiseEvent(field_event_eg,EVENT_CHAINING,te,0,tp,tp,current_chain_link)
		--Break to separate the activation and the resolution
		Duel.BreakEffect()
		--Manually raise the events for the start of resolution
		Duel.RaiseSingleEvent(sc,EVENT_CHAIN_SOLVING,te,0,tp,tp,current_chain_link)
		Duel.RaiseEvent(field_event_eg,EVENT_CHAIN_SOLVING,te,0,tp,tp,current_chain_link)
		--Resolution of the effect
		if operation then operation(te,tp,ceg,cep,cev,cre,cr,crp) end
		--Manually raise the events for the end of resolution
		Duel.RaiseSingleEvent(sc,EVENT_CHAIN_SOLVED,te,0,tp,tp,current_chain_link)
		Duel.RaiseEvent(field_event_eg,EVENT_CHAIN_SOLVED,te,0,tp,tp,current_chain_link)
	end
	--Manually release the effect relation for this card and any targeted cards
	sc:ReleaseEffectRelation(te)
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if tg then
		for tc in tg:Iter() do
			tc:ReleaseEffectRelation(te)
		end
	end
end