--電脳堺獣－鷲々
--Cyberspace Beast Jiuiiu
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
	--indes
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.indcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e2)
	--to grave
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCost(s.gycost)
	e3:SetTarget(s.gytg)
	e3:SetOperation(s.gyop)
	c:RegisterEffect(e3)
end
function s.indfilter1(c,tp)
	return c:IsType(TYPE_MONSTER) and Duel.IsExistingMatchingCard(s.indfilter2,tp,LOCATION_GRAVE,0,1,c,c)
end
function s.indfilter2(c,tc)
	return c:IsType(TYPE_MONSTER) and c:GetOriginalAttribute()==tc:GetOriginalAttribute()
		and c:GetOriginalRace()==tc:GetOriginalRace()
		and not c:IsCode(tc:GetCode())
end
function s.indcon(e)
	return Duel.IsExistingMatchingCard(s.indfilter1,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil,e:GetHandlerPlayer())
end
function s.gycfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true)
end
function s.gycheck(sg,e,tp)
	return sg:GetClassCount(Card.GetOriginalAttribute)==1 
		and sg:GetClassCount(Card.GetOriginalRace)==1 
		and sg:GetClassCount(Card.GetCode)==#sg
		and Duel.IsExistingTarget(Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,sg)
end
function s.gycost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.gycfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil,tp)
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,2,2,s.gycheck,0) end
	local sg=aux.SelectUnselectGroup(g,e,tp,2,2,s.gycheck,1,tp,HINTMSG_REMOVE)
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
end
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToGrave() end
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectTarget(tp,Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
