--パワー・オブ・ザ・デュエリスト
--Power of the Duelist
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Declare 2, 3, or 4 Attributes; apply this effect based on the number declared, also during the End Phase of this turn, you must send all cards you control to the GY, unless you have activated effects of monsters of all declared Attributes in your field and/or GY this turn
	--● 2: Target 1 monster on the field; banish it
	--● 3: Draw 2 cards, then discard 1 card
	--● 4: Negate the effects of 2 face-up cards on the field
	--You can only activate 1 "Power of the Duelist" per turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
	--Keep track of the attributes of the monsters that activate their effects in your field and/or GY this turn
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAINING)
		ge1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
			if re:IsMonsterEffect() and Chain.IsTriggeringLocation(ev,LOCATION_MZONE|LOCATION_GRAVE) then
				local trig_attribute=Chain.GetTriggeringAttribute(ev)
				if not Duel.HasFlagEffect(rp,id) then
					Duel.RegisterFlagEffect(rp,id,RESET_PHASE|PHASE_END,0,1,trig_attribute)
				else
					local total_attributes=Duel.GetFlagEffectLabel(rp,id)|trig_attribute
					Duel.SetFlagEffectLabel(rp,id,total_attributes)
				end
			end
		end)
		Duel.RegisterEffect(ge1,0)
	end)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToRemove() end
	local c=e:GetHandler()
	--● 2: Target 1 monster on the field; banish it
	local option_1=Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	--● 3: Draw 2 cards, then discard 1 card
	local option_2=Duel.IsPlayerCanDraw(tp,2)
	--● 4: Negate the effects of 2 face-up cards on the field
	local option_3=Duel.IsExistingMatchingCard(Card.IsNegatable,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,2,c)
	if chk==0 then return option_1 or option_2 or option_3 end
	local choice=Duel.SelectEffect(tp,
		{option_1,aux.Stringid(id,1)},
		{option_2,aux.Stringid(id,2)},
		{option_3,aux.Stringid(id,3)})
	local chain_data=e.GetChainData()
	chain_data.choice=choice
	local declare_count=choice+1
	local declared_attributes=0
	for i=1,declare_count do
		declared_attributes=declared_attributes|Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL&(~declared_attributes))
	end
	chain_data.declared_attributes=declared_attributes
	local attributes={ATTRIBUTE_EARTH,ATTRIBUTE_WATER,ATTRIBUTE_FIRE,ATTRIBUTE_WIND,ATTRIBUTE_LIGHT,ATTRIBUTE_DARK,ATTRIBUTE_DIVINE}
	for i=1,7 do
		if attributes[i]&declared_attributes==attributes[i] then
			aux.RegisterClientHint(c,EFFECT_FLAG_OATH,tp,1,0,aux.Stringid(id,i+3))
		end
	end
	if choice==1 then
		--● 2: Target 1 monster on the field; banish it
		e:SetCategory(CATEGORY_REMOVE)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,tp,0)
	elseif choice==2 then
		--● 3: Draw 2 cards, then discard 1 card
		e:SetCategory(CATEGORY_DRAW|CATEGORY_HANDES)
		e:SetProperty(0)
		Duel.SetTargetPlayer(tp)
		Duel.SetTargetParam(2)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,1,tp,2)
		Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,1,tp,1)
	elseif choice==3 then
		--● 4: Negate the effects of 2 face-up cards on the field
		e:SetCategory(e:GetCategory()|CATEGORY_DISABLE)
		e:SetProperty(0)
		Duel.SetPossibleOperationInfo(0,CATEGORY_DISABLE,nil,2,PLAYER_EITHER,LOCATION_ONFIELD)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local chain_data=e.GetChainData()
	local choice=chain_data.choice
	local declared_attributes=chain_data.declared_attributes
	
	if choice==1 then
		--● 2: Target 1 monster on the field; banish it
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
		end
	elseif choice==2 then
		--● 3: Draw 2 cards, then discard 1 card
		local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
		if Duel.Draw(p,2,REASON_EFFECT)==2 then
			Duel.ShuffleHand(tp)
			Duel.BreakEffect()
			Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT|REASON_DISCARD)
		end
	elseif choice==3 then
		--● 4: Negate the effects of 2 face-up cards on the field
		local exc=c:IsRelateToEffect(e) and c or nil
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
		local g=Duel.SelectMatchingCard(tp,Card.IsNegatable,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,2,2,exc)
		if #g==2 then
			Duel.HintSelection(g)
			for sc in g:Iter() do
				sc:NegateEffects(c,nil,true)
			end
		end
	end
	--During the End Phase of this turn, you must send all cards you control to the GY, unless you have activated effects of monsters of all declared Attributes in your field and/or GY this turn
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return ((Duel.GetFlagEffectLabel(tp,id) or 0)&declared_attributes)~=declared_attributes
	end)
	e1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		Duel.Hint(HINT_CARD,1-tp,id)
		local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,0)
		if #g>0 then
			Duel.SendtoGrave(g,REASON_RULE)
		end
	end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end