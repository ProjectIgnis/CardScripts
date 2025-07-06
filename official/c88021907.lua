--塊斬機ラプラシア
--Primathmech Laplacian
--Scripted by AlphaKretin
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 3 Level 4 monsters
	Xyz.AddProcedure(c,nil,4,3)
	--Resolve effect(s) based on the number of detached materials
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e) return e:GetHandler():IsXyzSummoned() end)
	e1:SetCost(Cost.Detach(1,s.effcostmax,function(e,og) e:SetLabel(#og) end))
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
	--If a "Mathmech" card(s) you control would be destroyed by card effect, you can detach 1 material from this card instead
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(s.reptg)
	e2:SetValue(function(e,c) return s.repfilter(c,e:GetHandlerPlayer()) end)
	c:RegisterEffect(e2)
end
s.listed_series={SET_MATHMECH}
function s.effcostmax(e,tp)
	local ct=0
	if Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)>0 then ct=ct+1 end
	if Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,0,LOCATION_MZONE,1,nil) then ct=ct+1 end
	if Duel.IsExistingMatchingCard(aux.AND(Card.IsSpellTrap,Card.IsAbleToGrave),tp,0,LOCATION_ONFIELD,1,nil) then ct=ct+1 end
	return ct
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ct=e:GetLabel()
	if ct==0 then return end
	local b1=Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)>0
	local b2=Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,0,LOCATION_MZONE,1,nil)
	local b3=Duel.IsExistingMatchingCard(aux.AND(Card.IsSpellTrap,Card.IsAbleToGrave),tp,0,LOCATION_ONFIELD,1,nil)
	local options={
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)},
		{b3,aux.Stringid(id,3)}
	}
	local selection={}
	for i=1,ct do
		local op=Duel.SelectEffect(tp,table.unpack(options))
		options[op][1]=false
		selection[op]=true
		local loc=op==1 and LOCATION_HAND or (op==2 and LOCATION_MZONE or LOCATION_SZONE)
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,loc)
	end
	e:SetLabelObject(selection)
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local selection=e:GetLabelObject()
	if selection[1] then
		--Send 1 random card from your opponent's hand to the GY
		local g=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0)
		if #g>0 then
			local sg=g:RandomSelect(1-tp,1)
			Duel.SendtoGrave(sg,REASON_EFFECT)
		end
	end
	if selection[2] then
		--Send 1 monster your opponent controls to the GY
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,0,LOCATION_MZONE,1,1,nil)
		if #g>0 then
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
	if selection[3] then
		--Send 1 Spell/Trap your opponent controls to the GY
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,aux.AND(Card.IsSpellTrap,Card.IsAbleToGrave),tp,0,LOCATION_SZONE,1,1,nil)
		if #g>0 then
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end
function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(SET_MATHMECH)
		and c:IsControler(tp) and c:IsLocation(LOCATION_ONFIELD)
		and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp) and c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT) end
	if Duel.SelectEffectYesNo(tp,c,96) then
		c:RemoveOverlayCard(tp,1,1,REASON_EFFECT)
		return true
	else return false end
end
