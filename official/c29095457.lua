--原石の穿光
--Primite Drillbeam
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Negate the effects of 1 card on the field and if you do, banish it
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Set this card from your GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e,tp) return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_PRIMITE),tp,LOCATION_MZONE,0,1,nil) end)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
s.listed_names={id}
s.listed_series={SET_PRIMITE}
function s.costfilter(c)
	return (c:IsSetCard(SET_PRIMITE) or (c:IsMonster() and c:IsType(TYPE_NORMAL))) and not (c:IsPublic() or c:IsCode(id))
end
function s.nocostfilter(c)
	return (c:IsType(TYPE_NORMAL) or (c:IsSetCard(SET_PRIMITE) and c:IsLevelAbove(5))) and c:IsFaceup() and not c:IsType(TYPE_TOKEN)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,e:GetHandler())
	local b2=Duel.IsExistingMatchingCard(s.nocostfilter,tp,LOCATION_MZONE,0,1,nil)
	if chk==0 then return b1 or b2 end
	local op=nil
	if b1 and b2 then
		op=Duel.SelectEffect(tp,
			{b1,aux.Stringid(id,2)},
			{b2,aux.Stringid(id,3)})
	else
		op=(b1 and 1) or (b2 and 2)
	end
	if op==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,nil)
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
	elseif op==2 then
		return
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc:IsNegatable() and chkc:IsAbleToRemove() and chkc~=c end
	if chk==0 then return Duel.IsExistingTarget(aux.AND(Card.IsNegatable,Card.IsAbleToRemove),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
	local g=Duel.SelectTarget(tp,aux.AND(Card.IsNegatable,Card.IsAbleToRemove),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsNegatable() and tc:IsCanBeDisabledByEffect(e) then
		--Negate its effects
		tc:NegateEffects(e:GetHandler())
		Duel.AdjustInstantly(tc)
		if tc:IsDisabled() then
			Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
		end
	end
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSSetable() end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,tp,0)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsSSetable() then
		Duel.SSet(tp,c)
	end
end