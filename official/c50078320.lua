--刻印の調停者
--Engraver of the Mark
local s,id=GetID()
function s.initial_effect(c)
	--Declare 1 other card name
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.declcon)
	e1:SetCost(Cost.SelfToGrave)
	e1:SetOperation(s.declop)
	c:RegisterEffect(e1)
	--Destroy 1 face-up card on the field during the End Phase of the next turn
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e2:SetCountLimit(1)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
function s.declcon(e,tp,eg,ep,ev,re,r,rp)
	local ex,cg,ct,cp,cv=Duel.GetOperationInfo(ev,CATEGORY_ANNOUNCE)
	return rp==1-tp and ex and (cv&ANNOUNCE_CARD+ANNOUNCE_CARD_FILTER)~=0
end
function s.declop(e,tp,eg,ep,ev,re,r,rp)
	local ex,cg,ct,cp,cv=Duel.GetOperationInfo(ev,CATEGORY_ANNOUNCE)
	local ac=0
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
	if (cv&ANNOUNCE_CARD)~=0 then
		ac=Duel.AnnounceCard(tp,cv)
	else
		ac=Duel.AnnounceCard(tp,table.unpack(re:GetHandler().announce_filter))
	end
	Duel.ChangeTargetParam(ev,ac)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,g,1,tp,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		local turn_count=Duel.GetTurnCount()
		--Destroy it during the End Phase of the next turn
		aux.DelayedOperation(tc,PHASE_END,id,e,tp,
			function(ag)
				Duel.Hint(HINT_CARD,0,id)
				Duel.Destroy(ag,REASON_EFFECT)
			end,
			function() return Duel.GetTurnCount()==turn_count+1 end,
			nil,2,aux.Stringid(id,2)
		)
	end
end