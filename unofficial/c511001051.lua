--The Phantom Knights of Break Sword
local s,id=GetID()
function s.initial_effect(c)
	local g=Group.CreateGroup()
	g:KeepAlive()
	--xyz summon
	Xyz.AddProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),3,2)
	c:EnableReviveLimit()
	--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(s.sumcon)
	e1:SetTarget(s.sumtg)
	e1:SetOperation(s.sumop)
	c:RegisterEffect(e1)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetOperation(s.op)
	e4:SetLabelObject(e1)
	c:RegisterEffect(e4)
	local e2=e1:Clone()
	e2:SetCode(EVENT_REMOVE)
	e2:SetLabelObject(e1)
	e2:SetTarget(s.sumtg2)
	e2:SetOperation(s.sumop2)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_TO_DECK)
	c:RegisterEffect(e3)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetOverlayGroup()
	if #g==0 then return end
	g:KeepAlive()
	e:GetLabelObject():SetLabelObject(g)
end
function s.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousPosition(POS_FACEUP) and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function s.filter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=e:GetLabelObject()
	g=g:Filter(s.filter,nil,e,tp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft>1 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	if chk==0 then return #g>0 and ft>#g-1 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,#g,tp,nil)
end
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	g=g:Filter(s.filter,nil,e,tp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft>1 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	if ft<=#g-1 then return end
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(4)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
	Duel.SpecialSummonComplete()
end
function s.sumtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=e:GetLabelObject():GetLabelObject()
	g=g:Filter(s.filter,nil,e,tp)
	if chk==0 then return #g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>#g-1 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,#g,tp,nil)
end
function s.sumop2(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject():GetLabelObject()
	g=g:Filter(s.filter,nil,e,tp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=#g-1 then return end
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(4)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
	Duel.SpecialSummonComplete()
end
