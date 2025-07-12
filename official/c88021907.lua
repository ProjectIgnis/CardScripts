--塊斬機ラプラシア
--Primathmech Laplacian
--Scripted by AlphaKretin
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 3 Level 4 monsters
	Xyz.AddProcedure(c,nil,4,3)
	--If a "Mathmech" card(s) you control would be destroyed by card effect, you can detach 1 material from this card instead
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(s.reptg)
	e1:SetValue(function(e,c) return s.repfilter(c,e:GetHandlerPlayer()) end)
	c:RegisterEffect(e1)
	--Activate a number of effects to activate equal to the number of materials detached
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetCondition(function(e) return e:GetHandler():IsXyzSummoned() end)
	e2:SetCost(Cost.DetachFromSelf(1,s.effcostmax,function(e,og) e:SetLabel(#og) end))
	e2:SetTarget(s.efftg)
	e2:SetOperation(s.effop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_MATHMECH}
function s.repfilter(c,tp)
	return c:IsSetCard(SET_MATHMECH) and c:IsControler(tp) and c:IsOnField() and c:IsFaceup()
		and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp) and c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT) end
	return Duel.SelectEffectYesNo(tp,c,96) and c:RemoveOverlayCard(tp,1,1,REASON_EFFECT)>0
end
function s.effcostmax(e,tp)
	local ct=0
	if Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,0,LOCATION_HAND,1,nil) then ct=ct+1 end
	if Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,0,LOCATION_MZONE,1,nil) then ct=ct+1 end
	if Duel.IsExistingMatchingCard(aux.AND(Card.IsSpellTrap,Card.IsAbleToGrave),tp,0,LOCATION_ONFIELD,1,nil) then ct=ct+1 end
	return ct
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local b1=Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,0,LOCATION_HAND,1,nil)
	local b2=Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,0,LOCATION_MZONE,1,nil)
	local b3=Duel.IsExistingMatchingCard(aux.AND(Card.IsSpellTrap,Card.IsAbleToGrave),tp,0,LOCATION_ONFIELD,1,nil)
	local options={
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)},
		{b3,aux.Stringid(id,3)}
	}
	local locations=0
	local selection={}
	local ct=e:GetLabel()
	for i=1,ct do
		local op=Duel.SelectEffect(tp,table.unpack(options))
		options[op][1]=false
		selection[op]=true
		locations=locations|((op==1 and LOCATION_HAND) or (op==2 and LOCATION_MZONE) or LOCATION_ONFIELD)
	end
	e:SetLabelObject(selection)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,ct,1-tp,locations)
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local break_chk=false
	local selection=e:GetLabelObject()
	if selection[1] then
		--Send 1 random card from your opponent's hand to the GY
		local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,0,LOCATION_HAND,nil)
		if #g>0 then
			break_chk=true
			local sg=g:RandomSelect(1-tp,1)
			Duel.SendtoGrave(sg,REASON_EFFECT)
		end
	end
	if selection[2] then
		--Send 1 monster your opponent controls to the GY
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,0,LOCATION_MZONE,1,1,nil)
		if #g>0 then
			Duel.HintSelection(g)
			if break_chk then Duel.BreakEffect() end
			break_chk=true
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
	if selection[3] then
		--Send 1 Spell/Trap your opponent controls to the GY
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,aux.AND(Card.IsSpellTrap,Card.IsAbleToGrave),tp,0,LOCATION_ONFIELD,1,1,nil)
		if #g>0 then
			Duel.HintSelection(g)
			if break_chk then Duel.BreakEffect() end
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end
