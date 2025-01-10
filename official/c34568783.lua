--レアル・ジェネクス・ウンディーネ
--R-Genex Undine
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Banish 1 "Genex" monster from your GY and gain its Attribute
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.attrcost)
	e1:SetOperation(s.attrop)
	c:RegisterEffect(e1)
	--Add 2 "Genex" monsters from your GY to your hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_GENEX}
function s.attrcfilter(c,attr)
	return c:IsSetCard(SET_GENEX) and c:IsMonster() and c:IsAbleToRemoveAsCost() and attr&c:GetAttribute()==0
end
function s.attrcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local attr=e:GetHandler():GetAttribute()
	if chk==0 then return Duel.IsExistingMatchingCard(s.attrcfilter,tp,LOCATION_GRAVE,0,1,nil,attr) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local sc=Duel.SelectMatchingCard(tp,s.attrcfilter,tp,LOCATION_GRAVE,0,1,1,nil,attr):GetFirst()
	Duel.Remove(sc,POS_FACEUP,REASON_COST)
	local tn_chk=sc:IsType(TYPE_TUNER) and 1 or 0
	e:SetLabel(sc:GetAttribute(),tn_chk)
end
function s.attrop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (c:IsFaceup() and c:IsRelateToEffect(e)) then return end
	local attr,tn_chk=e:GetLabel()
	if c:IsAttribute(attr) then return end
	--This card gains that monster's Attribute
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ADD_ATTRIBUTE)
	e1:SetValue(attr)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE)
	c:RegisterEffect(e1)
	if tn_chk==0 then return end
	Duel.BreakEffect()
	--Can be treated as a Tuner this turn
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
	e2:SetCode(EFFECT_CAN_BE_TUNER)
	e2:SetReset(RESETS_STANDARD_PHASE_END)
	c:RegisterEffect(e2)
end
function s.thcfilter(c)
	return c:IsSetCard(SET_GENEX) and c:IsType(TYPE_SYNCHRO) and c:IsFaceup()
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.thcfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.thfilter(c,e)
	return c:IsSetCard(SET_GENEX) and c:IsMonster() and c:IsAbleToHand() and c:IsCanBeEffectTarget(e)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() and c:IsCanBeEffectTarget(e)
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,c,e) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,c,e)
	Duel.SetTargetCard(g+c)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,2,tp,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg>0 then
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
	local c=e:GetHandler()
	--Banish any card sent to your GY
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e1:SetTargetRange(0xff,0)
	e1:SetTarget(s.rmtg)
	e1:SetValue(LOCATION_REMOVED)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	aux.RegisterClientHint(c,0,tp,1,0,aux.Stringid(id,3))
end
function s.rmtg(e,c)
	local tp=e:GetHandlerPlayer()
	return c:GetOwner()==tp and Duel.IsPlayerCanRemove(tp,c)
end