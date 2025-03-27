--地縛牢
--Earthbound Prison
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	c:RegisterEffect(e1)
	--Additional Normal Summon of 1 "Earthbound" monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_HAND|LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_EARTHBOUND))
	c:RegisterEffect(e2)
	--Halve your opponent's LP
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(s.discon)
	e3:SetTarget(s.distg)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_EARTHBOUND}
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() and chkc:IsType(TYPE_EFFECT) end
	if chk==0 then return true end
	if Duel.IsExistingTarget(aux.FaceupFilter(Card.IsType,TYPE_EFFECT),tp,0,LOCATION_MZONE,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e:SetOperation(s.activate)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsType,TYPE_EFFECT),tp,0,LOCATION_MZONE,1,1,nil)
	else
		e:SetProperty(0)
		e:SetOperation(nil)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local c=e:GetHandler()
		c:SetCardTarget(tc)
		--Negate its effects
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetRange(LOCATION_FZONE)
		e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
		e1:SetTarget(function(_e,_c) return _c==tc and c:IsHasCardTarget(tc) end)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsPreviousControler(tp) and c:IsReason(REASON_EFFECT)
end
function s.disconfilter(c)
	return c:IsSetCard(SET_EARTHBOUND) and c:IsFaceup() and c:IsMonster()
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.disconfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,nil) end
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SetLP(1-tp,Duel.GetLP(1-tp)/2,REASON_EFFECT)
	local g=Duel.GetMatchingGroup(Card.IsNegatable,tp,0,LOCATION_ONFIELD,nil)
	if #g==0 then return end
	local c=e:GetHandler()
	for tc in g:Iter() do
		tc:NegateEffects(c,RESET_PHASE|PHASE_END,true)
	end
end